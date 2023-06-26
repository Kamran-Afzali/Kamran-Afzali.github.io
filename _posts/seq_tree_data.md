
## Introduction

Synthetic data, generated through algorithms and statistical models, has emerged as a valuable tool in the field of healthcare. It offers numerous advantages and applications, ranging from privacy protection to improving the efficiency and accuracy of research and analysis. One of the primary benefits of synthetic data in healthcare is privacy protection. Healthcare data contains sensitive and personal information, such as medical history, genomic data, and demographics. Sharing or analyzing such data carries significant privacy risks. Synthetic data provides a solution by allowing the generation of realistic datasets that retain the underlying patterns and statistical properties of the original data, while simultaneously removing any personally identifiable information. This synthetic data can be safely shared with researchers, third-party organizations, or used for internal analysis without compromising patient privacy. By using synthetic data, healthcare organizations can adhere to privacy regulations such as the Health Insurance Portability and Accountability Act (HIPAA) while still facilitating data-driven research and innovation.

Another key application of synthetic data in healthcare is its ability to improve research and analysis. Real healthcare datasets are often limited in size and complexity due to privacy concerns and data access restrictions. This scarcity of data can hinder the accuracy and generalizability of research findings. Synthetic data addresses this limitation by enabling the creation of larger and more diverse datasets that closely resemble real-world scenarios. Researchers can generate synthetic datasets that simulate different patient populations, disease prevalence, or treatment outcomes, allowing for a more comprehensive exploration of various healthcare scenarios. This augmented data availability can enhance the development and validation of predictive models, support clinical decision-making, and foster evidence-based healthcare practices.

Furthermore, synthetic data enables the development and testing of novel healthcare technologies and algorithms. Innovations in healthcare, such as machine learning algorithms or medical imaging techniques, often require substantial amounts of labeled training data. Acquiring such data can be challenging, especially when dealing with sensitive or rare medical conditions. Synthetic data can bridge this gap by generating synthetic samples that represent a wide range of conditions, thereby facilitating the development and evaluation of new technologies. It enables researchers and developers to iterate and optimize their algorithms in a controlled environment before transitioning to real patient data. By leveraging synthetic data, healthcare innovations can be accelerated, reducing the time and costs associated with traditional data collection and annotation processes.

To explore the efficacy of synthetic data synthesis, the paper "Utility of synthetic microdata generated using tree-based methods" evaluates the utility of synthetic data produced through the implementation of tree-based methods in synthpop software. By employing classification and regression trees (CART) and comparing various tree-based methods, such as CART, bagging, and random forest, the authors assess the performance of synthetic data in statistical disclosure control and utility metrics. The findings highlight the viability of tree-based methods for synthesizing microdata, showcasing their potential across contexts constrained by confidentiality concerns. This idea can go further with the use of Sequential decision trees offering compelling solutions to address confidentiality constraints and enhance data utility. The "Bespoke Creation of Synthetic Data in R" paper introduces the synthpop package for R. This comprehensive tool empowers researchers to generate synthetic versions of original datasets, mimicking the observed data while preserving essential variable relationships. 

## Algorithm 

Sequential Regression Trees (SRTs) are a type of machine learning algorithm used for data imputation and data generation, based on the concepts of decision trees and sequentiality.

Here's how SRTs work in the context of data generation:

+ Training Data: You would start with a dataset containing complete samples. Each sample would consist of features and a target variable, where the target variable could have missing values. This dataset serves as the training data for the SRT.

+ SRT Construction: Using the training data, you would construct an SRT by building a decision tree that predicts the target variable based on the available features. The tree would be constructed using a splitting criterion, such as minimizing mean squared error, to create homogeneous subsets of data.

+ Generating Values: Once the SRT is constructed, you can use it to generate synthetic data by intentionally introducing missing values. You can randomly remove values from the target variable in the training data, representing the missing values you want to generate in the synthetic data.


Let's say we have five variables, A,B,C,D, and E. The generation is performed sequentially, and therefore we need to have a sequence. Various criteria can be used to choose a sequence. For our example, we define the sequence A ->E -> C -> B ->D. Let the prime notation indicate that the variable is synthesized. For example, A' means that this is the synthesized version of A. 
The generative process consists of two general steps: fitting and synthesis. The following are the steps for sequential generation:


```

Input: 
- Training dataset 

Output:
- Synthetic dataset

Procedure SequentialTrees(train_data):

1. Construct Sequential Regression Trees (SRTs) using the training dataset:

+ Build a model Fl: E ~ A 
+ Build a model F2: C ~ A + E 
+ Build a model F3: B ~ A + E + C 
+ Build a model F4: D ~ A + E + C + B    
             
2. Generate synthetic data with missing values:

+ Sample from the A distribution to get A' 
+ Synthesize E as E' = F1(A') 
+ Synthesize C as C' F2(A', E') 
+ Synthesize B as B' = F3(A', E' 
+ Synthesize D as D'.F4(A', E', C', B') 
+ The four models (F1, F2, F3, and F4) make up the overall generative model. 

3. Return the final synthetic dataset.
```

The first variable to be synthesised A cannot have any predictors and therefore its synthetic values are generated by random sampling with replacement from its observed values. Then the distribution of E conditional on A is estimated and the synthetic values of E are generated using the fitted model and the synthesised values of A. Next the distribution of C conditional on A and E is estimated and used along with synthetic values of A and E to generate synthetic values of C and so on. The distribution of the last variable D will be conditional on all other variables. Similar conditional specification approaches are used in most implementations of synthetic data generation. 

    SynthpopGenerator()

The most important rule when selecting predictors is that independent variables in a prediction model have to be already synthesized. The only exception is when a variable is used only as a predictor and is not going to be synthesized at all. In order to build an adequate predictor selection matrix, instead of doing it from scratch we can define an initial visit. Then we can adjust the predictor selection matrix used in this synthesis and rerun the function with new parameters. Another option would be to concenputalize the variable order as an optimization problem such as the Traveling Salesman Problem (TSP). 

The Traveling Salesman Problem (TSP) is a well-known optimization problem in computer science and operations research. It involves determining the shortest route that a salesman can take to visit a set of cities and return to the starting city, ensuring that each city is visited exactly once. As the number of cities increases, solving the TSP becomes computationally challenging, leading to the exploration of various optimization algorithms to tackle this problem. One such algorithm is Particle Swarm Optimization (PSO). 

Particle Swarm Optimization (PSO) is a population-based stochastic optimization algorithm that draws inspiration from the collective behavior observed in bird flocks or fish schools. In PSO, a population of potential solutions, referred to as particles, collaboratively explores the search space in an iterative manner to locate the optimal or near-optimal solution. Each particle represents a candidate solution and navigates through the search space, guided by its own experience and the knowledge shared by its neighboring particles. The objective function is then evaluated for each particle, providing a measure of its fitness or quality at the current position. Each particle maintains a personal best position, reflecting the position that has yielded the best fitness value thus far. If the current position surpasses the personal best, the personal best is updated accordingly. Additionally, the global best position, representing the best solution discovered by any particle in the entire population, is continuously updated based on the personal best positions of all particles. To adapt their movement, particles update their velocities and positions based on their current state, personal best, and global best. The velocity influences the direction and magnitude of the particle's movement, while the new position determines its location in the search space. These steps are iteratively repeated for a specified number of iterations or until a termination criterion is met, such as achieving a desired fitness value or exhausting computational resources.

However, PSO may encounter challenges such as premature convergence or being trapped in local optima. To mitigate these limitations, researchers have proposed various enhancements and extensions to the algorithm. These include incorporating adaptive parameters, hybridizing PSO with other algorithms, or leveraging problem-specific knowledge to improve performance and convergence. In summary, Particle Swarm Optimization is a powerful and widely employed optimization algorithm that harnesses the collective behavior of particles to efficiently explore and discover optimal or near-optimal solutions within a given search space. Its effectiveness, ease of implementation, and ability to handle complex objective functions make it a valuable tool for solving a wide range of optimization problems. Ongoing research continues to advance PSO and its adaptations, paving the way for further improvements in solving complex optimization challenges.

The Traveling Salesman Problem (TSP) is a well-known optimization problem that involves finding the shortest route for a salesman to visit a set of cities and return to the starting city, while visiting each city exactly once. Due to its computational complexity, various optimization algorithms have been employed to tackle this challenge. One such algorithm is Particle Swarm Optimization (PSO), which offers a promising approach to address the TSP. PSO is a population-based stochastic optimization algorithm inspired by the collective behavior of bird flocks or fish schools. It operates by iteratively exploring the search space to find optimal or near-optimal solutions. When applied to the TSP, PSO introduces several adaptations to effectively optimize the salesman's route. In the TSP variant of PSO, particles represent potential solutions, with each particle corresponding to a specific permutation of the cities to be visited. The fitness of each particle is evaluated based on the total distance or cost of the corresponding tour. The algorithm initializes a population of particles randomly within the search space, assigning them random positions and velocities. Throughout the iterations, particles adjust their velocities and positions, guided by their personal best (the best tour found by the particle itself) and the global best (the best tour discovered by any particle in the population). The position perturbation operation, replacing the traditional velocity update, modifies the permutation of cities within each particle to explore different tour possibilities. By evaluating fitness values and updating positions based on personal and global bests, PSO efficiently explores the solution space, striving to find high-quality solutions for the TSP.


## References

+ [Emam, K. E., Mosquera, L., & Zheng, C. (2021). Optimizing the synthesis of clinical trial data using sequential trees. Journal of the American Medical Informatics Association : JAMIA, 28(1), 3–13.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7810457/)

+ [Nowok, B., Raab, G. M., Dibben, C., & Chris, D. (2016). synthpop: Bespoke creation of synthetic data in R. Journal of Statistical Software, 74(11), 1-26. doi: 10.18637/jss.v074.i11](https://www.jstatsoft.org/article/view/v074i11)

+ [​Nowok, B​​., Raab, G. M​​., & Dibben, C​​. (2016). Utility of synthetic microdata generated using tree-based methods​​. Journal of Statistical​​ Software, 74(11),​](https://unece.org/fileadmin/DAM/stats/documents/ece/ces/ge.46/20150/Paper_33_Session_2_-_Univ._Edinburgh__Nowok_.pdf) 

+ [Luping Fang, Pan Chen, Shihua Liu: Particle Swarm Optimization with Simulated Annealing for TSP, Proceedings of the 6th WSEAS Int. Conf. on Artificial Intelligence, Knowledge Engineering and Data Bases, Corfu Island, Greece, February 16-19, 2007, pp. 206-210 ](https://dl.acm.org/doi/10.5555/1348485.1348522)

+ [Raab, G. M., Nowok, B., & Dibben, C. (2017). Guidelines for producing useful synthetic data. arXiv preprint arXiv:1712.04078.](https://www.arxiv-vanity.com/papers/1712.04078/)
+ [Hothorn, T., Hornik, K., & Zeileis, A. (2006). Unbiased recursive partitioning: A conditional inference framework. Journal of Computational and Graphical statistics, 15(3), 651-674.](https://www.zeileis.org/papers/Hothorn+Hornik+Zeileis-2006.pdf)
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/tests/utils/test_optimization.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/utils/optimization.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/generators/synthpop_generator.py
+ https://github.com/CRCHUM-CITADEL/clover/blob/main/notebooks/synthetic_data_generation.ipynb
