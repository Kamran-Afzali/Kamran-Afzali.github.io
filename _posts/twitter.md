## Twitter Analysis with R

Twitter APIs are one of the easily available and retrievable sources of user-generated language data that provides the opportunity to gain insights into the online public behaviour of a given person or around a given subject of matter. Hence, getting access and analysing Twitter has become a crucial source of information for both scientific and business investigations. Twitter has considerable advantages over other social media platforms for analysis of the text data because of the large number of tweets published every day that allows access to large data samples as well as the size of the tweets leading to a relatively homogeneous corpus. However, extracting the insights still requires coding, this article provides a simple guide on how to extract and analyse tweets with the R programming software.

## Step 1: 

Load the required packages (including rtweet) in RStudio

## Step 2: 

Authenticate using your credentials to Twitter’s API by creating an access token. In order to get started, you first need to get a Twitter API that allows you to retrieve the tweets. To get a Twitter API you have to use your Twitter account and apply for a developer account via the website [here]( https://developer.twitter.com/en/apply-for-access.html). There is an application form to be accepted by Twitter. Once accepted, you’ll receive the following credentials that you need to keep safe:

+ Consumer key:#######################
+ Consumer Secret:#######################
+ Access Token:#######################
+ Access Secret:#######################

## Step 3: 

Search tweets on the topic of your choice; narrow the number of tweets as you see fit and decide on whether or not to include retweets. I decided to include 100 tweets each for Canada and Scotland, plus decided not to include retweets, so as to avoid duplicate tweets impacting the evaluation. You can do the same analysis with the hashtags. In this case, you’ll want to use the hashtags variable from the rtweet package.

## Step 4: 

Process each set of tweets into tidy text or corpus objects. 
Use pre-processing text transformations to clean up the tweets; this includes stemming words. An example of stemming is rolling the words “computer”, “computational” and “computation” to the root “comput”.
Additional pre-processing involves converting all words to lower-case, removing links to web pages (http elements), and deleting punctuation as well as stop words. The tidytext package contains a list of over 1,000 stop words in the English language that are not helpful in determining the overall sentiment of a text body; these are words such as “I”, “ myself”, “ themselves”, “being” and “have”. We are using the tidytext package with an anti-join to remove the stop words from the tweets that were extracted in step 3.


## Step 5: 

. A nice way to visualise these is using a word cloud as shown below.

## Step 6: 
Bigram analysis:
Rather than looking at individual words we can look at what words tend to co-occur. We want to use the data set where we’ve corrected the spelling so this is going to require us to transform from long to wide and then back to long because the night is dark and full of terror. DID YOU SEE WHAT I DID THERE.

## Step 7: 

Sentiment analysis There are many libraries, dictionaries and packages available in R to evaluate the emotion prevalent in a text. The tidytext and textdata packages have such word-to-emotion evaluation repositories. Three of the general purpose lexicons are Bing, AFINN and nrc (from the textdata package).
To take a look at what each package contains, you can run the following commands in R:

The get_sentiments function returns a tibble, so to take a look at what is included as “positive” and “negative” sentiment, you will need to filter accordingly. Since I wanted a general glimpse, I didn’t need to extract the entire dataset, however depending on your needs, you may want to do so.

In contrast to Bing, the AFINN lexicon assigns a “positive” or “negative” score to each word in its lexicon; further sentiment analysis will then add up the emotion score to determine overall expression. A score greater than zero indicates positive sentiment, while a score less than zero would mean negative overall emotion. A calculated score of zero indicates neutral sentiment (neither positive or negative).

## References

+ [Twitter Sentiment Analysis and Visualization using R](https://towardsdatascience.com/twitter-sentiment-analysis-and-visualization-using-r-22e1f70f6967)

+ [Twitter Data in R Using Rtweet: Analyze and Download Twitter Data](https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/use-twitter-api-r/)

+ [A Guide to Mining and Analysing Tweets with R](https://towardsdatascience.com/a-guide-to-mining-and-analysing-tweets-with-r-2f56818fdd16)

+ [Collecting and Analyzing Twitter Data](https://mkearney.github.io/nicar_tworkshop/#47)

