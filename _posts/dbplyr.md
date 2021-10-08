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



library(nycflights13)
library(tidyverse)
library(DBI)
library(RSQLite)

planes <- planes

flights <- flights
con <- dbConnect(SQLite(), ":memory:")
copy_to(con, flights)
copy_to(con, planes)
dbGetQuery(con, '
SELECT * 
FROM flights
           ')



dbGetQuery(con, '
SELECT tailnum, COUNT(tailnum)
FROM flights
GROUP BY tailnum
ORDER BY COUNT(tailnum) DESC
           ')


dbGetQuery(con, '
SELECT *
FROM flights
JOIN planes
ON flights.tailnum = planes.tailnum
ORDER BY planes.tailnum
           ')




```{sql, connection = con, output.var = "df"}
# SELECT fight.fight_pk, fight.fighter, B.opponent, CASE WHEN 
# fight.res = "W" THEN 1 ELSE 0 END AS fight_res
# FROM FIGHT
# JOIN (SELECT fight_pk, fighter AS opponent FROM FIGHT) B
# ON FIGHT.fight_pk = B.fight_pk
# WHERE fight.fighter != B.opponent AND fighter > opponent
# ORDER BY fight.fight_pk
 ```

```{r}
# df
```


dbGetQuery(con, '
  SELECT COUNT (dest)
FROM flights
WHERE (dest="SEA" AND year=2013)')  

dbGetQuery(con, '
  SELECT COUNT (distinct carrier) AS "Number of unique airlines"
FROM flights
WHERE (dest="SEA" AND year=2013)')  


copy_to(con, nycflights13::flights, "flights",
        temporary = FALSE, 
        indexes = list(
          c("year", "month", "day"), 
          "carrier", 
          "tailnum",
          "dest"
        )
)
flights_db <- tbl(con, "flights")

flights_db


tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)

tailnum_delay_db %>% show_query()


tailnum_delay <- tailnum_delay_db %>% collect()

tailnum_delay





## References


+ [Efficient grid search via racing with ANOVA models](https://rdbsql.rsquaredacademy.com/dbi.html)
+ [Create a Collection of tidymodels Workflows](https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html)
+ [Getting Started With stacks](https://github.com/andrew-couch/Tidy-Tuesday/blob/master/Season%201/Scripts/TidyTuesdayDatabase.Rmd)
+ [hhh](https://github.com/thakremanas/SQL-Queries-on-NYC-Fights-weather-data/blob/master/SQL%20Queries%20on%20NYC%20Flight%20and%20Weather%20dataset.sql)
+ 

