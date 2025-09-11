
### What is Optuna?

**Optuna** is an efficient automatic hyperparameter tuning frameworks try to circumvent the existing optimization frameworks that overlook some critical issues. Firstly, the more traditional frameworks typically require users to statically define the parameter-search space for each model, which can be challenging for large-scale experiments with diverse candidate models and complex parameter spaces. Secondly, many lack efficient pruning strategies, essential for high-performance optimization under limited resources. Lastly, frameworks should be versatile enough to handle experiments of varying scales and be easy to set up and use, preferably with a single command. Open-source architecture is also crucial for continuous integration of new optimization methods from the community. To address these concerns, a new set of design criteria is proposed follows:

1. Define-by-run programming for dynamic search space construction.
2. Efficient sampling and pruning algorithms with user-customization capabilities.
3. Easy-to-setup, versatile architecture suitable for various tasks, from lightweight experiments to distributed computations.

**Optuna** is an open-source optimization software that introduces optimization algorithms to meet these criteria. Optuna employs a technique called Sequential Model-Based Optimization (SMBO), specifically using the Tree-structured Parzen Estimator (TPE) algorithm. The TPE algorithm models the relationship between hyperparameters and the objective metric (such as accuracy or loss) using a probabilistic model. It then guides the search process by iteratively sampling hyperparameter configurations that are likely to improve the objective metric based on the model. The algorithm works by iteratively building a probabilistic model of the objective function (here it is the model perfomance) and using it to select the most promising hyperparameters to evaluate in the actual objective function. The TPE algorithm starts with an initial belief about the objective function and updates this belief as it observes the results of different trials. This approach allows Optuna to efficiently narrow down the search space and focus on regions that are likely to yield better performance, thus optimizing the hyperparameters more effectively than random or grid search methods. TPE operates by iteratively gathering observations and, at the end of each iteration, determining the next set of hyperparameters to evaluate. The process begins by establishing a prior distribution for the hyperparameters, which are typically uniformly distributed but can be associated with any random unimodal distribution.


### Tree-structured Parzen Estimator algorithm

The TPE algorithm effectively balances exploration and exploitation by using the probabilistic models to identify promising areas of the hyperparameter space while also considering the uncertainty in the observations. It is particularly well-suited for optimizing expensive-to-evaluate functions, such as those encountered in machine learning model training, and when the objective function is expensive to evaluate and when the hyperparameter space is high-dimensional. The TPE algorithm starts with a warm-up phase, which involves collecting preliminary data. This is typically achieved through a few iterations of Random Search, with the number of iterations being a user-defined parameter within the TPE algorithm. Once sufficient data is collected, TPE divides the observations (i.e. candidate hyperparameter values) into two groups: one containing the observations with the best perfomance scores and the other comprising all remaining observations. The objective is to identify a set of hyperparameters that are more likely to fall within the first group and less likely to be in the second. The proportion of top observations used to define this "best" group is another parameter set by the user, usually ranging from 10% to 25% of all observations. Unlike methods that focus on the best single observation, TPE utilizes the distribution of the best observations. The more iterations conducted during the Random Search phase, the more refined the initial distribution will be. TPE then models the likelihood probability for each group, which is a departure from the Gaussian Process approach that models the posterior probability. Using the likelihood probability from the group of best observations, TPE samples a set of candidate hyperparameters. The goal is to find a candidate that is more likely to be associated with the first group and less likely with the second. This is achieved by defining a Gaussian distribution for each sample, characterized by a mean (the value of the hyperparameter) and a standard deviation.  Despite its advantages, TPE has its drawbacks. One significant limitation is that it selects parameters independently, without considering potential interactions between them. For instance, there is a known relationship between regularization and the number of training epochs; more epochs can be beneficial with regularization but may lead to overfitting without it. TPE's independent parameter selection may appear arbitrary if it does not account for such relationships. Below is the outline of the algorithm:

1. **Initialization**: The algorithm starts with an empty set `D` of observed hyperparameter configurations and their corresponding objective function (i.e. perfomance) values.

2. **Initial Random Sampling**:
   - For a predefined number of initial configurations (`N_init`, referred to as `n_startup_trials` in Optuna), the algorithm randomly selects hyperparameter configurations (` x_n`).
   - It then evaluates the objective function ` f(x_n) ` for each configuration, adding a small noise `epsilon_n` to account for stochasticity, and stores the results in the set `D`.

3. **Main Optimization Loop**: The algorithm enters a loop that continues as long as the computational budget allows or the results converge.

4. **Quantile Computation**:
   - The algorithm computes a quantile `gamma` based on the number of observations ` N ` in ` D `. This quantile is used to split the observed data (i.e. perforamnce) into two groups: one with the best (top `gamma`) objective function values and the other with the rest.

5. **Data Splitting**:
   - The set `D` is split into `D(l)` containing the best observations and `D(g)` containing the rest.

6. **Weight Computation**:
   - Weights `w_n` are computed for the observations based on the distribution of the observed data (i.e. perforamnce).

7. **Bandwidth Selection**:
   - Bandwidths ` b(l) ` and ` b(g) ` are computed using a function ` B ` for both ` D(l) ` and ` D(g) `.

8. **Model Building**:
   - Probabilistic models ` p(x|D(l)) ` and ` p(x|D(g)) ` are built for the likelihood of observing a hyperparameter configuration given the best and the rest of the data, respectively.

9. **Sampling Candidates**:
   - A set of candidate hyperparameter configurations ` S ` is sampled from the model ` p(x|D(l)) `.

10. **Acquisition Function Optimization**:
    - The algorithm selects the next hyperparameter configuration ` x_{N+1} ` from the candidates by maximizing the acquisition function ` r(x|D) `, which is typically the ratio of the likelihoods ` p(x|D(l)) ` to ` p(x|D(g)) `.

11. **Objective Function Evaluation**:
    - The objective function is evaluated at the selected hyperparameter configuration ` x_N+1 `, and the result ` y_N+1 ` is added to the set ` D `.

12. **Iteration**:
    - The algorithm iterates, updating the set ` D ` with the new observations and repeating the process until the computational budget is exhausted.


As mentioned above, Optuna/TPE are effective frameworks for hyperparameter tuning due to their ability to efficiently navigate the hyperparameter space using probabilistic models, which focus the search on promising hyperparameter configurations and significantly reduce the number of evaluations required compared to traditional methods like grid search and random search, while being highly adaptable by dynamically updating the search distribution to balance exploration and exploitation. Furthermore, Optuna is framework-agnostic, allowing it to work with most Python-based frameworks and cover a broad range of use cases beyond machine learning, such as acceleration or database tuning, while also supporting asynchronous distributed optimization for parallelization to accelerate the optimization process. In the context of synthetic data generation, the hyperparameter tuning of several of the algorithms implementated in our package Clover based on the functionalities provided by Optuna. 


#### References

-  [Optuna](https://optuna.org) 
-  [Github Optuna](https://github.com/optuna/optuna) 
-  [Github Optuna TPE](https://github.com/optuna/optuna/blob/master/optuna/samplers/_tpe/sampler.py)
-  [Optuna: An Automatic Hyperparameter Optimization Framework](https://odsc.com/blog/optuna-an-automatic-hyperparameter-optimization-framework/)
-  [Algorithms for Hyper-Parameter Optimization](https://proceedings.neurips.cc/paper_files/paper/2011/file/86e8f7ab32cfd12577bc2619bc635690-Paper.pdf)
-  [Hyperparameter optimization for Neural Networks](http://neupy.com/2016/12/17/hyperparameter_optimization_for_neural_networks.html#tree-structured-parzen-estimators-tpe)



-  https://optuna.readthedocs.io/en/stable/
-  https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.optimize
-  https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html#optuna.samplers.TPESampler
-  https://optuna.readthedocs.io/en/stable/tutorial/10_key_features/003_efficient_optimization_algorithms.html
-  https://towardsdatascience.com/building-a-tree-structured-parzen-estimator-from-scratch-kind-of-20ed31770478
-  https://optunity.readthedocs.io/en/latest/user/solvers/TPE.html
-  https://towardsdatascience.com/a-conceptual-explanation-of-bayesian-model-based-hyperparameter-optimization-for-machine-learning-b8172278050f
-  https://neptune.ai/blog/hyperparameter-tuning-in-python-complete-guide
-  https://github.com/nabenabe0928/tpe
-   https://arxiv.org/abs/2304.11127
-   https://openreview.net/pdf?id=YDepgWDUDXx
-   https://www.avient.com/sites/default/files/2020-10/tpe-overmold-design-guide.pdf
-   http://auai.org/uai2017/proceedings/papers/50.pdf
-   https://theroundup.org/is-tpe-eco-friendly/
-  http://www.real-seal.com/blog/rubber-vs-tpe-which-is-the-better-choice/
-   https://www.avient.com/products/thermoplastic-elastomers/tpe-knowledge-center/beginners-guide
-   https://dl.acm.org/doi/pdf/10.1145/3449639.3459370
-   https://towardsdatascience.com/bayesian-optimization-concept-explained-in-layman-terms-1d2bcdeaf12f
