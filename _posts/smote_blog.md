

SMOTE (Synthetic Minority Over-sampling Technique) is a technique used for generating synthetic data in order to address the problem of class imbalance in machine learning. It is a type of data augmentation for the minority class and is used to oversample the minority class by creating synthetic examples. SMOTE works by selecting examples that are close in the feature space, drawing a line between the examples in the feature space, and drawing a new sample at a point along that line. Specifically, a random example from the minority class is chosen, then k of the nearest neighbors for that example are found (typically k=5) and a synthetic example is created at a randomly selected point between the two examples in feature space.

- The algorithm selects a random example from the minority class and selects random neighbors using K Nearest Neighbors. 
- The synthetic example is created between two examples in the feature space.

There are some variations of SMOTE, such as ADASYN (Adaptive Synthetic Sampling Method), which is a modification of SMOTE that generates more synthetic examples near the boundary of the minority class. In the litterature SMOTE is presented as a powerful solution for imbalanced data, but it has a drawback. It does not consider the majority class while creating synthetic examples, which can cause issues where there is a strong overlap between the classes. Therefore, the original SMOTE paper suggests combining oversampling (SMOTE) with the undersampling of the majority class, as SMOTE does not consider the majority class while creating new samples. To better underestand the algorithm below is a pseudocode for the SMOTE (Synthetic Minority Over-sampling Technique) algorithm:

```
function SMOTE(dataset, minority_class, N, k):
    synthetic_samples = []

    for each sample in minority_class:
        neighbors = k_nearest_neighbors(sample, dataset, k)
        
        for i in range(N):
            neighbor = randomly_select_neighbor(neighbors)
            synthetic_sample = generate_synthetic_sample(sample, neighbor)
            synthetic_samples.append(synthetic_sample)

    return synthetic_samples

function k_nearest_neighbors(sample, dataset, k):
    distances = compute_distances(sample, dataset)
    sorted_neighbors = sort_by_distance(distances)
    return sorted_neighbors[:k]

function randomly_select_neighbor(neighbors):
    return randomly_pick_one_neighbor(neighbors)

function generate_synthetic_sample(sample, neighbor):
    synthetic_sample = {}
    
    for each feature in sample:
        difference = neighbor[feature] - sample[feature]
        synthetic_sample[feature] = sample[feature] + random_uniform(0, 1) * difference

    return synthetic_sample
```

In this pseudocode:
- `dataset` is the entire dataset.
- `minority_class` is the class that is in the minority (you apply SMOTE to balance it with the majority class).
- `N` is the number of synthetic samples to generate for each original minority class sample.
- `k` is the number of nearest neighbors to consider when generating synthetic samples.

As mentioned above basic steps of SMOTE involve selecting a sample from the minority class, finding its k-nearest neighbors, and creating synthetic samples by combining features from the selected sample and its neighbors.


Primarily SMOTE has been used in medical applications to improve classification performance over imbalanced medical datasets. However, it found applications beyond initial domain for which it is developped. It can be used for synthetic data generation in medical applications, and there are several studies that have used SMOTE for this purpose. For instance, a study used SMOTE to generate synthetic data for predictive models in low-middle-income countries, while study used SMOTE to generate high-fidelity synthetic patient data for assessing machine learning healthcare software. Additionally, a novel algorithm called SMOTE-ENC was proposed to generate synthetic data for nominal and continuous features in medical imbalanced data. Buliding on the SMOTE capabilites, another novel approach called Data Collaboration (DC) analysis has emerged, enabling privacy-conscious joint analysis across diverse institutions. This method aggregates dimensionality-reduced representations and facilitates comprehensive analysis through collaborative representations, all while safeguarding the original data. Typically, each institution contributes a shareable  dataset and consolidates its intermediate representation for this integrated analysis. 


    

## References

- [Synthesizing Electronic Health Records for Predictive Models in Low-Middle-Income Countries (LMICs)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10295936/) 
- [Generating high-fidelity synthetic patient data for assessing machine learning healthcare software](https://www.nature.com/articles/s41746-020-00353-9)
- [SMOTE-ENC: A Novel SMOTE-Based Method to Generate Synthetic Data for Nominal and Continuous Features](https://www.mdpi.com/2571-5577/4/1/18)
- [RSMOTE: improving classification performance over imbalanced medical datasets](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7292850/)
- [Another use of SMOTE for interpretable data collaboration analysis](https://www.sciencedirect.com/science/article/pii/S0957417423008874)
