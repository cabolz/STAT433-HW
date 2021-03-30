library(data.table)
library(tidyverse)
library(tidytext)
library(Matrix)
library(rARPACK)
library(glmnet)
library(randomForest)
library(textdata)


data = fread("https://raw.githubusercontent.com/bpb27/political_twitter_archive/master/realdonaldtrump/realdonaldtrump.csv") %>% as.tbl
str(data)

text_df <- tibble(tweet = 1:nrow(data), text = data$text)

# this does a lot of processing! 
#  to lower, remove @ # , . 
#  often these make sense on a first cut.
#  worth revisiting before "final results"!
tt  = text_df %>% unnest_tokens(word, text)
str(tt)

# make the document-term matrix.  
#   I sometimes call this the bag-of-words-matrix.
dt = cast_sparse(tt, tweet, word)
dt[1:10,1:20]
str(dt)
dim(dt)
hist(rowSums(dt))
cs = colSums(dt)
hist(log(cs[cs>1]))


# can we predict which phone it came from?
# http://varianceexplained.org/r/trump-tweets/ 
table(data$source) %>% sort
# these are tweets that we think trump wrote himself:
y = data$source == "Twitter for Android"  

sum(cs>20)
x = dt[,cs>20]  # is it "cheating" to select variables with cs?  
dim(x)  # what do we do???

# fancy regression!  
fit = glmnet(x, 
             y , 
             family = "binomial", 
             alpha  = .9,
             standardize = F)
dim(x)  # should have 2286 betas...
coef(fit) %>% dim  # but we actually have 100 of those beta vectors!
# agh!  need to "tune".... do it with cv...

cvfit = cv.glmnet(x,y, 
                  family = "binomial",
                  type.measure = "class", 
                  nfolds = 5, 
                  alpha = .1,
                  )
plot(cvfit)
betaHat = coef(cvfit, s = "lambda.1se")
tibble(word = colnames(x), beta = as.vector(betaHat[-1])) %>% 
  arrange(-beta)
tibble(word = colnames(x), beta = as.vector(betaHat[-1])) %>% 
  arrange(beta)

# hard to interpret!!!  What to do next if you want to make sense of it?
# Need to fit a different model... a model with more interpretable features.
#  Often, a **really good** path is to transform the data into new features.
#   these new features should be easier to interpret
#   and maybe also "low dimensional"  
#   ideally, you might have some "a priori" sense for why each feature
#     predicts the outcome y.  
#  Think of these new features as functions of the original features.
#    linear combinations is a big one...
#    how should we make linear combinations of features???
#    need "weights". 
#    In time series or image analysis, you can use "wavelets"
#    In text analysis, you can use sentiment analysis
#    In such examples, the "weights" are known before hand.  
#    You take your design matrix x and you multiple it by a weight matrix W
#    xW is your matrix of new features for regression!
#    In any example, you can find these weights by running PCA. 
#      I like adding a varimax rotation to find "clusters". 
#    This is a data driven way of finding a matrix W.  That is,
#    W is "estimated" from x (does not look at y). 


# sentiment analysis!
#   http://tidytextmining.com/sentiment.html
#   sentiment analysis is a way of creating new features from words. 
#   words are assigned values, eg whether they belong to these types:
sentiments$sentiment %>% table %>% names


str(sentiments)
sentiments$sentiment %>% table
get_sentiments("afinn")$value %>% table
get_sentiments("bing")$sentiment %>% table
get_sentiments("loughran")$sentiment %>% table 
get_sentiments("nrc")$sentiment %>% table 
# there are ~20 different values (T/F, valued, or +/-) assigned to each word.  
#   Lets make a matrix:
#     each row is a tweet
#     one column for each of these 20 "sentiment" features
# Then, we can run logistic regression with only 20 predictors... one for each sentiment.


finnFeat = tt %>% 
  left_join(get_sentiments("afinn")) %>% 
  group_by(tweet) %>% 
  summarize(afinn = mean(value, na.rm = T),
            afinnWords = sum(!is.na(value))
  )

bing = get_sentiments("bing") %>% 
  mutate(neg= sentiment == "negative", pos = sentiment =="positive")


bingFeat = tt %>% 
  left_join(bing) %>% 
  group_by(tweet) %>% 
  summarize(bingNeg = sum(neg, na.rm = T),
            bingPos = sum(pos, na.rm = T),
            bingWords = bingNeg + bingPos, 
            bing = bingPos/(bingWords+.000001))

lough = get_sentiments("loughran") %>% 
  rename(lough = sentiment)

lough = lough %>% 
  mutate(value = 1) %>% 
  pivot_wider(word, names_from = lough)


loughFeat = tt %>% 
  left_join(lough) %>% 
  group_by(tweet) %>% 
  summarize(  # is there an easier way to do this...???
    loughneg = sum(negative, na.rm=T),
    loughpos = sum(positive, na.rm=T),
    loughUnc = sum(uncertainty, na.rm=T),
    loughlit = sum(litigious, na.rm=T),
    loughConst = sum(constraining, na.rm=T),
    loughsuperfluous = sum(superfluous, na.rm=T))


nrc = get_sentiments("nrc") %>% rename(nrc = sentiment)

nrc %>% 
  mutate(value = 1) %>% 
  pivot_wider(word, names_from = nrc)

get_sentiments("nrc") %>% 
  pivot_wider(word, names_from = sentiments)


nrcWide = nrc %>% 
  mutate(value = 1) %>% pivot_wider(word, names_from = nrc)

nrcFeat = tt %>% 
  left_join(nrcWide) %>% 
  group_by(tweet) %>% 
  summarise(
    nrcTrust = sum(trust, na.rm = T),
    nrcFear = sum(fear, na.rm = T),
    nrcNegative = sum(negative, na.rm = T),
    nrcSadness = sum(sadness, na.rm = T),
    nrcAnger = sum(anger, na.rm = T),
    nrcSurprise = sum(surprise, na.rm = T),
    nrcPositive = sum(positive, na.rm = T),
    nrcDisgust = sum(disgust, na.rm = T),
    nrcJoy = sum(joy, na.rm = T),
    nrcAnticipation = sum(anticipation, na.rm = T),
  )


xsent = finnFeat %>% 
  left_join(bingFeat) %>% 
  left_join(loughFeat) %>% 
  left_join(nrcFeat)

xsent[is.na(xsent)] = 0

# make sure rows are in order:
mean(xsent$tweet == 1:nrow(xsent))
str(xsent)
fit = glm(y~ . -tweet, family = "binomial", data = xsent)
summary(fit)  # whats up with bingwords???  

fit = glm(y~ . - tweet - bingNeg - bingPos, 
          family = "binomial", data = xsent)
summary(fit)

xsentRescaled = scale(xsent)
apply(xsentRescaled[,-1], 2, sd) %>% plot

cvfit = cv.glmnet(as.matrix(xsent),y, 
                  family = "binomial",
                  type.measure = "class", 
                  nfolds = 5, 
                  alpha = .1)
plot(cvfit)





# let's make clusters/topics 
# install.packages("devtools")
devtools::install_github("RoheLab/vsp")
library(vsp)
fa = vsp(dt, k = 30)

#if you see radial streaks, aligned with the axes in this plot:
plot_varimax_z_pairs(fa, 1:10)

#  then see what the document clusters appear to be:
# 
topTweets = 3
# just run the next code chunk...

topDoc = fa$Z %>% 
  apply(2,
        function(x) which(rank(-x, ties.method = "random") <= topTweets)
  )
for(j in 1:ncol(topDoc)){
  paste("topic", j, "\n \n") %>% cat
  text_df$text[topDoc[,j]] %>% print
  paste("\n \n \n") %>% cat
}

glm(y~as.matrix(fa$Z), family = "binomial") %>% summary
cvfit = cv.glmnet(as.matrix(fa$Z),y, 
                  family = "binomial",
                  type.measure = "class", 
                  nfolds = 5, 
                  alpha = .1)
plot(cvfit)

