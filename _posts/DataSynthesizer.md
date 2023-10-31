### DataSynthesizer

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
