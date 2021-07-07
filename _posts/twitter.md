Twitter provides us with vast amounts of user-generated language data — a dream for anyone wanting to conduct textual analysis. More than that, tweets allow us to gain insights into the online public behaviour. As such, analysing Twitter has become a crucial source of information for brands and agencies.
Several factors have given Twitter considerable advantages over other social media platforms for analysis. First, the limited character size of tweets provides us with a relatively homogeneous corpora. Second, the millions of tweets published everyday allows access to large data samples. Third, the tweets are publicly available and easily accessible as well as retrievable via APIs.
Nonetheless, extracting these insights still requires a bit of coding and programming knowledge. This is why, most often, brands and agencies rely on easy-to-use analytics tools such as SproutSocial and Talkwalker who provide these insights at a cost in just one click.
In this article, I help you to break down these barriers and provide you with a simple guide on how to extract and analyse tweets with the programming software R.

Step 1: Load the required packages (including rtweet) in RStudio

Step 2: Authenticate using your credentials to Twitter’s API by creating an access token. Steps on getting Twitter access tokens:

STEP 1: Getting your Twitter API access
In order to get started, you first need to get a Twitter API. This will allow you to retrieve the tweets — without it, you cannot do anything. Getting a Twitter API is easy. First make sure you have a Twitter account, otherwise create one. Then, apply for a developer account via the following website: https://developer.twitter.com/en/apply-for-access.html. You’ll need to fill in an application form, which includes explaining a little a bit more what you wish you analyse.
Once you application has been accepted by Twitter (which doesn’t take too long), you’ll receive the following credentials that you need to keep safe:
Consumer key
Consumer Secret
Access Token
Access Secret

Step 3: Search tweets on the topic of your choice; narrow the number of tweets as you see fit and decide on whether or not to include retweets. I decided to include 100 tweets each for Canada and Scotland, plus decided not to include retweets, so as to avoid duplicate tweets impacting the evaluation.


Step 4: Process each set of tweets into tidy text or corpus objects.

Step 5: Use pre-processing text transformations to clean up the tweets; this includes stemming words. An example of stemming is rolling the words “computer”, “computational” and “computation” to the root “comput”.
Additional pre-processing involves converting all words to lower-case, removing links to web pages (http elements), and deleting punctuation as well as stop words. The tidytext package contains a list of over 1,000 stop words in the English language that are not helpful in determining the overall sentiment of a text body; these are words such as “I”, “ myself”, “ themselves”, “being” and “have”. We are using the tidytext package with an anti-join to remove the stop words from the tweets that were extracted in step 3.

6. SHOW THE MOST FREQUENTLY USED HASHTAGS
You can do the same analysis with the hashtags. In this case, you’ll want to use the hashtags variable from the rtweet package. A nice way to visualise these is using a word cloud as shown below.

Step 7: Perform sentiment analysis using the Bing lexicon and get_sentiments function from the tidytext package. There are many libraries, dictionaries and packages available in R to evaluate the emotion prevalent in a text. The tidytext and textdata packages have such word-to-emotion evaluation repositories. Three of the general purpose lexicons are Bing, AFINN and nrc (from the textdata package).
To take a look at what each package contains, you can run the following commands in R:

The get_sentiments function returns a tibble, so to take a look at what is included as “positive” and “negative” sentiment, you will need to filter accordingly. Since I wanted a general glimpse, I didn’t need to extract the entire dataset, however depending on your needs, you may want to do so.

In contrast to Bing, the AFINN lexicon assigns a “positive” or “negative” score to each word in its lexicon; further sentiment analysis will then add up the emotion score to determine overall expression. A score greater than zero indicates positive sentiment, while a score less than zero would mean negative overall emotion. A calculated score of zero indicates neutral sentiment (neither positive or negative).

https://towardsdatascience.com/twitter-sentiment-analysis-and-visualization-using-r-22e1f70f6967

https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/use-twitter-api-r/

https://towardsdatascience.com/a-guide-to-mining-and-analysing-tweets-with-r-2f56818fdd16

https://mkearney.github.io/nicar_tworkshop/#47

