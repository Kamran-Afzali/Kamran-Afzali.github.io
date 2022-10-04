AutoML or Automated Machine Learning is a machine learning method that automates the training, tuning, and deploying machine learning models. AutoML can be used to automatically discover the best model for a given dataset and task without any human intervention.

AutoML is an important tool for making machine learning accessible to non-experts, as it can automate the process of training and deploying machine learning models. This can save time and resources and accelerate research on machine learning.

There are a number of different ways to approach AutoML, depending on the specific problem that needs to be solved. For example, some methods focus on optimizing a model for a given dataset, while others focus on finding the best model for a given task.

No matter what approach is taken, AutoML can be a powerful tool for making machine learning more accessible and efficient. In the future, we can expect to see more and more use of AutoML in both industry and research.


This post aims to introduce you to some of the top AutoML Tools and Platforms. These tools/platforms may serve as your most satisfactory source for the AutoML functions. Please note this is not a ranking article

Here are some of the important and most used AutoML Tools for 2022:

Auto-SKLearn

It is a mechanized machine-learning programming package called Auto-SKLearn, which is based on scikit-learn. An AI client has been released from hyper-boundary tuning and computation choice thanks to auto-SKLearn. It features standout design strategies like automated normalization and One-Hot. The concept uses SKLearn assessors to address relapsing and grouping concerns.

While Auto-SKLearn can produce the current deep learning frameworks, which need excellent performances in massive datasets, it can’t do so well with small and medium datasets.

H2OAutoML

By creating user-friendly machine learning software, H2OAutoML meets the demand for machine learning specialists. This AutoML tool aims to provide straightforward and consistent user interfaces for various machine learning algorithms while streamlining machine learning. Machine learning models are automatically trained and tuned within a user-specified time frame.


The lares package has multiple families of functions to help the analyst or data scientist achieve quality robust analysis without the need of much coding. One of the most complex but valuable functions we have is h2o_automl, which semi-automatically runs the whole pipeline of a Machine Learning model given a dataset and some customizable parameters. AutoML enables you to train high-quality models specific to your needs and accelerate the research and development process.

HELP: Before getting to the code, I recommend checking h2o_automl's full documentation here or within your R session by running ?lares::h2o_automl. In it you'll find a brief description of all the parameters you can set into the function to get exactly what you need and control how it behaves.

Model #2 - h2o AutoML
The next candidate will be h2o’s AutoML function. h2O is an open-source machine learning platform that runs in java and has interfaces with R amongst others. The AutoML feature will auto-magically try different models and eventually construct a leaderboard of the best models. For this section, the blog post from Riley King was an inspiration as AutoML was used to compare against data from the Sliced data science competition.

In order to start using h2o I must first initialize the engine:

h2O also has its own data format which must used. Fortunately its easy to convert between the tibbles and this format with as.h2o:

Due to how h2o is set up, I’ll need to specific the name of the dependent variable (y) as a string and provide the list of predictors as a vector of strings (x). This is most easily done prior to the function call using setdiff() to remove the dependent from the other variables.

https://datascienceplus.com/real-plug-and-play-supervised-learning-automl-using-r-and-lares/

https://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html

https://www.r-bloggers.com/2020/04/automl-frameworks-in-r-python/

https://rdrr.io/github/MrDomani/autofeat/man/SAFE.html

https://jlaw.netlify.app/2022/05/03/ml-for-the-lazy-can-automl-beat-my-model/
