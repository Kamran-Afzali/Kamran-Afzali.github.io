Hyperparameter search poses a significant challenge in machine learning endeavors, particularly as the complexity of deep learning methods continues to rise alongside their popularity. Consequently, there's an increasing demand for efficient automatic hyperparameter tuning frameworks. Several optimization software solutions, including Hyperopt, Spearmint, SMAC, Autotune, and Vizier, have been developed to address this need.

These frameworks vary in their choice of parameter-sampling algorithms. For instance, Spearmint and GPyOpt utilize Gaussian Processes, while Hyperopt employs the tree-structured Parzen estimator (TPE). SMAC, introduced by Hutter et al., relies on random forests. More recent frameworks such as Google Vizier, Katib, and Tune support pruning algorithms, which terminate unpromising trials prematurely to expedite exploration. The field of hyperparameter optimization also sees ongoing research into pruning algorithms, with methods proposed by Domhan et al., Klein et al., and Li et al.

Another strategy to accelerate optimization involves distributed computing, enabling parallel processing of multiple trials. Katib, built on Kubeflow, and Tune, utilizing the Ray distributed computing platform, both support parallel optimization.

Despite these advancements, existing optimization frameworks overlook several critical issues. Firstly, they typically require users to statically define the parameter-search space for each model, which can be challenging for large-scale experiments with diverse candidate models and complex parameter spaces. Secondly, many lack efficient pruning strategies, essential for high-performance optimization under limited resources. Lastly, frameworks should be versatile enough to handle experiments of varying scales and be easy to set up and use, preferably with a single command. Open-source architecture is also crucial for continuous integration of new optimization methods from the community.

To address these concerns, a new set of design criteria for next-generation optimization frameworks is proposed:
1. Define-by-run programming for dynamic search space construction.
2. Efficient sampling and pruning algorithms with user-customization capabilities.
3. Easy-to-setup, versatile architecture suitable for various tasks, from lightweight experiments to distributed computations.

Optuna, an open-source optimization software, embodies these criteria and represents a culmination of efforts towards a next-generation optimization framework. It introduces new design techniques and optimization algorithms to meet these criteria, outperforming many existing black-box optimization frameworks in usability and performance. Experimental results in real-world applications and benchmark datasets will further demonstrate the significance of these criteria and the effectiveness of Optuna's approach.

Optuna is an open-source hyperparameter optimization framework primarily used for machine learning models. It provides a flexible and efficient platform for automating the process of tuning the hyperparameters of machine learning algorithms.

Optuna employs a technique called Sequential Model-Based Optimization (SMBO), specifically using the Tree-structured Parzen Estimator (TPE) algorithm. The TPE algorithm models the relationship between hyperparameters and the objective metric (such as accuracy or loss) using a probabilistic model. It then guides the search process by iteratively sampling hyperparameter configurations that are likely to improve the objective metric based on the model.

Optuna's approach is advantageous because it adapts its search strategy over time based on the observed performance of past trials, allowing it to efficiently explore the hyperparameter space and find optimal configurations even in high-dimensional settings.



Optuna employs a Bayesian optimization algorithm known as the Tree-structured Parzen Estimator (TPE) as its default sampler for hyperparameter optimization[1][2][4]. This algorithm works by iteratively building a probabilistic model of the objective function and using it to select the most promising hyperparameters to evaluate in the actual objective function. The TPE algorithm starts with an initial belief about the objective function and updates this belief as it observes the results of different trials. This approach allows Optuna to efficiently narrow down the search space and focus on regions that are likely to yield better performance, thus optimizing the hyperparameters more effectively than random or grid search methods[1][2][3][4].

Tree-structured Parzen Estimators (TPE) represent an advanced approach to hyperparameter optimization, addressing some limitations inherent in Gaussian Process-based methods. TPE operates by iteratively gathering observations and, at the end of each iteration, determining the next set of hyperparameters to evaluate. The process begins by establishing a prior distribution for the hyperparameters, which are typically uniformly distributed but can be associated with any random unimodal distribution.

To initiate the TPE algorithm, a warm-up phase is required, which involves collecting preliminary data. This is typically achieved through a few iterations of Random Search, with the number of iterations being a user-defined parameter within the TPE algorithm.

Once sufficient data is collected, TPE proceeds to divide the observations into two groups: one containing the observations with the best evaluation scores and the other comprising all remaining observations. The objective is to identify a set of hyperparameters that are more likely to fall within the first group and less likely to be in the second. The proportion of top observations used to define this "best" group is another parameter set by the user, usually ranging from 10% to 25% of all observations.

Unlike methods that focus on the best single observation, TPE utilizes the distribution of the best observations. The more iterations conducted during the Random Search phase, the more refined the initial distribution will be.

TPE then models the likelihood probability for each group, which is a departure from the Gaussian Process approach that models the posterior probability. Using the likelihood probability from the group of best observations, TPE samples a set of candidate hyperparameters. The goal is to find a candidate that is more likely to be associated with the first group and less likely with the second. This is achieved by defining a Gaussian distribution for each sample, characterized by a mean (the value of the hyperparameter) and a standard deviation. These distributions are then stacked and normalized to form a Probability Density Function (PDF), hence the inclusion of "Parzen estimators" in the algorithm's name.

The "tree-structured" aspect of TPE refers to the hierarchical nature of the hyperparameter space. For example, when deciding on the number of layers in a neural network, the algorithm may need to determine whether to use one or two hidden layers. If two layers are chosen, the number of units in each layer is defined independently. However, if only one layer is chosen, there is no need to define units for a second layer, as it does not exist in that parameter configuration. This illustrates the tree-structured dependencies between parameters.

Despite its advantages, TPE has its drawbacks. One significant limitation is that it selects parameters independently, without considering potential interactions between them. For instance, there is a known relationship between regularization and the number of training epochs; more epochs can be beneficial with regularization but may lead to overfitting without it. TPE's independent parameter selection may appear arbitrary if it does not account for such relationships.

To address this, users can define different epoch ranges based on whether regularization is enabled or not. For example, with regularization, the number of epochs might range from 500 to 1000, while without regularization, it might range from 10 to 200. This allows for a more nuanced approach that takes into account the interplay between related variables.



#### References


-  https://pub.aimind.so/a-deep-dive-in-optunas-advance-features-2e495e71435c?gi=5209dbf9b47c
-  https://optuna.readthedocs.io/en/stable/tutorial/10_key_features/003_efficient_optimization_algorithms.html
-  https://towardsdatascience.com/state-of-the-art-machine-learning-hyperparameter-optimization-with-optuna-a315d8564de1
-  https://odsc.com/blog/optuna-an-automatic-hyperparameter-optimization-framework/
-  https://towardsdatascience.com/optuna-a-flexible-efficient-and-scalable-hyperparameter-optimization-framework-d26bc7a23fff
-  https://optuna.org
-  https://optuna.readthedocs.io/en/stable/
-  https://github.com/optuna/optuna 
-  https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.optimize
-  https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html#optuna.samplers.TPESampler
-  https://proceedings.neurips.cc/paper_files/paper/2011/file/86e8f7ab32cfd12577bc2619bc635690-Paper.pdf
-  http://neupy.com/2016/12/17/hyperparameter_optimization_for_neural_networks.html#tree-structured-parzen-estimators-tpe




-  https://towardsdatascience.com/building-a-tree-structured-parzen-estimator-from-scratch-kind-of-20ed31770478
-  https://optunity.readthedocs.io/en/latest/user/solvers/TPE.html
-  https://towardsdatascience.com/a-conceptual-explanation-of-bayesian-model-based-hyperparameter-optimization-for-machine-learning-b8172278050f
-  https://ekamperi.github.io/mathematics/2021/03/30/gaussian-process-regression.html
-  https://neptune.ai/blog/hyperparameter-tuning-in-python-complete-guide
-  https://stats.stackexchange.com/questions/246655/limitation-of-gaussian-process-regression
-  https://hongjusilicone.com/tpe-rubber-guide/
-  https://github.com/nabenabe0928/tpe
-   https://www.immould.com/tpe-molding/
-   https://arxiv.org/abs/2304.11127
-   https://openreview.net/pdf?id=YDepgWDUDXx
-   https://www.avient.com/sites/default/files/2020-10/tpe-overmold-design-guide.pdf
-   http://auai.org/uai2017/proceedings/papers/50.pdf
-   https://theroundup.org/is-tpe-eco-friendly/
-  http://www.real-seal.com/blog/rubber-vs-tpe-which-is-the-better-choice/
-   https://www.avient.com/products/thermoplastic-elastomers/tpe-knowledge-center/beginners-guide
-   https://dl.acm.org/doi/pdf/10.1145/3449639.3459370
-   https://towardsdatascience.com/bayesian-optimization-concept-explained-in-layman-terms-1d2bcdeaf12f
