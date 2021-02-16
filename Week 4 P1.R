#  This follows chapter 12 of r4ds.  

rm(list =ls())
library(tidyr)
library(dplyr)

table1  # if this doesn't load, make sure you have the most recent versions of tidyr and dplyr.
table2
table3
table4a
table4b
table5

# TIDY DATA:
# Each variable must have its own column.
# Each observation must have its own row.
# Each value must have its own cell.
# http://r4ds.had.co.nz/images/tidy-1.png

# which table above is tidy?

#  Simpler instructions:
# Put each dataset in a tibble.
# Put each variable in a column.


# dplyr, ggplot2, and all other the packages 
# in the tidyverse are designed to work with tidy data. 

table1 %>% 
  mutate(rate = cases / population * 10000)

table1 %>% 
  count(year, wt = cases)

library(ggplot2)
ggplot(table1, aes(year, cases)) + 
  geom_line(aes(group = country), colour = "grey50") + 
  geom_point(aes(colour = country))


# Exercise:
# Compute the rate for table2, and table4a + table4b. You will need to perform four operations:
#   
#   Extract the number of TB cases per country per year.
# Extract the matching population per country per year.
# Divide cases by population, and multiply by 10000.
# Store back in the appropriate place.
# Which representation is easiest to work with? Which is hardest? Why?




#     In data analysis, tidy data is the agile stance.  It facilitates quick and dynamic interactions with your data.

# I like to think:  
# Rows index the *units of observation* (i.e. "an observation" is one row).  
# The first columns identify the unit (country x year).  
# Then, the later columns give "the measurement"  



# to tidy the data (or organize it), two functions are particularly helpful:
# pivot_longer
# pivot_wider

# We are going to use those functions to tidy these tibbles:
table2
table4a
table4b

#  In brief....
# When units of analysis are distributed across different columns (i.e. variables of the "same thing" take up several columns),
#   then pivot_longer gets you tidy.  pivot_longer takes a tibble which is too wide and makes it thinner and taller. 

# When measurements are distributed across different rows (i.e. measurements on a unit of analysis takes up several rows), 
#  Then, your tibble is too long.  pivot_wider makes it shorter and wider.



##################
### pivot_longer #######
##################

table4a  # columns are identifiers!
table4a %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "cases")

# pipe data, then 
#   1) names of columns you wish to pivot.  This will create two new columns. 
#       The first column will contain the old column names.
#       The second column will contain the values.
#   2) names_to. what do you want to call the column that contains the old names?
#   3) what do you want to call the colum that contains the new values?

# http://r4ds.had.co.nz/images/tidy-9.png

# here is another example:
table4b

table4b %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "population")



#  Now, these two new data sets need to be put together!
#    This is peeking ahead to chapter 13 (next week)

tidy4a <- table4a %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "cases")
tidy4b <- table4b %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "population")
left_join(tidy4a, tidy4b)


table2  # this has the "opposite problem"!

##################
### pivot_wider #######
##################

# pivot_wider is the opposite of pivot_longer. You use it when an observation is scattered across multiple rows. 
table2

# This time, however, we only need two parameters:

# 1) The column that contains variable names. This should be a "qualitative" variable (factor or character).  Those character strings are going to become column names.
# 
# 2) The column that contains values.

table2 %>%
  pivot_wider(names_from = type, values_from = count)


# http://r4ds.had.co.nz/images/tidy-8.png


# pivot_longer() makes wide tables narrower and longer; 
# pivot_wider() makes long tables shorter and wider.

# pivot_longer is not *exactly* the "inverse" of pivot_wider but it is really close:

# what changes:
stocks <- tibble(
  year   = c(2015, 2015, 2016, 2016),
  half  = c(   1,    2,     1,    2),
  return = c(1.88, 0.59, 0.92, 0.17)
)
stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(`2015`:`2016`, names_to = "year", values_to = "return")


# why doesn't this run?
table4a %>% 
  pivot_longer(c(1999, 2000), names_to = "year", values_to = "cases")



#  is this data tidy?  why doesn't it pivot_wider?
people <- tribble(
  ~name,             ~key,    ~value,
  #-----------------|--------|------
  "Phillip Woods",   "age",       45,
  "Phillip Woods",   "height",   186,
  "Phillip Woods",   "age",       50,
  "Jessica Cordero", "age",       37,
  "Jessica Cordero", "height",   156
)

pivot_wider(people, names_from = key, values_from = value)





#separate and unite are less useful... but maybe you might need them.

#Separate splits one column into two different columns
table3

table3 %>% 
  separate(rate, into = c("cases", "population"))  # sep is a regular expression!


table3 %>% 
  separate(rate, into = c("cases", "population"), sep = "/", convert=T)  # sep is a regular expression!

table3 %>% 
  separate(year, into = c("century", "year"), sep = 2)  # this probably isn't a good idea for any ensuing data analysis... it is here to illustrate the function.

table3 %>% 
  separate(year, into = c("century", "year"), sep = 2)  #  notice the difference between this line and the last...


# Unite puts to columns together into a single column.
table5
table5 %>% 
  unite(new, century, year, sep = "")



#########################
##### Missing values#####
#########################

# Missing values are annoying.
# Missing values should be expected.

# how many missing values?
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)

# how many missing values?
stocks

# how many missing values?
stocks %>% pivot_wider(names_from = qtr,values_from = return)

# how many missing values?
stocks %>% 
  complete(year, qtr)



#  READ SECTION 12.6 IN R4DS!!!
# http://r4ds.had.co.nz/tidy-data.html#case-study
#  It puts all the pieces together in a case study.
#  Follow along by typing the code in your terminal.  



#  Tidy data is great for "90%" of "small data" problems (remember: small data is data that you can fit in memory, i.e. load into R)
#    As such, I think of tidy data as a default "null hypothesis" for how to store data.
#    Of course, there is another "10%" of problems.  See here:  http://simplystatistics.org/2016/02/17/non-tidy-data/






