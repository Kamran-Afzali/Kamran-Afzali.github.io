McKenna (2021) introduces a general approach for differentially private synthetic data generation, which involves selecting low-dimensional marginals, adding noise to measure them, and generating synthetic data that preserves these marginals. This approach is implemented in the NIST-MST and MST mechanisms, with the former winning the 2018 NIST contest. Bowen (2019, 2021) provides a comparative evaluation of differentially private synthetic data algorithms, including those from the NIST PSCR challenge, based on data accuracy and usability. Rosenblatt (2020) further evaluates differentially private generative adversarial networks for data synthesis, highlighting the need for effective assessment and proposing the QUAIL ensemble-based modeling approach.

Our approach to di erentially private synthetic data generation consists of three highlevel steps, as show in Figure 1: (1) query selection, (2) query measurement and (3) synthetic data generation. For step (1), there are various ways to approach query selection; a domain expert familiar with the data and its use cases can specify the set of queries, or they can be automatically determined by an algorithm. The selected queries are important because they will ultimately determine the statistics for which the synthetic data preserves accuracy. For step (2), after the queries are  xed, they are measured privately with a noise-addition mechanism, in our case, with the Gaussian mechanism. In step (3), the noisy measurements are processed through Private-PGM, a post-processing method that can estimate a high-dimensional data distribution from noisy measurements and generate synthetic data. 

Private-PGM is a synthetic data generator that uses a differentially private approach to generate synthetic data while preserving privacy. It is based on the paper "Graphical-model based estimation and inference for differential privacy" by McKenna, Sheldon, and Miklau[1]. The algorithm consists of three main steps:

1. Select a collection of low-dimensional marginals.
2. Measure those marginals with a noise addition mechanism.
3. Generate synthetic data that preserves the measured marginals well[1].

Private-PGM is a post-processing method used to estimate a high-dimensional data distribution from noisy measurements of its marginals[1]. It has been successfully applied in various settings, including the 2018 NIST differential privacy synthetic data competition, where it was the winning mechanism[1].

The main idea behind Private-PGM is to construct a probabilistic graphical model (PGM) that captures the dependencies between attributes in the data. This model is then used to generate synthetic data that maintains the correlations between attributes while satisfying differential privacy guarantees[1].

To use Private-PGM for synthetic data generation, you can refer to the GitHub repository (https://github.com/ryan112358/private-pgm) which provides an implementation of the tools described in the paper[1]. The repository also includes examples and mechanisms for different problems, making it easier for users to learn how to use the codebase and build their own mechanisms on top of it[1].

The Private-PGM synthetic data generator is a key component in the development of differentially private synthetic data. It is a post-processing method that estimates a high-dimensional data distribution from noisy measurements of its marginals (McKenna, 2021). This approach is particularly effective in preserving the statistical properties of the original data while ensuring privacy. It has been successfully applied in various domains, including health record data, where it outperformed existing models in terms of data quality and model performance (Torfi, 2022). The Private-PGM synthetic data generator is a significant advancement in the field of privacy-preserving data generation, offering a scalable and general approach that can be adopted in future mechanisms for synthetic data generation (McKenna, 2021).

The Private-PGM algorithm works in two main steps:

1. **Measurement:** This step involves selecting a collection of low-dimensional marginals and measuring them with a noise addition mechanism to ensure differential privacy. The selection of marginals is crucial as it determines the attributes that will be preserved in the synthetic data. The noise addition mechanism is typically a Laplace or Gaussian mechanism, which adds random noise to the true values of the marginals to prevent the disclosure of individual data points.

2. **Synthetic Data Generation:** In this step, a probabilistic graphical model (PGM) is constructed based on the noisy measurements of the marginals. The PGM captures the dependencies between the attributes in the data. Synthetic data is then generated from this model, preserving the measured marginals well.

The pseudo code for the Private-PGM algorithm can be outlined as follows:

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

This pseudo code provides a high-level overview of the Private-PGM algorithm. The actual implementation would involve more detailed steps, such as the specific method for constructing the PGM and the method for sampling from the PGM to generate synthetic data[1][4].



Citations:
- [1] https://github.com/ryan112358/private-pgm
- [2] https://arxiv.org/pdf/2108.04978.pdf
- [3] https://github.com/BorealisAI/private-data-generation
- [4] https://differentialprivacy.org/synth-data-1/
- [5] https://arxiv.org/pdf/2310.20062.pdf
- [6] https://pages.nist.gov/privacy_collaborative_research_cycle/pages/techniques.html
- [7] https://arxiv.org/abs/2108.04978
- [8] https://www.vldb.org/pvldb/vol16/p1573-pujol.pdf
- [9] https://arxiv.org/pdf/2310.03447.pdf
- [10] https://arxiv.org/pdf/2201.12677.pdf
- [11] https://www.usenix.org/system/files/sec21fall-zhang-zhikun.pdf
- [12] https://youtube.com/watch?v=UKzh9QgNRxA
- [13] https://journalprivacyconfidentiality.org/index.php/jpc/article/view/778
- [14] https://openreview.net/pdf?id=B9R1uLC1B1
- [15] https://programming-dp.com/ch14.html
- [16] https://aaai-ppai22.github.io/files/26.pdf


- [1] https://github.com/ryan112358/private-pgm
- [2] https://openreview.net/forum?id=comGUyv5sac
- [3] https://proceedings.mlr.press/v202/liu23ag/liu23ag.pdf
- [4] https://arxiv.org/pdf/1901.09136.pdf
- [5] https://arxiv.org/pdf/2109.06153.pdf
- [6] https://openreview.net/forum?id=5JdyRvTrK0q
- [7] https://openreview.net/pdf?id=comGUyv5sac
- [8] https://www.usenix.org/system/files/sec21fall-zhang-zhikun.pdf
- [9] https://arxiv.org/pdf/2106.07153.pdf
- [10] https://journalprivacyconfidentiality.org/index.php/jpc/article/download/778/727/1684
- [11] https://www.vldb.org/pvldb/vol14/p2190-cai.pdf
- [12] https://www.usenix.org/system/files/sec21-zhang-zhikun.pdf
- [13] https://differentialprivacy.org/synth-data-1/
- [14] https://arxiv.org/pdf/2108.04978.pdf
- [15] https://youtube.com/watch?v=UKzh9QgNRxA
- [16] https://journalprivacyconfidentiality.org/index.php/jpc/article/view/778
- [17] https://pages.nist.gov/privacy_collaborative_research_cycle/pages/techniques.html


- https://github.com/alan-turing-institute/reprosyn
- https://arxiv.org/abs/2108.04978
- https://app.litmaps.com/seed/47184668?utm_source=litmaps&utm_content=home-seed
- https://elicit.com/?workflow=table-of-papers&run=ff8e68e9-5d2e-4e22-9afd-314251deb473
- https://github.com/ryan112358/private-pgm
- https://arxiv.org/pdf/1901.09136.pdf
