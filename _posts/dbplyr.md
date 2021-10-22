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

First, we would connect to our database using the DBI package. For the sake of example, I simply connect to an “in-memory” database, but a wide range of database connectors are available depending on where your data lives.

Again, for the sake of this tutorial only, I will write the palmerpenguins::penguins data to our database. Typically, data would already exist in the database of interest.



```{r}
library(nycflights13)
library(tidyverse)
library(DBI)
library(RSQLite)

planes <- planes

flights <- flights
```

```{r}
con <- dbConnect(SQLite(), ":memory:")
copy_to(con, flights)
copy_to(con, planes)
dbGetQuery(con, '
SELECT * 
FROM flights
           ')
```



```{r}
dbGetQuery(con, '
SELECT tailnum, COUNT(tailnum)
FROM flights
GROUP BY tailnum
ORDER BY COUNT(tailnum) DESC
           ')
```


```{r}
dbGetQuery(con, '
SELECT *
FROM flights
JOIN planes
ON flights.tailnum = planes.tailnum
ORDER BY planes.tailnum')
```




```{sql, connection = con, output.var = "df"}
SELECT fight.fight_pk, fight.fighter, B.opponent, CASE WHEN 
fight.res = "W" THEN 1 ELSE 0 END AS fight_res
FROM FIGHT
JOIN (SELECT fight_pk, fighter AS opponent FROM FIGHT) B
ON FIGHT.fight_pk = B.fight_pk
WHERE fight.fighter != B.opponent AND fighter > opponent
ORDER BY fight.fight_pk
```

```{r}
df
```


```{r}
dbGetQuery(con, '
  SELECT COUNT (dest)
FROM flights
WHERE (dest="SEA" AND year=2013)')
```  

```{r}
dbGetQuery(con, '
  SELECT COUNT (distinct carrier) AS "Number of unique airlines"
FROM flights
WHERE (dest="SEA" AND year=2013)')
```  

Our temporary database has no data in it, so we’ll start by copying over nycflights13::flights using the convenient copy_to() function. This is a quick and dirty way of getting data into a database and is useful primarily for demos and other small jobs.
```{r}
copy_to(con, nycflights13::flights, "flights",
        temporary = FALSE, 
        indexes = list(
          c("year", "month", "day"), 
          "carrier", 
          "tailnum",
          "dest"
        ))
```

As you can see, the copy_to() operation has an additional argument that allows you to supply indexes for the table. Here we set up indexes that will allow us to quickly process the data by day, carrier, plane, and destination. Creating the right indices is key to good database performance, but is unfortunately beyond the scope of this article.

Now that we’ve copied the data, we can use tbl() to take a reference to it:


```{r}
flights_db <- tbl(con, "flights")

flights_db
```

Generating queries

To interact with a database you usually use SQL, the Structured Query Language. SQL is over 40 years old, and is used by pretty much every database in existence. The goal of dbplyr is to automatically generate SQL for you so that you’re not forced to use it. However, SQL is a very large language and dbplyr doesn’t do everything. It focusses on SELECT statements, the SQL you write most often as an analyst.

Most of the time you don’t need to know anything about SQL, and you can continue to use the dplyr verbs that you’re already familiar with. The most important difference between ordinary data frames and remote database queries is that your R code is translated into SQL and executed in the database on the remote server, not in R on your local machine. When working with databases, dplyr tries to be as lazy as possible:

    It never pulls data into R unless you explicitly ask for it.

    It delays doing any work until the last possible moment: it collects together everything you want to do and then sends it to the database in one step.
Surprisingly, this sequence of operations never touches the database. It’s not until you ask for the data (e.g. by printing tailnum_delay) that dplyr generates the SQL and requests the results from the database. Even then it tries to do as little work as possible and only pulls down a few rows.

Behind the scenes, dplyr is translating your R code into SQL. You can see the SQL it’s generating with show_query():

However, since we are using a remote backend, the penguins_aggr object does not contain the resulting data that we see when it is printed (forcing its execution). Instead, it contains a reference to the database’s table and an accumulation of commands than need to be run on the table in the future. We can access this underlying SQL translation with the dbplyr::show_query() and use capture.output() to convert that query (otherwise printed to the R console) to a character vector.


```{r}
tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)

tailnum_delay_db %>% show_query()


penguins_query <- capture.output(show_query(penguins_aggr))
penguins_query

```
If you’re familiar with SQL, this probably isn’t exactly what you’d write by hand, but it does the job. You can learn more about the SQL translation in vignette("translation-verb") and vignette("translation-function").

Typically, you’ll iterate a few times before you figure out what data you need from the database. Once you’ve figured it out, use collect() to pull all the data down into a local tibble:

collect() requires that database does some work, so it may take a long time to complete. Otherwise, dplyr tries to prevent you from accidentally performing expensive query operations:

```{r}
tailnum_delay <- tailnum_delay_db %>% collect()

tailnum_delay
```

Run predictions inside the database. tidypredict parses a fitted R model object, and returns a formula in ‘Tidy Eval’ code that calculates the predictions.
tidypredict is able to parse an R model object and then creates the SQL statement needed to calculate the fitted prediction:

```{r}
model <- lm(arr_delay ~ month + distance + air_time, data = flights)
tidypredict_sql(model, dbplyr::simulate_mssql())
```
It returns a SQL query that contains the coefficients (model$coefficients) operated against the correct variable or categorical variable value. In most cases the resulting SQL is one short CASE WHEN statement per coefficient. It appends the offset field or value, if one is provided.

```{r}
dbGetQuery(con, 'SELECT -1.17390925699898 + (month * -0.0414672658738873) + (distance * -0.0875558911189957) + (air_time * 0.664509571024122) AS estimated_Delay, arr_delay
           FROM flights') 
```



## References


+ [Efficient grid search via racing with ANOVA models](https://rdbsql.rsquaredacademy.com/dbi.html)
+ [Introduction to dbplyr](https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html)
+ [TidyTuesday Database](https://github.com/andrew-couch/Tidy-Tuesday/blob/master/Season%201/Scripts/TidyTuesdayDatabase.Rmd)
+ [NYC Queries](https://github.com/thakremanas/SQL-Queries-on-NYC-Fights-weather-data/blob/master/SQL%20Queries%20on%20NYC%20Flight%20and%20Weather%20dataset.sql)
+ [Tidy Predict](https://tidypredict.netlify.app)
+ [Generating SQL with {dbplyr} and sqlfluff](https://emilyriederer.netlify.app/post/sql-generation/)


