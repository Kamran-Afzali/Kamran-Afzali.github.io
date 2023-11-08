### Bayesian networks

A Bayesian network is a graphical model that encodes probabilistic relationships among variables of interest[3]. It takes the form of a directed acyclic graph where the nodes represent variables and the edges indicate a dependency between variables[2]. 

In the context of synthetic data generation, Bayesian networks are used to learn probabilistic graphical structures from real datasets, and then simulate synthetic records from the learned structure[1][4]. This approach has been successfully applied in various fields, including healthcare and social media data synthesis[1][3].

Here's how Bayesian networks can be applied in the process of synthetic data generation:

- Modeling Dependencies: Bayesian networks are adept at modeling dependencies between attributes. Each node in the network represents an attribute, and the edges between nodes indicate conditional dependencies. By constructing a Bayesian network from the original dataset, you can capture how attributes influence one another, such as how age might influence income or education level.

- Learning the Network: In many cases, the structure of the Bayesian network can be learned directly from the original data using various machine learning algorithms. This process involves identifying the conditional dependencies and structure that best fits the data. Bayesian network learning algorithms can discover relationships that might not be immediately apparent, making them a valuable tool for understanding complex datasets.

- Sampling from the Network: Once the Bayesian network is established, you can use it to sample synthetic data. Starting with known values or evidence for certain attributes, the network generates values for other attributes based on their conditional dependencies. This process ensures that the synthetic data retains the same probabilistic relationships as the original data.


In healthcare, for instance, a study used Bayesian networks to generate synthetic patient records from real datasets, such as the University of California Irvine (UCI) heart disease and diabetes datasets, as well as the MIMIC-III diagnoses database[1][4]. The generated synthetic data was evaluated through statistical tests, machine learning tasks, preservation of rare events, disclosure risk, and the ability of a machine learning classifier to discriminate between the real and synthetic data[1]. The Bayesian network model outperformed or equaled the predominant existing method, medBGAN, in all key metrics, notably capturing rare variables and preserving association rules[1]. 

The use of Bayesian networks in synthetic data generation offers several advantages. They generate data sufficiently similar to the original data with minimal risk of disclosure, while offering additional transparency, computational efficiency, and capacity to handle more data types in comparison to existing methods[1][4]. This makes them a valuable tool for organizations that need to distribute data to researchers, reducing the need for access to real data[1][2][4].

The algorithm used for Bayesian networks in synthetic data generation involves several steps. First, a "greedy" search algorithm is used to generate alternative network structures and to select the structure with the highest posterior probability given the data and prior information[1]. This network is then used to generate synthetic data[1].

One of the methods used for synthetic data generation with Bayesian networks is PrivBayes, which synthesizes data via a Bayesian network with differentially private (DP) conditional distributions[3]. PrivBayes is a differentially private method for synthetic data generation[7]. The construction of the Bayesian network and the approximation of the low dimension distributions are conducted in a manner that satisfies differential privacy[7]. Finally, PrivBayes generates synthetic tuples using the Bayesian network and noisy distributions, and releases them[7].

The PrivBayes method involves two main steps[7]:

1. Network learning: Construct a Bayesian network over the attributes in the data using the analytical Gaussian mechanism. The Bayesian network is represented as a fully connected set of attributes and a set of attribute-parent pairs.
2. Distribution learning: Generate the corresponding joint and conditional distributions for the Bayesian network learned in the first phase using the analytical Gaussian mechanism.

### Psuedo code

Based on the search results, the PrivBayes algorithm for synthetic data generation using Bayesian networks can be broken down into two main steps: Network Learning and Distribution Learning. Here is a simplified pseudocode representation of the process:

```python
# PrivBayes Algorithm

# Step 1: Network Learning
function NetworkLearning(Dataset D, Privacy budget ε):
    Initialize Bayesian network N
    for each attribute in D:
        Select attribute Xi and its parent set Πi in a differentially private manner
        Add Xi and Πi to N
    return N

# Step 2: Distribution Learning
function DistributionLearning(Bayesian network N, Dataset D, Privacy budget ε):
    Initialize set of distributions P
    for each attribute Xi and its parent set Πi in N:
        Compute joint distribution Pr[Xi, Πi] in a differentially private manner
        Derive conditional distribution Pr[Xi|Πi] from Pr[Xi, Πi]
        Add Pr[Xi|Πi] to P
    return P

# Main function
function PrivBayes(Dataset D, Privacy budget ε):
    N = NetworkLearning(D, ε)
    P = DistributionLearning(N, D, ε)
    Generate synthetic data from P
```

In the Network Learning step, the algorithm constructs a Bayesian network over the attributes in the data in a differentially private manner. This involves selecting an attribute and its parent set in each iteration and adding them to the network[2].

In the Distribution Learning step, the algorithm generates the corresponding joint and conditional distributions for the Bayesian network learned in the first phase. This is done in a differentially private manner, and the distributions are added to a set P[1].

Finally, the synthetic data is generated from the set of distributions P[1].

Please note that this is a simplified version of the algorithm. The actual implementation would involve more complex steps and considerations, such as handling privacy budgets, noise injection for differential privacy, and specific methods for computing differentially private distributions[1][2][7].




The pseudo code provided outlines the PrivBayes algorithm, a differentially private method for generating synthetic data while preserving the privacy of the individuals in the original dataset. This algorithm consists of two main steps: Network Learning and Distribution Learning.

**Step 1: Network Learning**
In this step, the algorithm constructs a Bayesian network (N) from the original dataset (D) while ensuring differential privacy. A Bayesian network is a graphical model that represents probabilistic dependencies between attributes. Here's an explanation of the key elements:

- `Initialize Bayesian network N`: Create an empty Bayesian network to be populated with nodes and edges.
- `for each attribute in D`: Iterate through each attribute in the original dataset.
  - `Select attribute Xi and its parent set Πi in a differentially private manner`: For each attribute, choose the attribute itself (Xi) and its parent set (Πi) in a way that preserves differential privacy. The parent set represents the attributes that directly influence Xi.
  - `Add Xi and Πi to N`: Incorporate Xi and Πi into the Bayesian network N.
- `return N`: The network N, which captures the probabilistic relationships among attributes, is returned.

**Step 2: Distribution Learning**
In this step, the algorithm computes the joint and conditional distributions associated with the attributes in the Bayesian network N. These distributions are used to generate the synthetic data. Here's an explanation of the key elements:

- `Initialize set of distributions P`: Create an empty set (P) to store the conditional distributions.
- `for each attribute Xi and its parent set Πi in N`: Iterate through each attribute and its corresponding parent set in the Bayesian network.
  - `Compute joint distribution Pr[Xi, Πi] in a differentially private manner`: Calculate the joint distribution between Xi and Πi while preserving differential privacy.
  - `Derive conditional distribution Pr[Xi|Πi] from Pr[Xi, Πi]`: From the joint distribution, derive the conditional distribution of Xi given its parent set Πi.
  - `Add Pr[Xi|Πi] to P`: Incorporate the conditional distribution Pr[Xi|Πi] into the set P.
- `return P`: The set P now contains all the conditional distributions for attributes, which will be used for data generation.

**Main Function (PrivBayes)**
The main function combines the results from the two previous steps to generate the synthetic data while preserving differential privacy. Here's a brief explanation:

- `N = NetworkLearning(D, ε)`: Create the Bayesian network N by invoking the NetworkLearning function with the original dataset D and privacy budget ε.
- `P = DistributionLearning(N, D, ε)`: Compute the set of conditional distributions P by invoking the DistributionLearning function with the Bayesian network N, original dataset D, and privacy budget ε.
- `Generate synthetic data from P`: Use the conditional distributions in P to generate a synthetic dataset that approximates the statistical properties of the original dataset while satisfying the privacy constraints.

In summary, the PrivBayes algorithm is a privacy-preserving approach for generating synthetic data by first learning the probabilistic relationships between attributes and then using these relationships to model the conditional distributions necessary for data generation. Differential privacy is maintained throughout the process to protect individual privacy.

### DataSynthesizer
DataSynthesizer is a comprehensive system designed for generating synthetic datasets from private input data. DataSynthesizer addresses the challenges of data sharing agreements, particularly in fields such as government, social sciences, and healthcare, where strict privacy rules can hinder collaborations. This system can produce structurally and statistically similar datasets while maintaining robust privacy safeguards. Its user-friendly design offers three intuitive operational modes, requiring minimal user input. The potential applications of DataSynthesizer are diverse, ranging from standalone library usage to integration into comprehensive data sharing platforms. Ongoing efforts are focused on enhancing data owner accessibility and meeting additional requirements. DataSynthesizer is open source, accessible for download at https://github.com/DataResponsibly/DataSynthesizer, making it a valuable resource for the data privacy and sharing community.


DataSynthesizer consists of three high-level modules --- DataDescriber, DataGenerator and ModelInspector. The first, DataDescriber, investigates the data types, correlations and distributions of the attributes in the private dataset, and produces a data summary, adding noise to the distributions to preserve privacy. DataGenerator samples from the summary computed by DataDescriber and outputs synthetic data. ModelInspector shows an intuitive description of the data summary that was computed by DataDescriber, allowing the data owner to evaluate the accuracy of the summarization process and adjust any parameters, if desired. The process begins with the DataDescriber module, which first processes the input dataset. It identifies the attributes' domains and estimates their distributions, saving this information in a dataset description file. For categorical attributes, DataDescriber computes the frequency distribution, which is represented as a bar chart. The DataGenerator module then samples from this distribution to create the synthetic dataset. Non-categorical numerical and datetime attributes are processed differently, with DataDescriber creating an equi-width histogram to represent their distribution. DataGenerator uses uniform sampling from this histogram during data generation. For non-categorical string attributes, DataDescriber records the minimum and maximum lengths, generating random strings within this length range during data generation.


#### DataDescriber

DataSynthesizer's DataDescriber module plays a pivotal role in the system's functionality, aiding in the inference and definition of data types and domains for the attributes within a given dataset. This understanding of attribute characteristics is fundamental to the generation of synthetic data that mimics the original dataset while preserving privacy and statistical fidelity.

Data types, which are crucial in characterizing the attributes, are classified into four distinct categories within DataSynthesizer. Users have the flexibility to explicitly specify these data types as needed. However, if a user does not specify a data type for an attribute, DataDescriber takes on the task of inferring it. The initial step in this process involves determining if an attribute is numerical and, if so, whether it is an integer or a floating-point number. In the case that the attribute doesn't align with any of the numerical categories, DataDescriber attempts to parse it as a datetime attribute. If this is unsuccessful, the attribute is identified as a string.

The data type of an attribute plays a pivotal role in defining its domain, which is essentially the set of permissible values. The domain can become more restricted if an attribute is categorized as "categorical." Categorical attributes are those for which only specific values are legitimate. For instance, in a dataset about students, the attribute "degree" may be constrained to values like "BS," "BA," "MS," or "PhD," rendering its domain as {BS, BA, MS, PhD}. It's noteworthy that even integer, floating-point, and datetime attributes can fall under the categorical category. The general criterion for an attribute to be considered categorical is when a limited number of distinct values appear in the input dataset. DataDescriber uses a default threshold, denoted as the "categorical threshold," which is set at 10 and signifies the maximum allowable distinct values for an attribute to be regarded as categorical.

However, setting a universal threshold can be challenging, as user preferences may vary for different attributes within the input dataset. Some attributes may seem categorical based on the threshold but are better suited to be treated as numerical. For instance, even if the age of elementary school children assumes only a handful of distinct values, users might prefer generating data for this attribute from a continuous range. Conversely, attributes with numerous distinct values, like country names, may not meet the categorical criteria, yet users may still prefer to treat them as categorical, generating valid country names rather than random strings. To cater to these nuanced preferences, DataSynthesizer provides users with the ability to specify data types and categorization for each attribute individually, thereby overriding the default settings.

It is worth noting that the actual datatype assigned to a categorical attribute is not particularly relevant in terms of the statistical properties and privacy guarantees of the synthetic data generation process. Whether an attribute like "sex" is encoded as "M/F," "0/1," or by using a Boolean flag (e.g., "True" for male and "False" for female), the tool performs computations based on the frequencies of each attribute value in the input dataset and subsequently samples values accordingly.

In the event that the input dataset contains missing values, DataDescriber recognizes their significance and computes the missing rate for each attribute. This rate is calculated as the number of observed missing values divided by the dataset's size, denoted as 'n'. This information is crucial in ensuring that the synthetic data generated by DataSynthesizer accurately represents the missing values present in the original dataset.

#### DataGenerator

The The DataGenerator component, which operates in tandem with the dataset description file created by DataDescriber, plays a pivotal role in generating synthetic data. This synthetic dataset's size can be specified by the user, with the default size being the same as the input dataset, denoted as 'n.'

The data generation process is detailed in Algorithm 2. When DataGenerator is in random mode, it generates random values for each attribute while ensuring type consistency. In independent attribute mode, DataGenerator draws samples from bar charts or histograms using uniform sampling. In correlated attribute mode, attribute values are sampled in an order determined by the Bayesian network established by DataDescriber.

Differential privacy is a critical concern, as repeated data generation requests can lead to the inadvertent disclosure of private information. To safeguard against such risks, a unique random seed can be assigned to each individual requiring a synthetic dataset, a measure that the system administrator can implement. DataGenerator facilitates this by offering per-user seed functionality, adding an extra layer of privacy protection for those interacting with the system. component, which operates in tandem with the dataset description file created by DataDescriber, plays a pivotal role in generating synthetic data. This synthetic dataset's size can be specified by the user, with the default size being the same as the input dataset, denoted as 'n.'

The data generation process is detailed in Algorithm 2. When DataGenerator is in random mode, it generates random values for each attribute while ensuring type consistency. In independent attribute mode, DataGenerator draws samples from bar charts or histograms using uniform sampling. In correlated attribute mode, attribute values are sampled in an order determined by the Bayesian network established by DataDescriber.

Differential privacy is a critical concern, as repeated data generation requests can lead to the inadvertent disclosure of private information. To safeguard against such risks, a unique random seed can be assigned to each individual requiring a synthetic dataset, a measure that the system administrator can implement. DataGenerator facilitates this by offering per-user seed functionality, adding an extra layer of privacy protection for those interacting with the system.

#### Model Inspector

The Model Inspector component offers a range of built-in functions aimed at assessing the similarity between the private input dataset and the synthetic output dataset. This tool empowers data owners to efficiently verify whether the synthetic dataset contains detectable differences by facilitating a comparison of the first five and last five tuples in both datasets.

Ensuring that the synthetic dataset exhibits comparable attribute value distributions to the input dataset is crucial. When operating in independent attribute mode, Model Inspector enables users to visually inspect and compare these attribute distributions through representations like bar charts or histograms. Additionally, the system calculates a correlation coefficient that aligns with the attribute type and the KL divergence value. The correlation coefficient measures the extent of association between attributes, while the KL divergence quantifies the disparity between the "before" and "after" probability distributions for a specific attribute.

In scenarios where correlated attribute mode is employed, Model Inspector provides comprehensive insights by presenting matrices that illustrate pairwise mutual information before and after the synthetic data generation process. It also provides information about Bayesian networks. This functionality allows data owners to conveniently assess and compare the statistical characteristics of both datasets in one glance. Ultimately, the Model Inspector serves as a valuable tool for ensuring the privacy-preserving synthetic dataset aligns closely with the original private dataset, both in terms of individual tuple comparisons and overall statistical properties.

### Clover implementation

    """
    Wrapper of the DataSynthesizer implementation https://github.com/DataResponsibly/DataSynthesizer.
    See the article `Ping, Haoyue, Julia Stoyanovich, and Bill Howe.
    "Datasynthesizer: Privacy-preserving synthetic datasets." Proceedings of the 29th International Conference on
    Scientific and Statistical Database Management. 2017.
    <https://dl.acm.org/doi/abs/10.1145/3085504.3091117>`_ for more details.

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

https://dl.acm.org/doi/10.1145/3085504.3091117

https://github.com/DataResponsibly/DataSynthesizer/tree/master

https://github.com/CRCHUM-CITADEL/clover/blob/main/generators/dataSynthesizer.py
https://github.com/DataResponsibly/DataSynthesizer.

[1] https://pubmed.ncbi.nlm.nih.gov/33367620/
[2] https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7973486/
[3] https://dl.acm.org/doi/10.1145/3411170.3411243
[4] https://academic.oup.com/jamia/article/28/4/801/6046159
[5] https://www.sciencedirect.com/science/article/pii/S2667096823000241
[6] https://www.cs.cmu.edu/~dmarg/Papers/PhD-Thesis-Margaritis.pdf
[7] https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/using-bayesian-networks-to-create-synthetic-data.pdf
[8] https://youtube.com/watch?v=06PzhH5lSPY
[9] https://www.aimspress.com/article/doi/10.3934/mbe.2021426
[10] https://www.researchgate.net/publication/288995388_Using_Bayesian_Networks_to_Create_Synthetic_Data
[11] https://cprd.com/sites/default/files/2022-02/Tucker%20et%20al.%20preprint.pdf
[12] https://www.researchgate.net/publication/355308838_Synthetic_data_generation_with_probabilistic_Bayesian_Networks



[1] https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/using-bayesian-networks-to-create-synthetic-data.pdf
[2] https://www.aimspress.com/article/doi/10.3934/mbe.2021426
[3] https://github.com/daanknoors/synthetic_data_generation
[4] https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7973486/
[5] https://pubmed.ncbi.nlm.nih.gov/33367620/
[6] https://www.researchgate.net/publication/288995388_Using_Bayesian_Networks_to_Create_Synthetic_Data
[7] https://journalprivacyconfidentiality.org/index.php/jpc/article/download/776/723


[1] http://dimacs.rutgers.edu/~graham/pubs/papers/privbayes-tods.pdf
[2] http://dimacs.rutgers.edu/~graham/pubs/papers/PrivBayes.pdf
[3] https://www.usenix.org/system/files/sec21fall-zhang-zhikun.pdf
[4] https://dr.ntu.edu.sg/bitstream/10356/69204/1/PpMain.V1.pdf
[5] https://journalprivacyconfidentiality.org/index.php/jpc/article/download/776/723
[6] https://www.utupub.fi/bitstream/handle/10024/151045/Perkonoja_Katariina_opinnayte.pdf?isAllowed=y&sequence=1
[7] https://www.researchgate.net/publication/320679178_PrivBayes_Private_Data_Release_via_Bayesian_Networks
