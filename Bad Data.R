#  readr and fread
rm(list = ls())

x = read.csv("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv")
head(x)
str(x)

library(readr)
y = read_csv("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv")
# missing lots of tail id's

library(data.table)
z = fread("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv")


str(x)
str(y)
str(z)

sum(is.na(x))
sum(is.na(y))
sum(is.na(z))

# what do we do? 
#  Read the error!!  
#   Does this error look google-able?  What is "parsing"

x = read.csv("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv", 
             colClasses = c("character", "character"))

y = read.csv("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv", 
             colClasses = c("character", "character"))

z = fread("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv", 
          colClasses = c("character", "character")) 

str(y)
sum(is.na(y))  # cool! 

mean(y[,2])
mean(as.numeric(y[,2]))
which(is.na(as.numeric(y[,2])))
bad = which(is.na(as.numeric(y[,2])))
y[bad,]  # yeah, that's messy.
mean(y[-bad,2])
mean(as.numeric(y[-bad,2]))



#  what about fread?
fread("http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv")
badFile = "http://pages.stat.wisc.edu/~karlrohe/ds479/data/badRead.csv"
read_lines(badFile,skip = 1071,n_max = 3)
# I guess you have to go into a text editor to fix it,
# or try skipping/restarting several times... ugh. any thoughts?
#  At this point, regular expressions can be particularly useful!!!  
# And python / more text friendly languages...
# https://github.com/Rdatatable/data.table/issues/711

