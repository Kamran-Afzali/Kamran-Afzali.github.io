### Bayesian networks

A Bayesian network is a graphical model that encodes probabilistic relationships among variables of interest. It takes the form of a directed acyclic graph where the nodes represent variables and the edges indicate a dependency between variables. In the context of synthetic data generation, Bayesian networks are used to learn probabilistic graphical structures from real datasets, and then simulate synthetic records from the learned structure. This approach has been successfully applied in various fields, including healthcare.

Here's how Bayesian networks can be applied in the process of synthetic data generation:

- Modeling Dependencies: Bayesian networks are adept at modeling dependencies between attributes. Each node in the network represents an attribute, and the edges between nodes indicate conditional dependencies. By constructing a Bayesian network from the original dataset, you can capture how attributes influence one another, such as how age might influence income or education level.

- Learning the Network: In many cases, the structure of the Bayesian network can be learned directly from the original data using various machine learning algorithms. This process involves identifying the conditional dependencies and structure that best fits the data. Bayesian network learning algorithms can discover relationships that might not be immediately apparent, making them a valuable tool for understanding complex datasets.

- Sampling from the Network: Once the Bayesian network is established, you can use it to sample synthetic data. Starting with known values or evidence for certain attributes, the network generates values for other attributes based on their conditional dependencies. This process ensures that the synthetic data retains the same probabilistic relationships as the original data.

In healthcare, for instance, a study used Bayesian networks to generate synthetic patient records from real datasets, such as the University of California Irvine (UCI) heart disease and diabetes datasets, as well as the MIMIC-III diagnoses database. The generated synthetic data was evaluated through statistical tests, machine learning tasks, preservation of rare events, disclosure risk, and the ability of a machine learning classifier to discriminate between the real and synthetic data. The algorithm used for Bayesian networks in synthetic data generation involves several steps. First, a "greedy" search algorithm is used to generate alternative network structures and to select the structure with the highest posterior probability given the data and prior information[1]. This network is then used to generate synthetic data.

### DataSynthesizer

DataSynthesizer is a comprehensive system designed for generating synthetic datasets from private input data. DataSynthesizer addresses the challenges of data sharing agreements, particularly in fields such as government, social sciences, and healthcare, where strict privacy rules can hinder collaborations. This system can produce structurally and statistically similar datasets while maintaining robust privacy safeguards. Its user-friendly design offers three intuitive operational modes, requiring minimal user input. The potential applications of DataSynthesizer are diverse, ranging from standalone library usage to integration into comprehensive data sharing platforms. Ongoing efforts are focused on enhancing data owner accessibility and meeting additional requirements. DataSynthesizer is open source, accessible for download at https://github.com/DataResponsibly/DataSynthesizer, making it a valuable resource for the data privacy and sharing community.


DataSynthesizer consists of three high-level modules _DataDescriber, DataGenerator and ModelInspector_. The first, DataDescriber, investigates the data types, correlations and distributions of the attributes in the private dataset, and produces a data summary, adding noise to the distributions to preserve privacy. DataGenerator samples from the summary computed by DataDescriber and outputs synthetic data. ModelInspector shows an intuitive description of the data summary that was computed by DataDescriber, allowing the data owner to evaluate the accuracy of the summarization process and adjust any parameters. The process begins with the DataDescriber module, which first processes the input dataset. It identifies the attributes' domains and estimates their distributions, saving this information in a dataset description file. For categorical attributes, DataDescriber computes the frequency distribution, which is represented as a bar chart. The DataGenerator module then samples from this distribution to create the synthetic dataset. Non-categorical numerical and datetime attributes are processed differently, with DataDescriber creating an equi-width histogram to represent their distribution. DataGenerator uses uniform sampling from this histogram during data generation. For non-categorical string attributes, DataDescriber records the minimum and maximum lengths, generating random strings within this length range during data generation.


#### DataDescriber

DataSynthesizer's DataDescriber module plays a central role in the system's functionality, aiding in the inference and definition of data types and domains for the attributes within a given dataset. Data types are classified into four distinct categories within DataSynthesizer. Users have the flexibility to explicitly specify these data types as needed. However, if a user does not specify a data type for an attribute, DataDescriber takes on the task of inferring it. The initial step in this process involves determining if an attribute is numerical and, if so, whether it is an integer or a floating-point number. In the case that the attribute doesn't align with any of the numerical categories, DataDescriber attempts to parse it as a datetime attribute. If this is unsuccessful, the attribute is identified as a string.

The domain can become more restricted if an attribute is categorized as "categorical." Categorical attributes are those for which only specific values are legitimate. It's noteworthy that even integer, floating-point, and datetime attributes can fall under the categorical category. The general criterion for an attribute to be considered categorical is when a limited number of distinct values appear in the input dataset. In the event that the input dataset contains missing values, DataDescriber recognizes their significance and computes the missing rate for each attribute. This rate is calculated as the number of observed missing values divided by the dataset's size, denoted as 'n'. This information is crucial in ensuring that the synthetic data generated by DataSynthesizer accurately represents the missing values present in the original dataset.

#### DataGenerator

The The DataGenerator component, which operates based the dataset description file created by DataDescriber. This synthetic dataset's size can be specified by the user, with the default size being the same as the input dataset, denoted as 'n'. When DataGenerator is in random mode, it generates random values for each attribute while ensuring type consistency. In independent attribute mode, DataGenerator draws samples from bar charts or histograms using uniform sampling. In correlated attribute mode, attribute values are sampled in an order determined by the Bayesian network established by DataDescriber. Differential privacy is a critical concern, as repeated data generation requests can lead to disclosure of private information. To safeguard against such risks, a unique random seed can be assigned to each individual generating a synthetic dataset, a measure that the system administrator can implement. DataGenerator facilitates this by offering per-user seed functionality, adding an extra layer of privacy protection for those interacting with the system. 


#### Model Inspector

The Model Inspector component offers a range of built-in functions aimed at assessing the similarity between the private input dataset and the synthetic output dataset. This tool enables data owners to efficiently verify whether the synthetic dataset contains detectable differences by facilitating a comparison of the first five and last five tuples in both datasets. Model Inspector also enables users to visually inspect and compare these attribute distributions through representations like bar charts or histograms. Additionally, the system calculates a correlation coefficient that aligns with the attribute type and the KL divergence value. The correlation coefficient measures the extent of association between attributes, while the KL divergence quantifies the disparity between the "before" and "after" probability distributions for a specific attribute. In scenarios where correlated attribute mode is employed, Model Inspector provides comprehensive insights by presenting matrices that illustrate pairwise mutual information before and after the synthetic data generation process. It also provides information about Bayesian networks. This functionality allows data owners to conveniently assess and compare the statistical characteristics of both datasets in one glance. Ultimately, the Model Inspector serves as a valuable tool for ensuring the privacy-preserving synthetic dataset aligns closely with the original private dataset, both in terms of individual tuple comparisons and overall statistical properties.

### Algorithm: 

The algorithm uses the GreedyBayes algorithm to create Bayesian Networks (BN) that capture the probabilistic relationships between attributes. These relationships represent how attributes are correlated. A Bayesian network is constructed from the input dataset (D), the set of attributes (A), and a parameter (k) that specifies the maximum number of parent nodes for each node in the BN. During this process, the algorithm maintains a set of visited attributes (V) and a subset of visited attributes that could potentially become parents of a node (X) in the BN. The selection of which attributes to become parents of X is done greedily, with the goal of maximizing mutual information. The Bayesian networks constructed in step above provide the order in which attribute values should be sampled to maintain the correlations between attributes. These networks define the dependencies between attributes, which guide the sampling process. The distributions used for generating dependent attribute values are referred to as "conditioned distributions." To maintain privacy, noise (represented as ε) is injected into these conditioned distributions. This noise prevents the disclosure of sensitive information about individual data points. The parent attributes of a dependent attribute can be either categorical or numerical. These parent attributes' distributions are modeled using bar charts for categorical parents and histograms for numerical parents. The conditions for a dependent attribute are based on the legal values of categorical parent attributes and the intervals of numerical parent attributes. Intervals are established in a manner similar to the unconditioned distributions of parent attributes.


### Psuedo code

The pseudocode for the synthetic data generation algorithm using Bayesian networks:

```python
# Synthetic Data Generation Algorithm

# Step 1: Construct Bayesian Networks
function ConstructBayesianNetworks(Dataset D, Set of attributes A, Maximum number of parent nodes k):
    Initialize Bayesian network BN
    Initialize set of visited attributes V
    Initialize subset of potential parent attributes P
    for each attribute X in A:
        Select subset of attributes P from V that maximizes mutual information with X
        Add X and P to BN
        Add X to V
    return BN

# Step 2: Define Sampling Order
function DefineSamplingOrder(Bayesian network BN):
    return order of attributes in BN

# Step 3: Model Parent Attributes
function ModelParentAttributes(Bayesian network BN, Privacy budget ε):
    Initialize set of conditioned distributions CD
    for each attribute X in BN:
        if X has parent attributes P:
            for each parent attribute Pi in P:
                if Pi is categorical:
                    Model distribution of Pi using bar chart
                else if Pi is numerical:
                    Model distribution of Pi using histogram
                Compute conditioned distribution of X given Pi in a differentially private manner
                Add conditioned distribution to CD
    return CD

# Main function
function SyntheticDataGeneration(Dataset D, Set of attributes A, Maximum number of parent nodes k, Privacy budget ε):
    BN = ConstructBayesianNetworks(D, A, k)
    order = DefineSamplingOrder(BN)
    CD = ModelParentAttributes(BN, ε)
    Generate synthetic data from CD in the order specified by order
```

In the first step, the algorithm constructs Bayesian networks that capture the probabilistic relationships between attributes. This is done using the GreedyBayes algorithm, which selects the subset of attributes that maximizes mutual information with the current attribute in a differentially private manner. In the second step, the algorithm defines the order in which attribute values should be sampled based on the structure of the Bayesian networks. In the third step, the algorithm models the distributions of parent attributes and computes the conditioned distributions of their dependent attributes in a differentially private manner. This involves handling both categorical and numerical parent attributes appropriately. Finally, the synthetic data is generated from the conditioned distributions in the order specified by the Bayesian networks. Please note that this is a simplified version of the algorithm. The actual implementation would involve more complex steps and considerations, such as handling privacy, noise injection for differential privacy, and specific methods for computing differentially private distributions and modeling parent attributes.

Here's an explanation of each step:

**Step 1: Construct Bayesian Networks**
This step involves constructing Bayesian networks (BNs) to model the probabilistic dependencies among attributes in the original dataset. Here's what each part of the code does:
- `Initialize Bayesian network BN`: Create an empty Bayesian network to be filled with nodes and edges.
- `Initialize set of visited attributes V`: Start with an empty set to keep track of attributes that have been visited during network construction.
- `Initialize subset of potential parent attributes P`: Create an empty subset to store attributes that are candidates for being parents of a given node.
- `for each attribute X in A`: Loop through each attribute in the set of attributes A.
  - `Select subset of attributes P from V that maximizes mutual information with X`: Choose a subset of attributes from the visited set that maximizes the mutual information with the current attribute X. This step determines the parent attributes for X in the Bayesian network.
  - `Add X and P to BN`: Add the attribute X and its selected parent attributes P to the Bayesian network BN.
  - `Add X to V`: Include the current attribute X in the set of visited attributes.
- `return BN`: The constructed Bayesian network BN captures the dependencies between attributes and their parent nodes.

**Step 2: Define Sampling Order**
This step is relatively straightforward:
- `return order of attributes in BN`: Determine the order in which attribute values should be sampled from the Bayesian network BN. The order is essential to ensure that the generated synthetic data preserves the relationships and dependencies between attributes.

**Step 3: Model Parent Attributes**
This step focuses on modeling the parent attributes and creating conditioned distributions for generating synthetic data:
- `Initialize set of conditioned distributions CD`: Start with an empty set to store the conditioned distributions.
- `for each attribute X in BN`: Iterate through each attribute in the Bayesian network BN.
  - `if X has parent attributes P`: Check if the current attribute X has parent attributes (P).
    - `for each parent attribute Pi in P`: Loop through each parent attribute in the set of parent attributes P.
      - `if Pi is categorical`: Check if the parent attribute Pi is categorical.
        - `Model distribution of Pi using a bar chart`: Model the distribution of Pi using a bar chart, which is suitable for categorical attributes.
      - `else if Pi is numerical`: Check if the parent attribute Pi is numerical.
        - `Model distribution of Pi using a histogram`: Model the distribution of Pi using a histogram, which is appropriate for numerical attributes.
      - `Compute conditioned distribution of X given Pi in a differentially private manner`: Calculate the conditioned distribution of X given Pi while preserving differential privacy.
      - `Add conditioned distribution to CD`: Include the calculated conditioned distribution in the set of conditioned distributions CD.
- `return CD`: The set CD now contains all the conditioned distributions necessary for generating synthetic data, considering the relationships with parent attributes.

**Main Function (SyntheticDataGeneration)**
The main function combines the results from the previous steps to generate synthetic data:
- `BN = ConstructBayesianNetworks(D, A, k)`: Create the Bayesian network BN using the provided original dataset D, attributes A, and the maximum number of parent nodes (k).
- `order = DefineSamplingOrder(BN)`: Define the order in which attribute values should be sampled based on the constructed Bayesian network BN.
- `CD = ModelParentAttributes(BN, ε)`: Model the parent attributes and create the conditioned distributions while maintaining privacy (using the privacy budget ε).
- `Generate synthetic data from CD in the order specified by order`: Use the conditioned distributions in the specified order to generate the synthetic dataset while preserving the statistical properties and privacy constraints.

This algorithm constructs a Bayesian network to model attribute dependencies, defines a sampling order, models parent attributes, and generates synthetic data while preserving privacy and maintaining the statistical relationships between attributes.


### Clover implementation

    """
    :cvar name: the name of the metric
    :vartype name: str
    :param df: the data to synthesize
    :param metadata: a dictionary containing the list of **continuous** and **categorical** variables
    :param random_state: for reproducibility purposes
    :param generator_filepath: the path of the generator to sample from if it exists
    :param candidate_keys: the candidate keys of the original database
    :param epsilon: the epsilon-DP for the Differential Privacy (0 for no added noise)
    :param degree: the maximum numbers of parents in the Bayesian Network
    """


       DataSynthesizer(
            df: pd.DataFrame,
            metadata: dict,
            random_state: int = None,
            generator_filepath: Union[Path, str] = None,
            candidate_keys: List[str] = None,
            epsilon: int = 0,
            degree: int = 5,
        ):

### References

- https://dl.acm.org/doi/10.1145/3085504.3091117
- https://github.com/DataResponsibly/DataSynthesizer/tree/master
- https://github.com/CRCHUM-CITADEL/clover/blob/main/generators/dataSynthesizer.py
- https://github.com/DataResponsibly/DataSynthesizer.

- [1] https://pubmed.ncbi.nlm.nih.gov/33367620/
- [2] https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7973486/
- [3] https://dl.acm.org/doi/10.1145/3411170.3411243
- [4] https://academic.oup.com/jamia/article/28/4/801/6046159
- [5] https://www.sciencedirect.com/science/article/pii/S2667096823000241
- [6] https://www.cs.cmu.edu/~dmarg/Papers/PhD-Thesis-Margaritis.pdf
- [7] https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/using-bayesian-networks-to-create-synthetic-data.pdf
- [8] https://youtube.com/watch?v=06PzhH5lSPY
- [9] https://www.aimspress.com/article/doi/10.3934/mbe.2021426
- [10] https://www.researchgate.net/publication/288995388_Using_Bayesian_Networks_to_Create_Synthetic_Data
- [11] https://cprd.com/sites/default/files/2022-02/Tucker%20et%20al.%20preprint.pdf
- [12] https://www.researchgate.net/publication/355308838_Synthetic_data_generation_with_probabilistic_Bayesian_Networks
- [3] https://github.com/daanknoors/synthetic_data_generation
- [7] https://journalprivacyconfidentiality.org/index.php/jpc/article/download/776/723


