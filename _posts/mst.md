McKenna (2021) introduces a general approach for differentially private synthetic data generation, which involves selecting low-dimensional marginals, adding noise to measure them, and generating synthetic data that preserves these marginals. This approach is implemented in the NIST-MST and MST mechanisms, with the former winning the 2018 NIST contest. Bowen (2019, 2021) provides a comparative evaluation of differentially private synthetic data algorithms, including those from the NIST PSCR challenge, based on data accuracy and usability. Rosenblatt (2020) further evaluates differentially private generative adversarial networks for data synthesis, highlighting the need for effective assessment and proposing the QUAIL ensemble-based modeling approach.

Our approach to di erentially private synthetic data generation consists of three highlevel steps, as show in Figure 1: (1) query selection, (2) query measurement and (3) synthetic data generation. For step (1), there are various ways to approach query selection; a domain expert familiar with the data and its use cases can specify the set of queries, or they can be automatically determined by an algorithm. The selected queries are important because they will ultimately determine the statistics for which the synthetic data preserves accuracy. For step (2), after the queries are  xed, they are measured privately with a noise-addition mechanism, in our case, with the Gaussian mechanism. In step (3), the noisy measurements are processed through Private-PGM, a post-processing method that can estimate a high-dimensional data distribution from noisy measurements and generate synthetic data. 


- https://github.com/alan-turing-institute/reprosyn
- https://arxiv.org/abs/2108.04978
- https://app.litmaps.com/seed/47184668?utm_source=litmaps&utm_content=home-seed
- https://elicit.com/?workflow=table-of-papers&run=ff8e68e9-5d2e-4e22-9afd-314251deb473
- https://github.com/ryan112358/private-pgm
- https://arxiv.org/pdf/1901.09136.pdf
