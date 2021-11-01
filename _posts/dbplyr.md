---
title: "Tidy_Database"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

# Databases in R and Tidyverse 


(If your data fits in memory there is no advantage to putting it in a database: it will only be slower and more frustrating.)

If you’re using R to do data analysis, most of the data you need probably already lives in a relational database. However, you will learn how to load data in to a local database in order to demonstrate dplyr’s database tools. For the this tutorial, I will write the nycflights13::planes and nycflights13::flights data to our database. Typically, data would already exist in the database of interest.




```r
library(nycflights13)
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.3.3     ✓ purrr   0.3.4
## ✓ tibble  3.1.2     ✓ dplyr   1.0.5
## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
## ✓ readr   1.4.0     ✓ forcats 0.5.0
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(DBI)
library(RSQLite)
library(tidypredict)
library(kableExtra)
```

```
## 
## Attaching package: 'kableExtra'
```

```
## The following object is masked from 'package:dplyr':
## 
##     group_rows
```

First, we would connect to our database using the DBI package. For the sake of example, I simply connect to an “in-memory” database, but a wide range of database connectors are available depending on where your data lives. It is noteworthy that: As well as working with local in-memory data stored in data frames, dplyr also works with remote on-disk data stored in databases. This is particularly useful in scenarios where data is already in a database, or data exceeda local memory and you need to use some external storage engine.



```r
con <- dbConnect(SQLite(), ":memory:")
```


The copy_to() function is used to get data to DB, this function has an additional argument that allows you to supply indexes for the table. Here we set up indexes that will allow us to quickly process the data by day, carrier, plane, and destination. Creating the right indices is key to good database performance, but is unfortunately beyond the scope of this article.


```r
copy_to(con, nycflights13::flights, "flights",
        temporary = FALSE, 
        indexes = list(
          c("year", "month", "day"), 
          "carrier", 
          "tailnum",
          "dest"
        ))
```
 it also possible to copy to a DB without indexing

```r
copy_to(con, nycflights13::planes, "planes")
```

To access the DB it is either possible to run quries either on a connection using *dbGetQuery*


```r
dbGetQuery(con, '
SELECT flight, type
FROM flights
JOIN planes
ON flights.tailnum = planes.tailnum
ORDER BY planes.tailnum
limit 10')%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> flight </th>
   <th style="text-align:left;"> type </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 4560 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4269 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4667 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4334 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4298 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4520 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4297 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4370 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4352 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4695 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
</tbody>
</table>

this can be done with different types of queries as follows



```r
dbGetQuery(con, '
  SELECT COUNT (dest)
FROM flights
WHERE (dest="SEA" AND year=2013)')%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> COUNT (dest) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 3923 </td>
  </tr>
</tbody>
</table>


```r
dbGetQuery(con, '
  SELECT COUNT (distinct carrier) AS "Number of unique airlines"
FROM flights
WHERE (dest="SEA" AND year=2013)')%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> Number of unique airlines </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 5 </td>
  </tr>
</tbody>
</table>


```r
dbGetQuery(con, '
SELECT tailnum, COUNT(tailnum)
FROM flights
GROUP BY tailnum
ORDER BY COUNT(tailnum) DESC
limit 10
           ')%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> tailnum </th>
   <th style="text-align:right;"> COUNT(tailnum) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> N725MQ </td>
   <td style="text-align:right;"> 575 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N722MQ </td>
   <td style="text-align:right;"> 513 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N723MQ </td>
   <td style="text-align:right;"> 507 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N711MQ </td>
   <td style="text-align:right;"> 486 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N713MQ </td>
   <td style="text-align:right;"> 483 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N258JB </td>
   <td style="text-align:right;"> 427 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N298JB </td>
   <td style="text-align:right;"> 407 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N353JB </td>
   <td style="text-align:right;"> 404 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N351JB </td>
   <td style="text-align:right;"> 402 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> N735MQ </td>
   <td style="text-align:right;"> 396 </td>
  </tr>
</tbody>
</table>

the other opetion would be to output the tables from Rmarkdown using *{sql, connection = con, output.var = "df"}*


```sql
SELECT flight, type
FROM flights
JOIN planes
ON flights.tailnum = planes.tailnum
ORDER BY planes.tailnum
limit 10
```

here the output is the df Dataframe


```r
df%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> flight </th>
   <th style="text-align:left;"> type </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 4560 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4269 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4667 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4334 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4298 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4520 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4297 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4370 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4352 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4695 </td>
   <td style="text-align:left;"> Fixed wing multi engine </td>
  </tr>
</tbody>
</table>

To interact with a database you usually use SQL, the Structured Query Language. SQL is over 40 years old, and is used by pretty much every database in existence. The goal of dbplyr is to automatically generate SQL for you so that you’re not forced to use it. However, SQL is a very large language and dbplyr doesn’t do everything. It focusses on SELECT statements, the SQL you write most often as an analyst.

Most of the time you don’t need to know anything about SQL, and you can continue to use the dplyr verbs that you’re already familiar with. The most important difference between ordinary data frames and remote database queries is that your R code is translated into SQL and executed in the database on the remote server, not in R on your local machine. When working with databases, dplyr tries to be as lazy as possible:

    It never pulls data into R unless you explicitly ask for it.

    It delays doing any work until the last possible moment: it collects together everything you want to do and then sends it to the database in one step.
Surprisingly, this sequence of operations never touches the database. It’s not until you ask for the data (e.g. by printing tailnum_delay) that dplyr generates the SQL and requests the results from the database. Even then it tries to do as little work as possible and only pulls down a few rows.

 we can use tbl() to take a reference to it:



```r
flights_db <- tbl(con, "flights")
```


Behind the scenes, dplyr is translating your R code into SQL. You can see the SQL it’s generating with show_query():

However, since we are using a remote backend, the penguins_aggr object does not contain the resulting data that we see when it is printed (forcing its execution). Instead, it contains a reference to the database’s table and an accumulation of commands than need to be run on the table in the future. We can access this underlying SQL translation with the dbplyr::show_query() and use capture.output() to convert that query (otherwise printed to the R console) to a character vector.



```r
tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)

tailnum_delay_db %>% show_query()
```

```
## Warning: Missing values are always removed in SQL.
## Use `mean(x, na.rm = TRUE)` to silence this warning
## This warning is displayed only once per session.
```

```
## Warning: ORDER BY is ignored in subqueries without LIMIT
## ℹ Do you need to move arrange() later in the pipeline or use window_order() instead?
```

```
## <SQL>
## SELECT *
## FROM (SELECT `tailnum`, AVG(`arr_delay`) AS `delay`, COUNT(*) AS `n`
## FROM `flights`
## GROUP BY `tailnum`)
## WHERE (`n` > 100.0)
```


```r
tailnum_query <- capture.output(show_query(tailnum_delay_db))
```

```
## Warning: ORDER BY is ignored in subqueries without LIMIT
## ℹ Do you need to move arrange() later in the pipeline or use window_order() instead?
```


If you’re familiar with SQL, this probably isn’t exactly what you’d write by hand, but it does the job. You can learn more about the SQL translation in vignette("translation-verb") and vignette("translation-function").

Typically, you’ll iterate a few times before you figure out what data you need from the database. Once you’ve figured it out, use collect() to pull all the data down into a local tibble:

collect() requires that database does some work, so it may take a long time to complete. Otherwise, dplyr tries to prevent you from accidentally performing expensive query operations:


```r
tailnum_delay <- tailnum_delay_db %>% collect()%>%kable()
```

```
## Warning: ORDER BY is ignored in subqueries without LIMIT
## ℹ Do you need to move arrange() later in the pipeline or use window_order() instead?
```

Run predictions inside the database. tidypredict parses a fitted R model object, and returns a formula in ‘Tidy Eval’ code that calculates the predictions.
tidypredict is able to parse an R model object and then creates the SQL statement needed to calculate the fitted prediction:


```r
model <- lm(arr_delay ~ month + distance + air_time, data = flights)
tidypredict_sql(model, dbplyr::simulate_mssql())
```

```
## <SQL> -1.17390925699898 + (`month` * -0.0414672658738873) + (`distance` * -0.0875558911189957) + (`air_time` * 0.664509571024122)
```
It returns a SQL query that contains the coefficients (model$coefficients) operated against the correct variable or categorical variable value. In most cases the resulting SQL is one short CASE WHEN statement per coefficient. It appends the offset field or value, if one is provided.


```r
dbGetQuery(con, 'SELECT -1.17390925699898 + (month * -0.0414672658738873) + (distance * -0.0875558911189957) + (air_time * 0.664509571024122) AS estimated_Delay, arr_delay
           FROM flights
           limit 10')%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> estimated_Delay </th>
   <th style="text-align:right;"> arr_delay </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 27.050048 </td>
   <td style="text-align:right;"> 11 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 25.649154 </td>
   <td style="text-align:right;"> 20 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9.757789 </td>
   <td style="text-align:right;"> 33 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -17.598209 </td>
   <td style="text-align:right;"> -18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9.150145 </td>
   <td style="text-align:right;"> -25 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 35.508373 </td>
   <td style="text-align:right;"> 12 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10.530112 </td>
   <td style="text-align:right;"> 19 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 13.953332 </td>
   <td style="text-align:right;"> -14 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9.163202 </td>
   <td style="text-align:right;"> -8 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 26.308476 </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
</tbody>
</table>



## References


+ [RDB SQL](https://rdbsql.rsquaredacademy.com/dbi.html)
+ [Introduction to dbplyr](https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html)
+ [NYC Queries](https://github.com/thakremanas/SQL-Queries-on-NYC-Fights-weather-data/blob/master/SQL%20Queries%20on%20NYC%20Flight%20and%20Weather%20dataset.sql)
+ [Tidy Predict](https://tidypredict.netlify.app)
+ [Generating SQL with {dbplyr} and sqlfluff](https://emilyriederer.netlify.app/post/sql-generation/)


