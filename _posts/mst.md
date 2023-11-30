## Introduction 

McKenna (2021) introduces a general approach for differentially private synthetic data generation, which involves selecting low-dimensional marginals, adding noise to measure them, and generating synthetic data that preserves these marginals. This approach to dierentially private synthetic data generation consists of three highlevel steps. Step (1), A domain expert familiar with the data and its use cases can specify the set of queries, or they can be automatically determined by an algorithm. The selected queries are important because they will ultimately determine the statistics for which the synthetic data preserves accuracy. Step (2), after the queries are set, privay is augmented with a noise-addition mechanism, here, the Gaussian mechanism. In step (3), the noisy measurements are processed to estimate a high-dimensional data distribution from noisy measurements and generate synthetic data. This procedure is based on the Private-PGM, a synthetic data generator that uses a differentially private approach to generate synthetic data while preserving privacy. The algorithm consists of three main steps:

1. Select a collection of low-dimensional marginals.
2. Measure those marginals with a noise addition mechanism.
3. Generate synthetic data that preserves the measured marginals well.


The main idea behind Private-PGM is to construct a probabilistic graphical model (PGM) that captures the dependencies between attributes in the data. This model is then used to generate synthetic data that maintains the correlations between attributes while satisfying differential privacy guarantees. To use Private-PGM for synthetic data generation, you can refer to the [GitHub repository](https://github.com/ryan112358/private-pgm) which provides an implementation of the tools described in the paper. The repository also includes examples and mechanisms for different problems, making it easier for users to learn how to use the codebase and build their own mechanisms on top of it. This approach is particularly effective in preserving the statistical properties of the original data and has been successfully applied in various domains, including health record data, where it outperformed existing models in terms of data quality and model performance (Torfi, 2022). 


Below is the pseudo code for the Private-PGM algorithm can be outlined as follows:

```python
# Pseudo code for Private-PGM algorithm

# Step 1: Measurement
function MeasureMarginals(data, marginals, epsilon):
    noisy_marginals = {}
    for marginal in marginals:
        true_value = computeMarginal(data, marginal)
        noise = generateNoise(epsilon)  # Laplace or Gaussian noise
        noisy_marginals[marginal] = true_value + noise
    return noisy_marginals

# Step 2: Synthetic Data Generation
function GenerateSyntheticData(noisy_marginals):
    # Construct a PGM based on the noisy marginals
    pgm = constructPGM(noisy_marginals)
    # Generate synthetic data from the PGM
    synthetic_data = sampleFromPGM(pgm)
    return synthetic_data

# Main function
function PrivatePGM(data, marginals, epsilon):
    noisy_marginals = MeasureMarginals(data, marginals, epsilon)
    synthetic_data = GenerateSyntheticData(noisy_marginals)
    return synthetic_data
```

This pseudo code provides a high-level overview of the Private-PGM algorithm. The actual implementation would involve more detailed steps, such as the specific method for constructing the PGM and the method for sampling from the PGM to generate synthetic data.

## Clover implementation 


    class MSTGenerator(Generator):
    """
    Wrapper of the Maximum Spanning Tree (MST) method from Private-PGM repo:
    https://github.com/ryan112358/private-pgm/tree/master.

    :cvar name: the name of the metric
    :vartype name: str

    :param df: the data to synthesize
    :param metadata: a dictionary containing the list of **continuous** and **categorical** variables
    :param random_state: for reproducibility purposes
    :param generator_filepath: the path of the generator to sample from if it exists
    :param epsilon: the privacy budget of the differential privacy
    :param delta: the failure probability of the differential privacy
    """

  

## References:
- [Winning the NIST Contest: A scalable and general approach to differentially private synthetic data](https://arxiv.org/pdf/2108.04978.pdf)
- [A simple recipe for private synthetic data generation](https://differentialprivacy.org/synth-data-1/)
- [Privacy Techniques in the CRC Collection So Far](https://pages.nist.gov/privacy_collaborative_research_cycle/pages/techniques.html)
- [Privately Generating Justifiably Fair Synthetic Data](https://www.vldb.org/pvldb/vol16/p1573-pujol.pdf)
- [DataSynthesisviaDifferentiallyPrivateMarkovRandomFields](https://www.vldb.org/pvldb/vol14/p2190-cai.pdf)
- [Decentralised, Scalableand Privacy-Preserving Synthetic Data Generation](https://arxiv.org/pdf/2310.20062.pdf)
- [FLAIM: AIM-based synthetic data generation in the federated setting](https://arxiv.org/pdf/2310.03447.pdf)
- [AIM: An Adaptiveand Iterative Mechanism for Differentially Private Synthetic Data](https://arxiv.org/pdf/2201.12677.pdf)
- [Graphical-model based estimation and inference for differential privacy](https://arxiv.org/pdf/1901.09136.pdf)
- [Relaxed Marginal Consistency for Differentially Private Query Answering](https://arxiv.org/pdf/2109.06153.pdf)
- [Marginal-based Methods for Differentially Private Synthetic Data](https://youtube.com/watch?v=UKzh9QgNRxA)
- [Synthetic Data](https://programming-dp.com/ch14.html)
- [Priv Syn:Differentially Private Data Synthesis](https://www.usenix.org/system/files/sec21fall-zhang-zhikun.pdf)



- https://github.com/alan-turing-institute/reprosyn
- https://github.com/ryan112358/private-pgm
- https://github.com/BorealisAI/private-data-generation
- https://github.com/alan-turing-institute/reprosyn

