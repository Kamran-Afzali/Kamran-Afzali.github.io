---
title: "Tidy_Database"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

# Databases in R and Tidyverse 

As well as working with local in-memory data stored in data frames, dplyr also works with remote on-disk data stored in databases. This is particularly useful in two scenarios:

Your data is already in a database.

You have so much data that it does not all fit into memory simultaneously and you need to use some external storage engine.

(If your data fits in memory there is no advantage to putting it in a database: it will only be slower and more frustrating.)

This vignette focuses on the first scenario because it’s the most common. If you’re using R to do data analysis inside a company, most of the data you need probably already lives in a database (it’s just a matter of figuring out which one!). However, you will learn how to load data in to a local database in order to demonstrate dplyr’s database tools. At the end, I’ll also give you a few pointers if you do need to set up your own database.



## References




+ [Efficient grid search via racing with ANOVA models](https://rdbsql.rsquaredacademy.com/dbi.html)

+ [Create a Collection of tidymodels Workflows](https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html)

+ [Getting Started With stacks](https://github.com/andrew-couch/Tidy-Tuesday/blob/master/Season%201/Scripts/TidyTuesdayDatabase.Rmd)

