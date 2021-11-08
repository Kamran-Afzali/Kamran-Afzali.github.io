---
title: "Portfolio Optimization"
output:
  html_document:
    df_print: paged
    keep_md: yes
editor_options: 
  markdown: 
    wrap: 72
---

# Portfolio Optimization
According to the Modern portfolio theory (MPT) for any given level of risk it is possible to maximize the return of a portfolio, which is in practice called portfolio optimization. To do this oone would need the historical prices of the assets that will be used to compute mean returns for the time period, as well as the covariance matrix between the assets for the same period, and finally random weights assigned to each asset and to maximize the return to risk ratio.

First you have to install and load the following packages:


```r
library(tidyquant) 
library(timetk) 
library(forcats)
library(tidyr)
library(kableExtra)
library(ggplot2)
library(dplyr)
```


### Sector etfs

This analysis is based on sector ETFs to gain a perspective on the
performance and risk of different sectors. IXC energy sector, IXG financial sector, IXN technology
sector, IXJ healthcare sector, IXP telecom sector, RXI consumer discretionary sector, EXI industrial sector, MXI basic sector, KXI consumer staple sector, and forJXI utlities sector. Here we use the *tq_get* function.


```r
tick <- c('IXC', 'IXG', 'IXN', 'IXJ', 'IXP','RXI','EXI','MXI','KXI','JXI')

price_data <- tq_get(tick,
                     from = '2010-01-01',
                     to = '2021-11-01',
                     get = 'stock.prices')
```

as always we transform the price to return and log transform it using
*tq_transmute* function


```r
log_ret_tidy <- price_data %>%
  dplyr::group_by(symbol) %>%
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,
               period = 'daily',
               col_rename = 'ret',
               type = 'log')

head(log_ret_tidy)%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> symbol </th>
   <th style="text-align:left;"> date </th>
   <th style="text-align:right;"> ret </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:left;"> 2010-01-04 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:left;"> 2010-01-05 </td>
   <td style="text-align:right;"> 0.0054231 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:left;"> 2010-01-06 </td>
   <td style="text-align:right;"> 0.0086161 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:left;"> 2010-01-07 </td>
   <td style="text-align:right;"> -0.0029534 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:left;"> 2010-01-08 </td>
   <td style="text-align:right;"> 0.0037575 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:left;"> 2010-01-11 </td>
   <td style="text-align:right;"> 0.0074727 </td>
  </tr>
</tbody>
</table>

then we transform the long data to wide data using the *spread* function
and drop the missing data using the *drop_na* function.


```r
log_ret_xts <- log_ret_tidy %>%
  spread(symbol, value = ret) %>%
  tk_xts()
```

```
## Warning: Non-numeric columns being dropped: date
```

```
## Using column `date` for date_var.
```

```r
log_ret_xts=log_ret_xts%>%as.data.frame()%>%drop_na()

summary(log_ret_xts)%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;">      EXI </th>
   <th style="text-align:left;">      IXC </th>
   <th style="text-align:left;">      IXG </th>
   <th style="text-align:left;">      IXJ </th>
   <th style="text-align:left;">      IXN </th>
   <th style="text-align:left;">      IXP </th>
   <th style="text-align:left;">      JXI </th>
   <th style="text-align:left;">      KXI </th>
   <th style="text-align:left;">      MXI </th>
   <th style="text-align:left;">      RXI </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Min.   :-0.1079408 </td>
   <td style="text-align:left;"> Min.   :-2.163e-01 </td>
   <td style="text-align:left;"> Min.   :-0.1415391 </td>
   <td style="text-align:left;"> Min.   :-0.0979635 </td>
   <td style="text-align:left;"> Min.   :-0.1537118 </td>
   <td style="text-align:left;"> Min.   :-0.1025307 </td>
   <td style="text-align:left;"> Min.   :-0.1241903 </td>
   <td style="text-align:left;"> Min.   :-0.0967470 </td>
   <td style="text-align:left;"> Min.   :-0.1191473 </td>
   <td style="text-align:left;"> Min.   :-0.1300503 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1st Qu.:-0.0046489 </td>
   <td style="text-align:left;"> 1st Qu.:-6.889e-03 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0055047 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0040270 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0048440 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0046377 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0044924 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0034824 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0061805 </td>
   <td style="text-align:left;"> 1st Qu.:-0.0044866 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Median : 0.0009071 </td>
   <td style="text-align:left;"> Median : 4.926e-04 </td>
   <td style="text-align:left;"> Median : 0.0008703 </td>
   <td style="text-align:left;"> Median : 0.0008421 </td>
   <td style="text-align:left;"> Median : 0.0012534 </td>
   <td style="text-align:left;"> Median : 0.0006725 </td>
   <td style="text-align:left;"> Median : 0.0007154 </td>
   <td style="text-align:left;"> Median : 0.0005264 </td>
   <td style="text-align:left;"> Median : 0.0003481 </td>
   <td style="text-align:left;"> Median : 0.0009753 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Mean   : 0.0004047 </td>
   <td style="text-align:left;"> Mean   : 4.899e-05 </td>
   <td style="text-align:left;"> Mean   : 0.0002916 </td>
   <td style="text-align:left;"> Mean   : 0.0004754 </td>
   <td style="text-align:left;"> Mean   : 0.0006594 </td>
   <td style="text-align:left;"> Mean   : 0.0003062 </td>
   <td style="text-align:left;"> Mean   : 0.0002286 </td>
   <td style="text-align:left;"> Mean   : 0.0003485 </td>
   <td style="text-align:left;"> Mean   : 0.0001967 </td>
   <td style="text-align:left;"> Mean   : 0.0005240 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0062073 </td>
   <td style="text-align:left;"> 3rd Qu.: 7.699e-03 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0068296 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0056683 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0069806 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0056638 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0055806 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0047739 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0072199 </td>
   <td style="text-align:left;"> 3rd Qu.: 0.0064221 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Max.   : 0.0990035 </td>
   <td style="text-align:left;"> Max.   : 1.597e-01 </td>
   <td style="text-align:left;"> Max.   : 0.1066680 </td>
   <td style="text-align:left;"> Max.   : 0.0668417 </td>
   <td style="text-align:left;"> Max.   : 0.1050387 </td>
   <td style="text-align:left;"> Max.   : 0.0709797 </td>
   <td style="text-align:left;"> Max.   : 0.1014732 </td>
   <td style="text-align:left;"> Max.   : 0.0786298 </td>
   <td style="text-align:left;"> Max.   : 0.1034600 </td>
   <td style="text-align:left;"> Max.   : 0.0961797 </td>
  </tr>
</tbody>
</table>

```r
head(log_ret_xts)%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> EXI </th>
   <th style="text-align:right;"> IXC </th>
   <th style="text-align:right;"> IXG </th>
   <th style="text-align:right;"> IXJ </th>
   <th style="text-align:right;"> IXN </th>
   <th style="text-align:right;"> IXP </th>
   <th style="text-align:right;"> JXI </th>
   <th style="text-align:right;"> KXI </th>
   <th style="text-align:right;"> MXI </th>
   <th style="text-align:right;"> RXI </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2010-01-04 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2010-01-05 </td>
   <td style="text-align:right;"> 0.0017576 </td>
   <td style="text-align:right;"> 0.0054231 </td>
   <td style="text-align:right;"> 0.0123934 </td>
   <td style="text-align:right;"> -0.0089702 </td>
   <td style="text-align:right;"> 0.0017488 </td>
   <td style="text-align:right;"> -0.0019752 </td>
   <td style="text-align:right;"> -0.0024789 </td>
   <td style="text-align:right;"> -0.0106712 </td>
   <td style="text-align:right;"> 0.0021808 </td>
   <td style="text-align:right;"> 0.0022542 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2010-01-06 </td>
   <td style="text-align:right;"> 0.0021924 </td>
   <td style="text-align:right;"> 0.0086161 </td>
   <td style="text-align:right;"> 0.0023331 </td>
   <td style="text-align:right;"> 0.0034450 </td>
   <td style="text-align:right;"> -0.0071896 </td>
   <td style="text-align:right;"> -0.0104807 </td>
   <td style="text-align:right;"> 0.0028915 </td>
   <td style="text-align:right;"> -0.0003517 </td>
   <td style="text-align:right;"> 0.0175849 </td>
   <td style="text-align:right;"> 0.0004501 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2010-01-07 </td>
   <td style="text-align:right;"> 0.0074191 </td>
   <td style="text-align:right;"> -0.0029534 </td>
   <td style="text-align:right;"> 0.0038065 </td>
   <td style="text-align:right;"> -0.0030617 </td>
   <td style="text-align:right;"> -0.0026436 </td>
   <td style="text-align:right;"> -0.0102250 </td>
   <td style="text-align:right;"> -0.0076597 </td>
   <td style="text-align:right;"> -0.0035249 </td>
   <td style="text-align:right;"> -0.0045976 </td>
   <td style="text-align:right;"> 0.0049393 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2010-01-08 </td>
   <td style="text-align:right;"> 0.0121002 </td>
   <td style="text-align:right;"> 0.0037575 </td>
   <td style="text-align:right;"> 0.0084070 </td>
   <td style="text-align:right;"> 0.0049704 </td>
   <td style="text-align:right;"> 0.0080843 </td>
   <td style="text-align:right;"> 0.0012839 </td>
   <td style="text-align:right;"> 0.0051818 </td>
   <td style="text-align:right;"> 0.0001765 </td>
   <td style="text-align:right;"> 0.0100872 </td>
   <td style="text-align:right;"> 0.0080304 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2010-01-11 </td>
   <td style="text-align:right;"> 0.0123799 </td>
   <td style="text-align:right;"> 0.0074727 </td>
   <td style="text-align:right;"> -0.0002095 </td>
   <td style="text-align:right;"> 0.0091116 </td>
   <td style="text-align:right;"> -0.0031557 </td>
   <td style="text-align:right;"> 0.0016483 </td>
   <td style="text-align:right;"> 0.0115111 </td>
   <td style="text-align:right;"> 0.0056329 </td>
   <td style="text-align:right;"> 0.0053080 </td>
   <td style="text-align:right;"> 0.0042126 </td>
  </tr>
</tbody>
</table>

using the long data *colMeans* function provides the mean daily return
for each sector


```r
mean_ret <- colMeans(log_ret_xts,na.rm = T)
print(round(mean_ret, 5))%>%kable()
```

```
##     EXI     IXC     IXG     IXJ     IXN     IXP     JXI     KXI     MXI     RXI 
## 0.00040 0.00005 0.00029 0.00048 0.00066 0.00031 0.00023 0.00035 0.00020 0.00052
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> x </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> EXI </td>
   <td style="text-align:right;"> 0.00040 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:right;"> 0.00005 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXG </td>
   <td style="text-align:right;"> 0.00029 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXJ </td>
   <td style="text-align:right;"> 0.00048 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXN </td>
   <td style="text-align:right;"> 0.00066 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXP </td>
   <td style="text-align:right;"> 0.00031 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JXI </td>
   <td style="text-align:right;"> 0.00023 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KXI </td>
   <td style="text-align:right;"> 0.00035 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MXI </td>
   <td style="text-align:right;"> 0.00020 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RXI </td>
   <td style="text-align:right;"> 0.00052 </td>
  </tr>
</tbody>
</table>

in the same way the daily covariance matrix is formed by the *cov*
function and multiplied by the number of work days per year i.e. 252
days excluding weekends and holidays.


```r
cov_mat <- cov(log_ret_xts) * 252
print(round(cov_mat,4))%>%kable()
```

```
##        EXI    IXC    IXG    IXJ    IXN    IXP    JXI    KXI    MXI    RXI
## EXI 0.0365 0.0397 0.0390 0.0245 0.0322 0.0254 0.0239 0.0202 0.0379 0.0321
## IXC 0.0397 0.0679 0.0468 0.0267 0.0353 0.0296 0.0269 0.0224 0.0465 0.0355
## IXG 0.0390 0.0468 0.0492 0.0275 0.0358 0.0293 0.0273 0.0224 0.0427 0.0359
## IXJ 0.0245 0.0267 0.0275 0.0251 0.0260 0.0205 0.0197 0.0171 0.0263 0.0237
## IXN 0.0322 0.0353 0.0358 0.0260 0.0418 0.0277 0.0227 0.0207 0.0355 0.0327
## IXP 0.0254 0.0296 0.0293 0.0205 0.0277 0.0271 0.0205 0.0175 0.0285 0.0256
## JXI 0.0239 0.0269 0.0273 0.0197 0.0227 0.0205 0.0282 0.0185 0.0258 0.0222
## KXI 0.0202 0.0224 0.0224 0.0171 0.0207 0.0175 0.0185 0.0193 0.0219 0.0193
## MXI 0.0379 0.0465 0.0427 0.0263 0.0355 0.0285 0.0258 0.0219 0.0481 0.0345
## RXI 0.0321 0.0355 0.0359 0.0237 0.0327 0.0256 0.0222 0.0193 0.0345 0.0339
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> EXI </th>
   <th style="text-align:right;"> IXC </th>
   <th style="text-align:right;"> IXG </th>
   <th style="text-align:right;"> IXJ </th>
   <th style="text-align:right;"> IXN </th>
   <th style="text-align:right;"> IXP </th>
   <th style="text-align:right;"> JXI </th>
   <th style="text-align:right;"> KXI </th>
   <th style="text-align:right;"> MXI </th>
   <th style="text-align:right;"> RXI </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> EXI </td>
   <td style="text-align:right;"> 0.0365 </td>
   <td style="text-align:right;"> 0.0397 </td>
   <td style="text-align:right;"> 0.0390 </td>
   <td style="text-align:right;"> 0.0245 </td>
   <td style="text-align:right;"> 0.0322 </td>
   <td style="text-align:right;"> 0.0254 </td>
   <td style="text-align:right;"> 0.0239 </td>
   <td style="text-align:right;"> 0.0202 </td>
   <td style="text-align:right;"> 0.0379 </td>
   <td style="text-align:right;"> 0.0321 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXC </td>
   <td style="text-align:right;"> 0.0397 </td>
   <td style="text-align:right;"> 0.0679 </td>
   <td style="text-align:right;"> 0.0468 </td>
   <td style="text-align:right;"> 0.0267 </td>
   <td style="text-align:right;"> 0.0353 </td>
   <td style="text-align:right;"> 0.0296 </td>
   <td style="text-align:right;"> 0.0269 </td>
   <td style="text-align:right;"> 0.0224 </td>
   <td style="text-align:right;"> 0.0465 </td>
   <td style="text-align:right;"> 0.0355 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXG </td>
   <td style="text-align:right;"> 0.0390 </td>
   <td style="text-align:right;"> 0.0468 </td>
   <td style="text-align:right;"> 0.0492 </td>
   <td style="text-align:right;"> 0.0275 </td>
   <td style="text-align:right;"> 0.0358 </td>
   <td style="text-align:right;"> 0.0293 </td>
   <td style="text-align:right;"> 0.0273 </td>
   <td style="text-align:right;"> 0.0224 </td>
   <td style="text-align:right;"> 0.0427 </td>
   <td style="text-align:right;"> 0.0359 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXJ </td>
   <td style="text-align:right;"> 0.0245 </td>
   <td style="text-align:right;"> 0.0267 </td>
   <td style="text-align:right;"> 0.0275 </td>
   <td style="text-align:right;"> 0.0251 </td>
   <td style="text-align:right;"> 0.0260 </td>
   <td style="text-align:right;"> 0.0205 </td>
   <td style="text-align:right;"> 0.0197 </td>
   <td style="text-align:right;"> 0.0171 </td>
   <td style="text-align:right;"> 0.0263 </td>
   <td style="text-align:right;"> 0.0237 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXN </td>
   <td style="text-align:right;"> 0.0322 </td>
   <td style="text-align:right;"> 0.0353 </td>
   <td style="text-align:right;"> 0.0358 </td>
   <td style="text-align:right;"> 0.0260 </td>
   <td style="text-align:right;"> 0.0418 </td>
   <td style="text-align:right;"> 0.0277 </td>
   <td style="text-align:right;"> 0.0227 </td>
   <td style="text-align:right;"> 0.0207 </td>
   <td style="text-align:right;"> 0.0355 </td>
   <td style="text-align:right;"> 0.0327 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IXP </td>
   <td style="text-align:right;"> 0.0254 </td>
   <td style="text-align:right;"> 0.0296 </td>
   <td style="text-align:right;"> 0.0293 </td>
   <td style="text-align:right;"> 0.0205 </td>
   <td style="text-align:right;"> 0.0277 </td>
   <td style="text-align:right;"> 0.0271 </td>
   <td style="text-align:right;"> 0.0205 </td>
   <td style="text-align:right;"> 0.0175 </td>
   <td style="text-align:right;"> 0.0285 </td>
   <td style="text-align:right;"> 0.0256 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JXI </td>
   <td style="text-align:right;"> 0.0239 </td>
   <td style="text-align:right;"> 0.0269 </td>
   <td style="text-align:right;"> 0.0273 </td>
   <td style="text-align:right;"> 0.0197 </td>
   <td style="text-align:right;"> 0.0227 </td>
   <td style="text-align:right;"> 0.0205 </td>
   <td style="text-align:right;"> 0.0282 </td>
   <td style="text-align:right;"> 0.0185 </td>
   <td style="text-align:right;"> 0.0258 </td>
   <td style="text-align:right;"> 0.0222 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KXI </td>
   <td style="text-align:right;"> 0.0202 </td>
   <td style="text-align:right;"> 0.0224 </td>
   <td style="text-align:right;"> 0.0224 </td>
   <td style="text-align:right;"> 0.0171 </td>
   <td style="text-align:right;"> 0.0207 </td>
   <td style="text-align:right;"> 0.0175 </td>
   <td style="text-align:right;"> 0.0185 </td>
   <td style="text-align:right;"> 0.0193 </td>
   <td style="text-align:right;"> 0.0219 </td>
   <td style="text-align:right;"> 0.0193 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MXI </td>
   <td style="text-align:right;"> 0.0379 </td>
   <td style="text-align:right;"> 0.0465 </td>
   <td style="text-align:right;"> 0.0427 </td>
   <td style="text-align:right;"> 0.0263 </td>
   <td style="text-align:right;"> 0.0355 </td>
   <td style="text-align:right;"> 0.0285 </td>
   <td style="text-align:right;"> 0.0258 </td>
   <td style="text-align:right;"> 0.0219 </td>
   <td style="text-align:right;"> 0.0481 </td>
   <td style="text-align:right;"> 0.0345 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RXI </td>
   <td style="text-align:right;"> 0.0321 </td>
   <td style="text-align:right;"> 0.0355 </td>
   <td style="text-align:right;"> 0.0359 </td>
   <td style="text-align:right;"> 0.0237 </td>
   <td style="text-align:right;"> 0.0327 </td>
   <td style="text-align:right;"> 0.0256 </td>
   <td style="text-align:right;"> 0.0222 </td>
   <td style="text-align:right;"> 0.0193 </td>
   <td style="text-align:right;"> 0.0345 </td>
   <td style="text-align:right;"> 0.0339 </td>
  </tr>
</tbody>
</table>

The *runif* function provides hypothetical weights standardized to sum
up to 1.


```r
wts <- runif(n = length(tick))
wts <- wts/sum(wts)
print(wts)%>%kable()
```

```
##  [1] 0.02181918 0.07788497 0.05416218 0.21472448 0.06099253 0.04694185
##  [7] 0.19240680 0.15534889 0.07119757 0.10452155
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> x </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.0218192 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0778850 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0541622 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.2147245 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0609925 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0469418 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1924068 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1553489 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0711976 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1045216 </td>
  </tr>
</tbody>
</table>

This is the code for computing portfolio returns, risks, and sharp
ratios.


```r
port_returns <- (sum(wts * mean_ret) + 1)^252 - 1


port_risk <- sqrt(t(wts) %*%(cov_mat %*% wts) )
print(port_risk)%>%kable()
```

```
##          [,1]
## [1,] 0.158721
```

<table>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.158721 </td>
  </tr>
</tbody>
</table>

```r
sharpe_ratio <- port_returns/port_risk
print(sharpe_ratio)%>%kable()
```

```
##           [,1]
## [1,] 0.5842914
```

<table>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.5842914 </td>
  </tr>
</tbody>
</table>

This snippet set place holders for 10000 weights, portfolio risks,
returns, and sharp ratios.


```r
num_port <- 10000

# Creating a matrix to store the weights

all_wts <- matrix(nrow = num_port,
                  ncol = length(tick))

# Creating an empty vector to store
# Portfolio returns

port_returns <- vector('numeric', length = num_port)

# Creating an empty vector to store
# Portfolio Standard deviation

port_risk <- vector('numeric', length = num_port)

# Creating an empty vector to store
# Portfolio Sharpe Ratio

sharpe_ratio <- vector('numeric', length = num_port)
```

here is the loop to highlight portfolio returns, risks, and sharp ratios
for different wheight combinations


```r
for (i in seq_along(port_returns)) {
  
  wts <- runif(length(tick))
  wts <- wts/sum(wts)
  
  # Storing weight in the matrix
  all_wts[i,] <- wts
  
  # Portfolio returns
  
  port_ret <- sum(wts * mean_ret)
  port_ret <- ((port_ret + 1)^252) - 1
  
  # Storing Portfolio Returns values
  port_returns[i] <- port_ret
  
  
  # Creating and storing portfolio risk
  port_sd <- sqrt(t(wts) %*% (cov_mat  %*% wts))
  port_risk[i] <- port_sd
  
  # Creating and storing Portfolio Sharpe Ratios
  # Assuming 0% Risk free rate
  
  sr <- port_ret/port_sd
  sharpe_ratio[i] <- sr
  
}
```

here we are making a tibble of portfolio returns, risks, and sharp
ratios


```r
portfolio_values <- tibble(Return = port_returns,
                           Risk = port_risk,
                           SharpeRatio = sharpe_ratio)


# Converting matrix to a tibble and changing column names
all_wts <- tk_tbl(all_wts)
```

```
## Warning in tk_tbl.data.frame(as.data.frame(data), preserve_index,
## rename_index, : Warning: No index to preserve. Object otherwise converted to
## tibble successfully.
```

```r
colnames(all_wts) <- colnames(log_ret_xts)

# Combing all the values together
portfolio_values <- tk_tbl(cbind(all_wts, portfolio_values))
```

```
## Warning in tk_tbl.data.frame(cbind(all_wts, portfolio_values)): Warning: No
## index to preserve. Object otherwise converted to tibble successfully.
```

```r
head(portfolio_values)%>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> EXI </th>
   <th style="text-align:right;"> IXC </th>
   <th style="text-align:right;"> IXG </th>
   <th style="text-align:right;"> IXJ </th>
   <th style="text-align:right;"> IXN </th>
   <th style="text-align:right;"> IXP </th>
   <th style="text-align:right;"> JXI </th>
   <th style="text-align:right;"> KXI </th>
   <th style="text-align:right;"> MXI </th>
   <th style="text-align:right;"> RXI </th>
   <th style="text-align:right;"> Return </th>
   <th style="text-align:right;"> Risk </th>
   <th style="text-align:right;"> SharpeRatio </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.0015059 </td>
   <td style="text-align:right;"> 0.1415284 </td>
   <td style="text-align:right;"> 0.1188994 </td>
   <td style="text-align:right;"> 0.1288394 </td>
   <td style="text-align:right;"> 0.0145800 </td>
   <td style="text-align:right;"> 0.1913636 </td>
   <td style="text-align:right;"> 0.1803470 </td>
   <td style="text-align:right;"> 0.0978158 </td>
   <td style="text-align:right;"> 0.0370134 </td>
   <td style="text-align:right;"> 0.0881072 </td>
   <td style="text-align:right;"> 0.0786358 </td>
   <td style="text-align:right;"> 0.1649985 </td>
   <td style="text-align:right;"> 0.4765849 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1486655 </td>
   <td style="text-align:right;"> 0.0318730 </td>
   <td style="text-align:right;"> 0.0683066 </td>
   <td style="text-align:right;"> 0.0787044 </td>
   <td style="text-align:right;"> 0.1056284 </td>
   <td style="text-align:right;"> 0.0336204 </td>
   <td style="text-align:right;"> 0.1851120 </td>
   <td style="text-align:right;"> 0.1775181 </td>
   <td style="text-align:right;"> 0.0860809 </td>
   <td style="text-align:right;"> 0.0844906 </td>
   <td style="text-align:right;"> 0.0961518 </td>
   <td style="text-align:right;"> 0.1626657 </td>
   <td style="text-align:right;"> 0.5911005 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0671929 </td>
   <td style="text-align:right;"> 0.1721032 </td>
   <td style="text-align:right;"> 0.0626337 </td>
   <td style="text-align:right;"> 0.0954884 </td>
   <td style="text-align:right;"> 0.1794551 </td>
   <td style="text-align:right;"> 0.0124373 </td>
   <td style="text-align:right;"> 0.0973874 </td>
   <td style="text-align:right;"> 0.1729593 </td>
   <td style="text-align:right;"> 0.0886350 </td>
   <td style="text-align:right;"> 0.0517077 </td>
   <td style="text-align:right;"> 0.0917700 </td>
   <td style="text-align:right;"> 0.1720987 </td>
   <td style="text-align:right;"> 0.5332403 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1399838 </td>
   <td style="text-align:right;"> 0.0752763 </td>
   <td style="text-align:right;"> 0.0430130 </td>
   <td style="text-align:right;"> 0.0601343 </td>
   <td style="text-align:right;"> 0.0910031 </td>
   <td style="text-align:right;"> 0.1037290 </td>
   <td style="text-align:right;"> 0.1257542 </td>
   <td style="text-align:right;"> 0.0925847 </td>
   <td style="text-align:right;"> 0.1396637 </td>
   <td style="text-align:right;"> 0.1288578 </td>
   <td style="text-align:right;"> 0.0919778 </td>
   <td style="text-align:right;"> 0.1701907 </td>
   <td style="text-align:right;"> 0.5404394 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1707087 </td>
   <td style="text-align:right;"> 0.0214482 </td>
   <td style="text-align:right;"> 0.0324814 </td>
   <td style="text-align:right;"> 0.1145488 </td>
   <td style="text-align:right;"> 0.1880701 </td>
   <td style="text-align:right;"> 0.0873300 </td>
   <td style="text-align:right;"> 0.0122085 </td>
   <td style="text-align:right;"> 0.0890225 </td>
   <td style="text-align:right;"> 0.1952464 </td>
   <td style="text-align:right;"> 0.0889353 </td>
   <td style="text-align:right;"> 0.1070422 </td>
   <td style="text-align:right;"> 0.1738556 </td>
   <td style="text-align:right;"> 0.6156959 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.1134023 </td>
   <td style="text-align:right;"> 0.0345157 </td>
   <td style="text-align:right;"> 0.1007384 </td>
   <td style="text-align:right;"> 0.0136946 </td>
   <td style="text-align:right;"> 0.1229113 </td>
   <td style="text-align:right;"> 0.1539289 </td>
   <td style="text-align:right;"> 0.0585701 </td>
   <td style="text-align:right;"> 0.1751657 </td>
   <td style="text-align:right;"> 0.1650301 </td>
   <td style="text-align:right;"> 0.0620429 </td>
   <td style="text-align:right;"> 0.0924751 </td>
   <td style="text-align:right;"> 0.1694699 </td>
   <td style="text-align:right;"> 0.5456725 </td>
  </tr>
</tbody>
</table>

Minimum variance portfolio weights and Tangency portfolio weights with
the highest sharp ratio!


```r
min_var <- portfolio_values[which.min(portfolio_values$Risk),]
max_sr <- portfolio_values[which.max(portfolio_values$SharpeRatio),]
```

Minimum variance portfolio weights visualization is presented here


```r
p <- min_var %>%
  gather(EXI:RXI, key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') +
  theme_minimal() +
  labs(x = 'Assets', y = 'Weights', title = "Minimum Variance Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 

p
```

![](PortfolioOptimization_files/figure-html/portop1-1.png)<!-- -->

Tangency portfolio weights with the highest sharp ratio visualization is
presented here


```r
p <- max_sr %>%
  gather(EXI:RXI, key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') +
  theme_minimal() +
  labs(x = 'Assets', y = 'Weights', title = "Tangency Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 

p
```

![](PortfolioOptimization_files/figure-html/portop2-1.png)<!-- -->

and the risk/performance axis for all weights is presented here


```r
p <- portfolio_values %>%
  ggplot(aes(x = Risk, y = Return, color = SharpeRatio)) +
  geom_point() +
  theme_classic() +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = scales::percent) +
  labs(x = 'Annualized Risk',
       y = 'Annualized Returns',
       title = "Portfolio Optimization & Efficient Frontier") +
  geom_point(aes(x = Risk,
                 y = Return), data = min_var, color = 'red') +
  geom_point(aes(x = Risk,
                 y = Return), data = max_sr, color = 'red')
p
```

![](PortfolioOptimization_files/figure-html/portop3-1.png)<!-- -->

## References

-   [Sectors](https://seekingalpha.com/etfs-and-funds/etf-tables/sectors?utm_source=google&utm_medium=cpc&utm_campaign=14049528666&utm_term=127926794296%5Eaud-1457157706959:dsa-1427142718946%5Eb%5E547566878395%5E%5E%5Eg&gclid=Cj0KCQjw5oiMBhDtARIsAJi0qk2LjR58Nfps9hx7OgGrL_XmycmlH96YxiapMt-b5as3aFIQfQ5ggoIaAlOwEALw_wcB)

-   [Betas](https://pages.stern.nyu.edu/~adamodar/New_Home_Page/datafile/Betas.html)
