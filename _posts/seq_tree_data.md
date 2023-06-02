
## Literature
### Synthesizing Data for Enhanced Utility and Confidentiality: Harnessing the Power of Sequential Decision Trees

In the realm of data synthesis, the necessity of generating synthetic data has become increasingly apparent due to confidentiality constraints that limit access to valuable microdata. Addressing this need, the "Bespoke Creation of Synthetic Data in R" paper introduces the synthpop package for R. This comprehensive tool empowers researchers to generate synthetic versions of original datasets, mimicking the observed data while preserving essential variable relationships. By eliminating disclosive records, synthpop provides a safeguarded alternative for data sharing.

To explore the efficacy of synthetic data synthesis, the paper "Utility of synthetic microdata generated using tree-based methods" evaluates the utility of synthetic data produced through the implementation of tree-based methods in synthpop 1.2-1 software. By employing classification and regression trees (CART) and comparing various tree-based methods, such as CART, bagging, and random forest, the authors assess the performance of synthetic data in statistical disclosure control and utility metrics. The findings highlight the viability of tree-based methods for synthesizing microdata, showcasing their potential across contexts constrained by confidentiality concerns.

Building upon the notion of synthetic data optimization, the paper "Optimizing the synthesis of clinical trial data using sequential trees" introduces order-optimized sequential trees as a method for synthesizing clinical trial data. The authors propose a novel approach that employs a hinge loss function based on distinguishability metrics to optimize the synthesis process. Through experiments comparing optimized sequential trees with unoptimized counterparts and random search, the authors demonstrate significant enhancements in the synthesis of clinical trial data. The paper underscores the promising prospects of order-optimized sequential trees in clinical trial data synthesis.

In the pursuit of producing high-quality synthetic data, "Guidelines for Producing Useful Synthetic Data" offers a comprehensive set of guidelines that ensure reliability and utility. This paper delves into the evaluation of data utility, encompassing graphical methods, statistical metrics, and rigorous assessment of model parameters. Emphasizing the significance of the synthpop package for R, the guidelines provide practical insights into model selection and highlight the multi-faceted considerations that influence the production of useful synthetic data.

In summary, the combination of synthetic data generation techniques and the utilization of sequential decision trees offer compelling solutions to address confidentiality constraints and enhance data utility. The synthpop package in R stands as a valuable resource, providing researchers with the means to generate bespoke synthetic data that upholds privacy and can be safely shared. As researchers continue to explore and refine synthetic data generation techniques, the development of best practices and general guidelines remains an ongoing focus for future research in this domain.

## Algorithm 

The Sequential Regression Imputation (SRI) algorithm combines decision trees with a sequential process, where the decision trees are built iteratively to generate missing values for the target variable. This approach allows the generated data to capture the relationships between the predictor variables and the target variable.


Sequential Regression Trees (SRTs) are a type of machine learning algorithm used for data imputation, which is the process of filling in missing values in a dataset. SRTs combine the concepts of decision trees and regression to handle sequential dependencies and predict missing values based on the available data.

Here's how SRTs work in the context of data imputation:

Data Representation: SRTs operate on a dataset that contains both complete and incomplete samples. Each sample consists of a set of features and a target variable, where the target variable is the feature with the missing value.

Decision Tree Construction: Initially, an SRT is constructed using the complete samples in the dataset. The decision tree partitions the feature space based on the available features to predict the target variable accurately. The tree is built recursively by splitting the data based on the selected feature and its threshold value.

Splitting Criterion: The splitting criterion used in SRTs is typically based on minimizing the mean squared error (MSE) or a similar metric. The goal is to create homogeneous subsets of data that share similar characteristics, making it easier to predict the missing values.

Handling Missing Values: When predicting the target variable for incomplete samples, the SRT uses a sequential approach. Starting from the root of the tree, it traverses the tree based on the available features, making predictions at each node until it reaches a leaf node.

Sequential Regression: At each node, SRTs estimate the missing value using regression. The regression model is trained on complete samples that reach the current node. This model takes the available features as inputs and predicts the missing value. The predicted value is then used to guide the traversal of the tree until a leaf node is reached.

Tree Refinement: After making a prediction, the SRT checks whether the prediction matches the actual value (if available). If there is a mismatch, it updates the tree structure to refine future predictions. The tree can be refined by adjusting the thresholds or adding new branches to handle previously mispredicted samples more accurately.

Iterative Process: The process of constructing an SRT and refining it is typically performed iteratively until a convergence criterion is met. This allows the algorithm to adaptively learn from the data and improve its imputation accuracy.

Overall, Sequential Regression Trees provide a sequential and tree-based approach to data imputation, leveraging decision tree structures and regression models to predict missing values based on the available data. By considering the sequential dependencies and iteratively refining the tree, SRTs can effectively handle data imputation tasks.



To use SRTs for data generation, you would follow a similar process but with some modifications:

+ Training Data: You would start with a dataset containing complete samples. Each sample would consist of features and a target variable, where the target variable could have missing values. This dataset serves as the training data for the SRT.

+ SRT Construction: Using the training data, you would construct an SRT by building a decision tree that predicts the target variable based on the available features. The tree would be constructed using a splitting criterion, such as minimizing mean squared error, to create homogeneous subsets of data.

+ Generating Missing Values: Once the SRT is constructed, you can use it to generate synthetic data by intentionally introducing missing values. You can randomly remove values from the target variable in the training data, representing the missing values you want to generate in the synthetic data.

+ Sequential Regression: For each sample with missing values, you would traverse the SRT based on the available features, predicting the missing value at each node using the regression model. This process follows a sequential approach, similar to the imputation process, until a leaf node is reached.

+ Iterative Refinement: After generating the missing values, you can refine the SRT by adjusting thresholds or adding branches to improve the accuracy of future predictions. This iterative process helps the SRT adapt to the generated data and refine its generative capabilities.

By using Sequential Regression Trees in this way, you can generate synthetic data with missing values that follow the patterns and relationships learned from the original training data. This can be useful in scenarios where you need to create realistic datasets for testing, simulations, or other purposes.



```

Input: 
- Training dataset with complete samples (train_data)
- Number of iterations for refinement (num_iterations)

Output:
- Synthetic dataset with missing values (synthetic_data)

Procedure SequentialTrees(train_data, num_iterations):
    1. Preprocess the training dataset (e.g., handle missing values, feature engineering).

    2. Construct Sequential Regression Trees (SRTs) using the training dataset:
        a. Create an empty SRT.
        b. Recursively build the SRT:
           - At each node:
             - Select the best splitting criterion based on a metric (e.g., mean squared error).
             - Split the data based on the selected criterion.
             - If the stopping criteria are met (e.g., maximum depth, minimum sample size), create a leaf node and set the prediction value.
             - Otherwise, recursively build the left and right branches.
             
    3. Generate synthetic data with missing values:
        a. Initialize an empty synthetic dataset (synthetic_data).
        b. For each sample in the training dataset:
           - Randomly select values to be masked or removed to represent missing values.
           - Add the sample with missing values to synthetic_data.
    
    4. Perform missing value imputation using the SRTs:
        a. For each sample with missing values in synthetic_data:
           - Traverse the SRT based on available features.
           - At each node, use the regression model to predict the missing value based on available features.
           - Repeat the process until a leaf node is reached, providing an imputed value.
           - Update the synthetic_data with the imputed value.

    5. Iterate the refinement process (num_iterations times):
        a. Adjust the splitting criteria, thresholds, or regression models in the SRTs.
        b. Repeat steps 3 and 4 to generate new synthetic data and perform missing value imputation.

    6. Return the final synthetic dataset with imputed missing values (synthetic_data).
```


https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7810457/figure/ocaa249-F1/

![image here](https://www.ncbi.nlm.nih.gov/core/lw/2.0/html/tileshop_pmc/tileshop_pmc_inline.html?title=Click%20on%20image%20to%20zoom&p=PMC3&id=7810457_ocaa249f1.jpg "figure")

The most important rule when selecting predictors is that independent variables in a prediction model have to be already synthesized. The only exception is when a variable is used only as a predictor and is not going to be synthesized at all. 
In order to build an adequate predictor selection matrix, instead of doing it from scratch we can define an initial visit. sequence and corresponding method vector and run syn() function. Then we can adjust the predictor selection matrix used in this synthesis and rerun the function with new parameters. 

## The Traveling Salesman Problem (TSP)

The Traveling Salesman Problem (TSP) is a well-known optimization problem in computer science and operations research. It involves determining the shortest route that a salesman can take to visit a set of cities and return to the starting city, ensuring that each city is visited exactly once. As the number of cities increases, solving the TSP becomes computationally challenging, leading to the exploration of various optimization algorithms to tackle this problem. One such algorithm is Particle Swarm Optimization (PSO).

PSO is an optimization algorithm commonly used to solve complex optimization problems. In the context of the TSP, PSO is employed as an optimization algorithm to find good or near-optimal solutions. The adaptation of PSO for the TSP involves several key steps. Firstly, particles in the PSO algorithm represent potential solutions, where each particle corresponds to a permutation of cities, defining the order of city visits. The fitness of each particle is evaluated by calculating the total distance or cost of the corresponding tour. The initialization phase randomly assigns positions to the particles, representing different initial tours. As the algorithm progresses, each particle updates its personal best solution and shares information with the global best solution found by any particle in the population. The velocity update typically used in PSO is replaced with a position perturbation operation specific to the TSP, which modifies the permutation of cities within a particle to explore different tour possibilities. This perturbation can involve swapping cities or applying local search techniques to enhance the tour quality. The PSO algorithm iterates for a defined number of iterations, during which particles continually update their positions based on their personal and global best solutions, exploring the search space in search of optimal or near-optimal tours.

Although PSO does not guarantee finding the optimal solution for the TSP due to the problem's NP-hard nature, it has demonstrated effectiveness in finding high-quality solutions and has been extensively applied in TSP optimization research. Researchers have proposed various modifications and enhancements to improve PSO's performance and convergence when applied to the TSP. These include incorporating local search operators, utilizing problem-specific heuristics, or combining PSO with other metaheuristic algorithms to further enhance the optimization process.

In conclusion, Particle Swarm Optimization (PSO) is a powerful optimization algorithm that can be adapted to solve the Traveling Salesman Problem (TSP). By representing particles as tours, evaluating fitness based on tour length, and incorporating position perturbation operations, PSO efficiently explores the solution space to find good or near-optimal tours. Although the TSP remains a challenging problem, PSO's effectiveness and versatility have made it a valuable tool in TSP optimization research. Ongoing advancements and adaptations of PSO continue to enhance its performance, furthering the exploration of optimal solutions for the TSP.

## Particle Swarm Optimization (PSO) 


Particle Swarm Optimization (PSO) is a population-based stochastic optimization algorithm that draws inspiration from the collective behavior observed in bird flocks or fish schools. It has found widespread application in solving optimization problems, particularly those involving continuous variables and nonlinear objective functions.

In PSO, a population of potential solutions, referred to as particles, collaboratively explores the search space in an iterative manner to locate the optimal or near-optimal solution. Each particle represents a candidate solution and navigates through the search space, guided by its own experience and the knowledge shared by its neighboring particles.

The PSO algorithm follows a high-level process that begins with the initialization of a population of particles, randomly positioned within the search space. Each particle is assigned a random velocity, determining its movement direction. The objective function is then evaluated for each particle, providing a measure of its fitness or quality at the current position. Each particle maintains a personal best position, reflecting the position that has yielded the best fitness value thus far. If the current position surpasses the personal best, the personal best is updated accordingly. Additionally, the global best position, representing the best solution discovered by any particle in the entire population, is continuously updated based on the personal best positions of all particles. To adapt their movement, particles update their velocities and positions based on their current state, personal best, and global best. The velocity influences the direction and magnitude of the particle's movement, while the new position determines its location in the search space. These steps are iteratively repeated for a specified number of iterations or until a termination criterion is met, such as achieving a desired fitness value or exhausting computational resources.

During the iterative process, particles dynamically adjust their velocities and positions, exploring the search space in a cooperative manner. They integrate their personal experiences with the collective knowledge of the population to converge towards the optimal solution. PSO possesses several appealing characteristics, including ease of implementation, computational efficiency, and robustness against noisy or complex objective functions. Furthermore, it has minimal control parameters, simplifying its application compared to other optimization algorithms.

However, PSO may encounter challenges such as premature convergence or being trapped in local optima. To mitigate these limitations, researchers have proposed various enhancements and extensions to the algorithm. These include incorporating adaptive parameters, hybridizing PSO with other algorithms, or leveraging problem-specific knowledge to improve performance and convergence.

In summary, Particle Swarm Optimization is a powerful and widely employed optimization algorithm that harnesses the collective behavior of particles to efficiently explore and discover optimal or near-optimal solutions within a given search space. Its effectiveness, ease of implementation, and ability to handle complex objective functions make it a valuable tool for solving a wide range of optimization problems. Ongoing research continues to advance PSO and its adaptations, paving the way for further improvements in solving complex optimization challenges.

## Leveraging Particle Swarm Optimization for Traveling Salesman Problem Optimization

The Traveling Salesman Problem (TSP) is a well-known optimization problem that involves finding the shortest route for a salesman to visit a set of cities and return to the starting city, while visiting each city exactly once. Due to its computational complexity, various optimization algorithms have been employed to tackle this challenge. One such algorithm is Particle Swarm Optimization (PSO), which offers a promising approach to address the TSP.

PSO is a population-based stochastic optimization algorithm inspired by the collective behavior of bird flocks or fish schools. It operates by iteratively exploring the search space to find optimal or near-optimal solutions. When applied to the TSP, PSO introduces several adaptations to effectively optimize the salesman's route.

In the TSP variant of PSO, particles represent potential solutions, with each particle corresponding to a specific permutation of the cities to be visited. The fitness of each particle is evaluated based on the total distance or cost of the corresponding tour. The algorithm initializes a population of particles randomly within the search space, assigning them random positions and velocities.

Throughout the iterations, particles adjust their velocities and positions, guided by their personal best (the best tour found by the particle itself) and the global best (the best tour discovered by any particle in the population). The position perturbation operation, replacing the traditional velocity update, modifies the permutation of cities within each particle to explore different tour possibilities. By evaluating fitness values and updating positions based on personal and global bests, PSO efficiently explores the solution space, striving to find high-quality solutions for the TSP.

It is important to note that although PSO is not guaranteed to find the optimal solution for the NP-hard TSP, it has demonstrated its usefulness in finding good or near-optimal solutions. Researchers have explored various modifications and enhancements to improve its performance and convergence. Some approaches incorporate local search operators or problem-specific heuristics to refine the solutions generated by PSO. Additionally, combining PSO with other metaheuristic algorithms has shown promise in achieving further optimization.

In summary, PSO offers an effective approach to address the Traveling Salesman Problem by leveraging the collective behavior of particles. It provides a flexible framework for exploring the solution space, generating high-quality solutions for the TSP. While PSO is not infallible, it has proven to be a valuable tool in tackling this challenging optimization problem. As researchers continue to refine and extend PSO's capabilities, the potential for further advancements in TSP optimization using PSO remains a promising avenue for future research.

## References

+ [Emam, K. E., Mosquera, L., & Zheng, C. (2021). Optimizing the synthesis of clinical trial data using sequential trees. Journal of the American Medical Informatics Association : JAMIA, 28(1), 3–13.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7810457/)

+ [Nowok, B., Raab, G. M., Dibben, C., & Chris, D. (2016). synthpop: Bespoke creation of synthetic data in R. Journal of Statistical Software, 74(11), 1-26. doi: 10.18637/jss.v074.i11](https://www.jstatsoft.org/article/view/v074i11)

+ [​Nowok, B​​., Raab, G. M​​., & Dibben, C​​. (2016). Utility of synthetic microdata generated using tree-based methods​​. Journal of Statistical​​ Software, 74(11),​](https://unece.org/fileadmin/DAM/stats/documents/ece/ces/ge.46/20150/Paper_33_Session_2_-_Univ._Edinburgh__Nowok_.pdf) 

+ [Luping Fang, Pan Chen, Shihua Liu: Particle Swarm Optimization with Simulated Annealing for TSP, Proceedings of the 6th WSEAS Int. Conf. on Artificial Intelligence, Knowledge Engineering and Data Bases, Corfu Island, Greece, February 16-19, 2007, pp. 206-210 ](https://dl.acm.org/doi/10.5555/1348485.1348522)

+ [Raab, G. M., Nowok, B., & Dibben, C. (2017). Guidelines for producing useful synthetic data. arXiv preprint arXiv:1712.04078.](https://www.arxiv-vanity.com/papers/1712.04078/)

+ https://github.com/CRCHUM-CITADEL/clover/blob/main/tests/utils/test_optimization.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/utils/optimization.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/generators/synthpop_generator.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/generators/synthpop_generator.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/notebooks/synthetic_data_generation.ipynb
