### DataSynthesizer
DataSynthesizer consists of three high-level modules --- DataDescriber, DataGenerator and ModelInspector. The first, DataDescriber, investigates the data types, correlations and distributions of the attributes in the private dataset, and produces a data summary, adding noise to the distributions to preserve privacy. DataGenerator samples from the summary computed by DataDescriber and outputs synthetic data. ModelInspector shows an intuitive description of the data summary that was computed by DataDescriber, allowing the data owner to evaluate the accuracy of the summarization process and adjust any parameters, if desired.



DataSynthesizer is a comprehensive system designed for generating synthetic datasets from private input data. This Python 3-based tool is tailored to work with CSV-formatted private datasets, making it a versatile solution for a wide range of applications.

The process begins with the DataDescriber module, which first processes the input dataset. It identifies the attributes' domains and estimates their distributions, saving this information in a dataset description file. For categorical attributes, DataDescriber computes the frequency distribution, which is represented as a bar chart. The DataGenerator module then samples from this distribution to create the synthetic dataset. Non-categorical numerical and datetime attributes are processed differently, with DataDescriber creating an equi-width histogram to represent their distribution. DataGenerator uses uniform sampling from this histogram during data generation. For non-categorical string attributes, DataDescriber records the minimum and maximum lengths, generating random strings within this length range during data generation.

DataSynthesizer addresses the challenges of data sharing agreements, particularly in fields such as government, social sciences, and healthcare, where strict privacy rules can hinder collaborations. This system can produce structurally and statistically similar datasets while maintaining robust privacy safeguards. Its user-friendly design offers three intuitive operational modes, requiring minimal user input.

The potential applications of DataSynthesizer are diverse, ranging from standalone library usage to integration into comprehensive data sharing platforms. Ongoing efforts are focused on enhancing data owner accessibility and meeting additional requirements. DataSynthesizer is open source, accessible for download at https://github.com/DataResponsibly/DataSynthesizer, making it a valuable resource for the data privacy and sharing community.

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
