---
layout: post
categories: posts
title: Necessity of Explainable Models in Digital Health  
featured-image: /images/XAI2.png
tags: [Machine Learning, Interpretability, DigitalHealth]
date-string: August 2020
---


# Necessity of Explainable Models in Digital Health

Quantitative health researchers have traditionally used simple parametric models such as general(ized) linear models to conduct statistical inference. However, the recent advent of increased computing power, modern data collection techniques, and improved data storage options has encouraged a rise in the application of machine learning technologies in health research. Machine learning models handle feature interactions and non-linear effects automatically. Models such as support vector machines, gradient boosting, random forests, and neural networks often outperform simpler and more explainable models on many prediction tasks. Machine learning has advantages such as the ability to extract structured knowledge from extensive data while making few formal assumptions. In other words, such algorithmic methods aim to uncover general principles underlying a series of observations without explicit instructions, and let the data “speak for themselves.”

The machine-learning community has widely adopted and cultivated practices that can be used to develop predictive models capable of extrapolating from one set of data to another by making useful predictions for new cases. In the context of health research, and as a crucial avenue to uphold the promises of precision medicine, there is a growing necessity for the implementation of statistical learning procedures that explicitly model and test extrapolation to individuals who have not yet been seen. This speaks to the broader need for models that not only generalize but also adaptively learn patterns that remain valid across heterogeneous populations and evolving data environments.

However, there is an increasing demand for transparency from various stakeholders in health data science. Machine learning models are now being used to make important decisions in critical contexts. There is, therefore, a major risk in developing and implementing decision-making tools whose internal criteria are not justifiable or explainable. In precision medicine, where health professionals require far more information from the model than a simple class allocation to support their decisions (e.g., diagnosis), it is crucial to implement interpretable machine learning algorithms that augment the model’s output with relevant and understandable explanations.

The healthcare system increasingly leverages machine learning for high-stakes decision-making applications that deeply impact members of society. In this context, health authorities should be particularly cautious of black-box machine learning models that lack transparency and accountability, especially when they fail to explain their predictions in a way that humans can understand. Currently, the European Union’s General Data Protection Regulation (GDPR) emphasizes that “The data subject shall have the right not to be subject to a decision based solely on automated processing, including profiling, which produces legal effects concerning him or her or similarly significantly affects him or her” ([Article 22 of GDPR regulations](http://www.privacy-regulation.eu/en/22.htm)). This clause introduces the notion of a ‘right to an explanation’.

In this context, the term ‘explanation’ refers to an understanding of how a model works, and is closely aligned with concepts of interpretability, comprehensibility, and transparency. Several motivations justify the push toward interpretable machine learning models: (1) interpretable models ensure impartiality in decision-making by facilitating the detection and correction of algorithmic biases; (2) by highlighting potential adversarial perturbations that could substantially change the prediction, interpretability helps to ensure model robustness; (3) interpretability offers a means to approximate whether the model’s decision process aligns with known or hypothesized causal mechanisms, thereby acting as a potential warranty that only meaningful variables influence the output.

The current generation of Explainable AI (XAI) systems aims to develop techniques that enhance the interpretability of models while maintaining high levels of learning performance. This goal reflects the need for domain experts to understand, trust, and appropriately manage the emerging generation of intelligent computational partners. Although linear and parametric models provide numerical values reflecting the contribution of each feature in the prediction process, this is not the case for most non-linear machine learning models. These more complex models generally lack intelligible parameters, making it more difficult to extract transparent and actionable insights.

To address this issue, researchers have developed **model-agnostic techniques for post-hoc interpretability** that can be applied to any black-box model, regardless of its internal structure. These methods aim to simplify relationships between certain features and the target variable, achieving tractability and reduced complexity by strategies such as marginalizing performance over other features, systematically manipulating inputs, or visualizing effects to better understand the model’s behavior. Because model-agnostic interpretability separates the explanation layer from the model itself, it provides more flexibility compared to model-specific approaches.

Prominent techniques for estimating global feature effects include:

* **Permutation Feature Importance (PFI)**, which measures the difference between a baseline performance score and the same score after permuting values of a given feature in the validation data.
* **Partial Dependence Plots (PDPs)**, which reveal whether the marginal effect of a feature on the predicted outcome is linear, monotonic, or more complex.
* **Individual Conditional Expectation (ICE) plots**, which explore how a specific instance's prediction changes when one feature varies while others are fixed.

These techniques are complemented by local interpretability tools such as **LIME** and **SHAP**, which offer instance-specific explanations by approximating the model locally with simpler, interpretable models.

The implementation of interpretability pipelines directly addresses concerns and may enhance the adoption of machine learning by healthcare organizations and policymakers who demand a higher degree of accountability. Moreover, explainability is not only a desirable attribute but may be legally mandated. If such efforts do not succeed, black-box models may continue to be deployed in contexts where their opacity renders them unsafe or ethically problematic. Furthermore, suboptimal interpretability pipelines could lead to legal conflicts with regulations such as the ‘right to explanation’ and hinder public trust in AI-assisted health interventions. The current convergence of technological capability, ethical imperatives, and legal frameworks underscores the urgent necessity of shifting focus from mere performance metrics to explainability in health data science. This shift is especially important in domains where predictions directly affect clinical judgment, treatment pathways, or policy decisions. Explainable models are not just a technical convenience—they are a prerequisite for socially responsible AI in healthcare.



## Summary Table: Necessity of Explainable AI in Health Data Science

| **Dimension**                      | **Current Challenges**                                                    | **Explainability Solutions**                                                | **Benefits**                                              |
| ---------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------- |
| **Model Complexity**               | Non-linear ML models lack transparent parameters                          | Post-hoc model-agnostic tools (e.g., PDP, ICE, SHAP)                        | Improves understanding and usability of model predictions |
| **Legal Compliance**               | GDPR restricts automated decision-making without explanation              | “Right to an explanation” mandates interpretable model behavior             | Ensures legal alignment and prevents regulatory conflicts |
| **Bias and Fairness**              | Undetected algorithmic bias can lead to inequitable outcomes              | Interpretability reveals bias pathways                                      | Facilitates fair, equitable healthcare delivery           |
| **Robustness and Security**        | Susceptibility to adversarial perturbations                               | Explains model sensitivity and variance                                     | Increases model reliability under distributional shifts   |
| **Causal Interpretability**        | Lack of causal insight undermines clinical trust                          | Interpretability helps approximate meaningful feature–outcome relationships | Supports evidence-based medical reasoning                 |
| **Stakeholder Trust and Adoption** | Health professionals wary of black-box tools                              | Transparency fosters user engagement                                        | Increases stakeholder buy-in and ethical accountability   |
| **Generalization to New Cases**    | Poor extrapolation to unseen patients undermines precision medicine goals | Explicit modeling of generalization and covariate influence                 | Enhances relevance to diverse patient populations         |

