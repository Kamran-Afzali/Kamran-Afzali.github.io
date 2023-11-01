### DataSynthesizer
DataSynthesizer consists of three high-level modules --- DataDescriber, DataGenerator and ModelInspector. The first, DataDescriber, investigates the data types, correlations and distributions of the attributes in the private dataset, and produces a data summary, adding noise to the distributions to preserve privacy. DataGenerator samples from the summary computed by DataDescriber and outputs synthetic data. ModelInspector shows an intuitive description of the data summary that was computed by DataDescriber, allowing the data owner to evaluate the accuracy of the summarization process and adjust any parameters, if desired.



DataSynthesizer is a comprehensive system designed for generating synthetic datasets from private input data. This Python 3-based tool is tailored to work with CSV-formatted private datasets, making it a versatile solution for a wide range of applications.

The process begins with the DataDescriber module, which first processes the input dataset. It identifies the attributes' domains and estimates their distributions, saving this information in a dataset description file. For categorical attributes, DataDescriber computes the frequency distribution, which is represented as a bar chart. The DataGenerator module then samples from this distribution to create the synthetic dataset. Non-categorical numerical and datetime attributes are processed differently, with DataDescriber creating an equi-width histogram to represent their distribution. DataGenerator uses uniform sampling from this histogram during data generation. For non-categorical string attributes, DataDescriber records the minimum and maximum lengths, generating random strings within this length range during data generation.

DataSynthesizer addresses the challenges of data sharing agreements, particularly in fields such as government, social sciences, and healthcare, where strict privacy rules can hinder collaborations. This system can produce structurally and statistically similar datasets while maintaining robust privacy safeguards. Its user-friendly design offers three intuitive operational modes, requiring minimal user input.

The potential applications of DataSynthesizer are diverse, ranging from standalone library usage to integration into comprehensive data sharing platforms. Ongoing efforts are focused on enhancing data owner accessibility and meeting additional requirements. DataSynthesizer is open source, accessible for download at https://github.com/DataResponsibly/DataSynthesizer, making it a valuable resource for the data privacy and sharing community.



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
