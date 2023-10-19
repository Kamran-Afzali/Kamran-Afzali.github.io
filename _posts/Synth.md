## [Synthetic data as an enabler for machine learning applications in medicine](https://www.cell.com/iscience/fulltext/S2589-0042(22)01603-0_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS2589004222016030%3Fshowall%3Dtrue)

### **Introduction**

The use of health data for innovation and enhancing care has been a long-standing topic. AI and machine learning (ML) have opened exciting prospects for utilizing health system data to offer decision support for clinicians, develop better treatments, and enhance overall system efficiency. However, achieving widespread innovation and adoption encounters substantial challanges. ML applications are highly data-dependent, necessitating a resolution for the challenge of data accessibility.

Privacy concerns are major issues to health data sharing and access. Obtaining datasets for research projects from authors of published studies is an option, but it is often inefficient and unsuccessful. The _'privacy chill'_, a slowdown or complete restriction on health data sharing, has been identified to have detrimental effects on response to health crises like the COVID-19 pandemic and on recruiting and retaining talented health data scientists.


### **Definition and Categorization of Synthetic Data**

The term "synthetic data" is often defined based on the US Census Bureau's perspective, emphasizing the generation of new data values using statistical models that replicate the statistical properties of original data. This strategic use of synthetic data aims to enhance data utility while safeguarding privacy and confidentiality. Depending on the generation method, synthetic datasets can offer reverse disclosure protection, allowing appropriate multivariate analyses while preventing inferences about parameters in statistical models.

Synthetic data is broadly categorized into three types: fully synthetic, partially synthetic, and hybrid. Fully synthetic data involves creating entirely fabricated data, devoid of any real data, providing strong privacy control but limited analytic value due to data loss. Partially synthetic data replaces sensitive variables with synthetic versions while retaining original values, posing some reidentification risk. Hybrid synthetic data combines original and synthetic data, balancing privacy control and utility, albeit with increased processing time and memory requirements.

The UK's Office for National Statistics (ONS) has delineated a detailed spectrum of synthetic data types, ranging from the lowest, purely synthetic structural dataset developed using metadata only (with minimal analytic value and no disclosure risk), to a replica level synthetically-augmented dataset that closely mirrors real data, preserving format, structure, joint distribution, patterns, and geographies at the cost of higher disclosure risks. This categorization aids in understanding the varying utility and privacy aspects of synthetic data across different levels of replication and augmentation.

### **Exploring Opportunities in Synthetic Data Generation**

Synthetic data has emerged as a tool addressing three main challenges in healthcare data. Primarily, it safeguards individual privacy and record confidentiality by generating data that is difficult to re-identify, being a blend of "fake" and original data. Secondly, it enhances accessibility to health data for researchers and various users due to minimal disclosure risk in synthesized datasets. This opens doors for a broader array of users, accelerating research. Thirdly, synthetic data fills the void of realistic data for software development and testing, providing cost-effective and authentic test data for software applications.

Leveraging synthetic data offers substantial opportunities to support data infrastructure, especially in confronting emerging health challenges. For instance, restrictions on sharing mental health data, like opioid use disorder (OUD) records, have impeded research and public health initiatives. Synthetic longitudinal records, mirroring individuals diagnosed with OUD and those lost to opioid overdose, provide essential data for pattern analysis, risk identification, policy simulations, and program evaluation. Synthetic data proves crucial in studying communicable diseases and stigmatized populations like those diagnosed with HIV, where data sharing barriers persist.

Synthetic data presents a compelling array of benefits, making it an attractive option for a wide range of applications. It significantly streamlines the processes involved in training, testing, and deploying AI solutions, promoting more efficient and effective development. Furthermore, this cutting-edge technology plays a crucial role in reducing the risk of exposing sensitive information, thereby ensuring customer security and privacy. As researchers transition synthetic data from the lab to practical implementations, its real-world applications continue to expand. This section delves into several noteworthy domains where synthetic data generation significantly impacts addressing real-world challenges. Here we go through some of of the opportunities in synthetic Data generation:

#### **Fostering Data Sharing**

Sharing real data for secondary purposes can often be afeected by regulatory and ethical considerations, resulting in delays or denials in data access. Synthetic data emerges as a promising alternative in such scenarios. When crafted to mimic real datasets, synthetic data retains valuable information such as feature correlations and parameter distributions. It is not only valuable for training statistical models but also facilitates hypothesis generation and educational purposes. Recent advancements in Synthetic Data Generation (SDG), particularly through deep learning generative models, have shown remarkable progress. In the medical domain, SDG is notably relevant for generating tabular and time series data, crucial for electronic health records and biometric measurements. Sharing synthetic data offers the potential for more generalizable analyses and aids in reproducibility when real data sharing is limited or not feasible.

#### **Safeguarding Privacy**

Privacy, primarily protecting against unexpected access to sensitive information, is a critical concern. Patient information is highly sensitive, making de-identification methods vulnerable to privacy leaks. Synthetic data approaches often aim to reproduce populations rather than individuals, reducing the risk of privacy leaks. A recent study demonstrated that synthetic data generated from clinical data significantly protects against identity disclosure, falling below accepted risk thresholds. Although privacy is intricately linked with legal issues and enforcement, proper implementation of synthetic data can reduce privacy risks.

#### **Augmenting Data for Medical Applications**

Datasets for medical applications are often limited in size due to the requirements for data collection and annotation. Data augmentation, including SDG, provides a solution to augment dataset size without the need for extensive data collection. SDG optimizes statistical information extraction from real data, especially in medical imaging. By incorporating synthetic data into the training set alongside real data, the performance of machine learning models can be enhanced significantly. ML algorithms may exhibit bias, particularly when trained on imbalanced datasets. Underrepresented groups may suffer from poor model performance. Data augmentation, including synthetic data, can address this issue by augmenting underrepresented groups, improving model performance for each subgroup. Synthetic data can be used to augment rare subtypes of data, enhancing the accuracy and representativity of ML models.

#### [Utilizations of Synthetic Health Data](https://doi.org/10.1371/journal.pdig.0000082)

Here are some other utilizations of Synthetic Health Data

**1. Simulation Studies and Predictive Analytics:**
Simulation and prediction research necessitate extensive datasets for accurate prediction of behaviors and outcomes. Synthetic data, based on real datasets, can act as a supplement or substitute for real data, aiding researchers in expanding sample sizes or adding variables not present in the original set. It has been used in disease-specific hybrid simulation, microsimulation for policy testing, and health care financing strategy evaluation.

**2. Algorithm, Hypothesis, and Methods Testing:**
Synthetic data mirroring the format and structure of real data enables researchers to explore variables, assess dataset feasibility, and test hypotheses before accessing the actual dataset. It offers an additional level of validation and comparison for testing methods and algorithms beneficial for machine learning techniques development.

**3. Epidemiological Study/Public Health Research:**
Synthetic data proves valuable in epidemiology and public health studies where real datasets may be limited, challenging to obtain due to privacy concerns, or expensive. Synthetic datasets, especially during health emergencies like the COVID-19 pandemic, improve data timeliness, support real-time computational epidemiology, and enhance disease detection algorithms.

**4. Health IT Development and Testing:**
In health IT development, synthetic data serves as a crucial tool for software testing, significantly reducing cost, time, and labor. It provides developers with realistic datasets without privacy concerns, expediting the development lifecycle.

**5. Education and Training:**
In educational settings, synthetic data is instrumental in training students, especially in fields like data science and health economics. It allows students to access a large number of realistic datasets, essential for learning and skill development.

**6. Public Release of Datasets:**
Releasing health datasets for public use while preserving analytical value and ensuring confidentiality is a challenge. Partially synthesized data can mitigate disclosure risks while still allowing users to obtain valid inferences comparable to real data.

**7. Linking Data:**
Synthetic data is widely used to test, validate, and evaluate various data linkage methods, frameworks, and algorithms. It aids in comparing the performance of different algorithms in terms of linkage accuracy and speed.



### **Challenges in Synthetic Medical Data Generation**

Although synthetic data presents immense promise in healthcare, overcoming critical challenges while offering a wealth of opportunities, addressing its limitations and ensuring validation frameworks are crucial for maximizing its potential in transforming healthcare data infrastructure and research. Researchers and data users need to consider these factors and validation results when utilizing specific synthetic datasets. Synthetic data strives to provide artificial variables to preserve record confidentiality, but there's a risk of original data leakage. Adversarial machine learning techniques and data outliers can compromise the confidentiality intended by synthetic data. Additionally, not all synthetic data accurately replicate the content and properties of the original dataset, limiting its use in clinical research. Addressing these limitations requires thorough validation of synthetic data and the models used for its generation. Presently, there's a lack of standardized benchmarks for validation. Various frameworks and approaches have been proposed to validate the realism of synthetic data, comparing synthetic data results with real-world data to assess accuracy. Clinical quality measures have been suggested as a validation approach, aiding in understanding the limitations of synthetic data in modeling diverse outcomes.

Addressing these challenges is crucial to harnessing the complete potential of machine learning and its impact on various industries. Synthetic data, artificially generated through computer algorithms or simulations, plays a vital role, especially when real data is either unavailable or needs to be kept private. This paper aims to provide a comprehensive overview of state-of-the-art approaches for synthetic data generation in machine learning research, covering domains, generative models, privacy concerns, evaluation strategies, and future research avenues. Here we go through some of of the challenges in synthetic Data generation:

#### **Evaluating Quality**

The quality of synthetic medical data is often categorized by three key qualities: fidelity, diversity, and generalization. Fidelity concerns the quality of the samples, distinguishing them from real samples and enabling valid population inferences. Computational and human evaluations are common methods to measure fidelity, involving comparing statistical model parameter estimates and utilizing distance metrics between distributions of real and synthetic data. Diversity gauges the coverage of the real data population, ensuring subgroups aren't underrepresented. Generalization is tied to privacy concerns, determining whether synthetic data accurately mirrors real data.

**Evaluation Approaches**

In this section, we explore different methodologies for assessing the quality of synthetic data, a crucial aspect in ascertaining the effectiveness and relevance of synthetic data generation techniques in real-world contexts. We classify these assessment approaches as follows:

1. **Human Assessment**: Directly evaluating synthesized data involves seeking feedback from domain experts or non-experts to judge aspects like similarity to real data, usability in specific applications, or overall quality. For instance, in speech synthesis, evaluators blindly rate both synthesized and real human speech. However, this method has drawbacks, including high cost, time intensiveness, susceptibility to errors, and limited scalability. It's particularly challenging for high-dimensional data not easily visualized by humans.

2. **Statistical Comparison**: This approach entails calculating diverse statistical metrics on both synthetic and real datasets and comparing the outcomes. For example, statistics on features like medical concept frequency or patient-level clinical attributes can be employed to evaluate generated electronic health record (EHR) data. Smaller differences in statistical properties between synthetic and real data indicate higher quality in the synthetic dataset.

3. **Model-based Evaluation**: Utilizing a pre-trained machine learning model, especially the discriminator in Generative Adversarial Networks (GANs), helps distinguish between synthetic and real data. The performance of the discriminator on synthetic data serves as an indicator of the realism achieved by the generator, allowing assessment not only in GANs but also in other generative models using pre-trained machine learning models.

4. **Training and Testing on Real Data**: Here, synthetic data is utilized to train machine learning models, and their predictive performance is evaluated on real test data in downstream applications. Strong performance on real test data suggests successful capture of essential real data characteristics, establishing synthetic data as a valuable proxy for training. This strategy offers insights into the effectiveness of synthetic data in training machine learning models across various tasks and domains.

5. **Domain-specific Evaluation**: Depending on the specific domain or application, specialized evaluation techniques tailored to unique requirements, like regulatory compliance, privacy considerations, or specific performance metrics, may be employed to assess the synthesized data's quality. By evaluating synthesized data in its intended use context, a more precise assessment of its quality and suitability can be achieved.

These evaluation strategies offer diverse avenues to measure the quality of synthesized data, aiding researchers and professionals in determining the efficacy of synthetic data generation methods in real-world scenarios. Employing a blend of these strategies can furnish a comprehensive understanding of the synthetic data's strengths and weaknesses, facilitating ongoing enhancements in synthetic data generation techniques.


#### **Implementing and Evaluating Privacy**

Privacy evaluation typically involves privacy attacks like data extractions, model inversions, and Membership Inference Attacks (MIA). MIA assesses if a data sample was used for training an SDG model. There's a privacy-transparency trade-off, especially when sharing components of the SDG generation process. Federated learning is considered a privacy-preserving alternative, but careful implementation is necessary to avoid vulnerabilities. Balancing utility and privacy is crucial in producing good synthetic data, often involving a trade-off. Methods like k-anonymization impact data utility, and there's a constant challenge of predicting which data characteristics are preserved through SDG while balancing privacy and utility.

#### **Mitigating Bias Amplification**

Synthetic data inherits biases present in the real data on which it's based. Biases are prevalent in real datasets due to the entire data production pipeline, and SDG can inadvertently magnify these biases. Underrepresented groups in real data may be overlooked during the SDG process, further exacerbating biases. The correlation fallacy, confusing correlation with causation, is another bias source. Addressing biases, evaluating fairness, and minimizing their amplification in synthetic datasets are ongoing research objectives.
The challenge of fairness arises when generating synthetic data that accurately reflects the key statistical characteristics of real-world data. However, these synthetic datasets can inadvertently carry biases from data preprocessing, collection methods, and the algorithms used. Addressing fairness in synthetic data involves three main methods: preprocessing, in-processing, and postprocessing. Preprocessing modifies the input data to eliminate correlations with sensitive attributes, often using techniques like massaging, reweighting, or sampling. In contrast, in-processing integrates fairness constraints into the model learning process, while postprocessing adjusts model predictions after training. Existing fairness-aware data synthesis methods primarily utilize preprocessing techniques, leveraging balanced synthetic datasets from Generative Adversarial Networks (GANs) to mitigate disparate impact caused by imbalances in minoritized subgroups.

However, the preprocessing approach requires prior knowledge of all correlations, biases, and variable distributions in existing datasets. The latter two methods (in-processing and postprocessing) are less developed for ensuring fairness in synthetic data. Additionally, the introduction of differential privacy amplifies fairness concerns in the original data, particularly affecting the influence of majority subgroups and reducing synthetic data utility in downstream tasks. Fairness metrics for synthesized data have been proposed to analyze covariate-level disparities, considering protected attributes to assess bias. It's crucial to regulate the real-world data used to create the synthetic data distribution, ensuring the quality and minimizing biases. Moreover, ongoing scrutiny and the removal of sensitive and toxic information from both data and models are necessary to govern the outcomes generated by foundation models and prevent harm and discrimination.

### **Futur direction**

Synthetic Data Generation holds a great potential in the healthcare domain by applications like training in clinical data sciences and testing ML-based clinical decision support tools. It acts as a crucial tool for safeguarding patient privacy, enhancing small datasets, and mitigating bias against different subgroups. In today's data-centric world, revisiting the opportunities and challenges of synthetic health data is crucial. Privacy concerns related to AI and data collection emphasize the urgent need to bridge the accountability gap, making privacy legislation and AI regulations a priority globally. The  COVID-19 pandemic has shed light on how limited data access slows down real-time monitoring and a coordinated public health response. Leveraging data science and ML for improved healthcare necessitates investing in research and development of synthetic data techniques, bringing a balance between innovation and health data privacy. With data-sharing regulations tightening, adopting privacy-enhancing technologies like SDG is crucial. Accelerated development of evaluation frameworks for utility and privacy in synthetic data is a fundamental step toward enhancing SDG methods and facilitating informed decisions for data custodians.






















## BREAK

In today's era of digitalization and Big Data, there is a growing demand for innovative AI algorithms. However, the development and application of these technologies require access to data. Unfortunately, various challenges related to privacy, intellectual property, and security often hinder data sharing. These challenges are particularly prominent in the healthcare sector, where data is highly sensitive. Overcoming these barriers to data sharing, while preserving the privacy and rights of individuals, is crucial to advancing research in this field.

Synthetic Tabular Data Generation (STDG) techniques have emerged as a promising solution to address these data-sharing challenges. The main objective of this systematic review is to provide an overview of STDG approaches, particularly in healthcare applications where tabular data needs to be generated. Special attention is given to Generative Adversarial Networks (GANs) due to their recent success in similar applications.

Healthcare data plays a vital role in the development of AI-based healthcare systems, and structured data, often in tabular format, is the most common data source for these applications. This structured health data offers valuable opportunities, and progress in this domain is critical. Tabular healthcare data, typically sourced from Electronic Health Records (EHR), clinical trials, or laboratories, contains a wealth of patient-related information, including explicit identifiers, quasi-identifiers, and sensitive attributes. These data are integral to healthcare research and AI development.

Privacy in the healthcare sector is a complex issue, governed by contextual rules that regulate the flow of information to maintain the security and confidentiality of patient records. Violations of these rules, termed "invasions of privacy" or "violations of privacy," lead to the disclosure of personal information intended to be kept private from unauthorized entities. Privacy threats include identity disclosure, attribute disclosure, and membership disclosure, with adversaries using various techniques to compromise patient privacy.

In this landscape, STDG techniques offer a promising way to generate synthetic tabular data that can be shared for research and development purposes while safeguarding patient privacy. The review classifies various STDG algorithms into distinct groups but notes a lack of evaluation regarding their privacy-preserving capabilities and performance metrics. The development of standardized benchmarks and metrics is essential to assess these algorithms effectively and to drive improvements in the field.

In summary, the study contributes valuable insights to the scientific community by classifying and evaluating STDG techniques, with a focus on their resemblance, utility, and privacy dimensions. These findings can aid researchers in developing AI-based applications without compromising user privacy and provide guidance in addressing research challenges. To advance intelligent healthcare applications while preserving patient privacy, the widespread use of fully synthetic tabular data is crucial.


### Other paper 

The exploration of leveraging health data for innovation and enhancing care has been a long-standing topic. AI and machine learning (ML) have opened exciting prospects for utilizing health system data to offer decision support for clinicians, develop better treatments, and enhance overall system efficiency. However, achieving widespread innovation and adoption encounters substantial challanges. ML applications are highly data-dependent, necessitating a resolution for the challenge of data accessibility.

Privacy concerns are major issues to health data sharing and access. Obtaining datasets for research projects from authors of published studies is an option, but it is often inefficient and unsuccessful. Particularly in European Economic Area (EEA) countries, compliance with the EU General Data Protection Regulation (GDPR) poses significant challenges, setting a standard globally. The 'privacy chill', a slowdown or complete restriction on health data sharing, has been identified to have detrimental effects on response to health crises like the COVID-19 pandemic and on recruiting and retaining talented health data scientists.

Technical approaches to enhancing and safeguarding privacy can aid health data stewards in overcoming the 'privacy chill' and sharing data for secondary purposes. Synthetic data generation (SDG) emerges as a promising tool. A symposium and workshop in 2021 explored the potential and challenges of deploying synthetic data approaches in medical research and training. Synthetic data, if appropriately generated, has the potential to preserve privacy, offering exciting prospects across health and life sciences. However, realizing the full benefits requires further education, research, and policy innovation. The article summarizes the opportunities and challenges of SDG for health data as discussed during the symposium, presents a case study on synthetic PET scans, and outlines directions for leveraging this technology to accelerate data access for secondary purposes.

**Assuring Reliability**

In the era of data-powered decision-making across various sectors, the emergence of synthetic data has gained traction. Synthetic data, artificially generated to mimic real-world scenarios, offers a workaround for challenges linked to real data, such as privacy issues, scarcity, and data collection complexities. However, the credibility of synthetic data remains a topic of ongoing discussion, pivoting on elements like data fidelity, privacy safeguarding, and potential prejudices.

To be reliable, synthetic data must accurately mirror the statistics of the original data, encompassing its inherent diversity and structure. The peril lies in oversimplifying or distorting the complexities present in real-world data, possibly resulting in erroneous conclusions or ineffective solutions during analysis or modeling. Privacy preservation stands as a critical aspect in the creation of synthetic data. It is frequently utilized in situations where using real data might breach privacy regulations or ethical boundaries. Although synthetic data offers a degree of anonymity, debates persist about its potential for de-anonymization.

Furthermore, potential biases in synthetic data pose a significant worry. Despite being artificially generated, synthetic data often relies on real-world data for its formation. Consequently, if the real-world data is biased, these biases might inadvertently seep into the synthetic data, perpetuating flawed patterns and undermining its trustworthiness.

Additionally, evaluating the trustworthiness of synthetic data involves scrutinizing the methods employed in its creation. Transparency in the generation process, including a clear comprehension of the underlying algorithms and parameters, plays a vital role in assessing the trustworthiness of the resulting synthetic data.

In summary, while synthetic data offers substantial advantages, its credibility relies on its faithfulness to the original data, preservation of privacy, and avoidance of biases. Acknowledging and tackling these concerns empowers researchers and professionals to make well-informed decisions regarding the authenticity and ethical implications of synthetic data. Open and robust methods for generating synthetic data are crucial in nurturing this credibility.



**Challenges and Prospects**

The objective of this study is to provide an extensive overview of synthetic data generation, a burgeoning and promising technique in contemporary deep learning. This survey delineates existing real-world applications and identifies potential directions for future research in this evolving field. Synthetic data utilization has proven effective across a wide spectrum of tasks and domains. In this section, we explore the hurdles and possibilities within this swiftly advancing domain.

Firstly, robust evaluation metrics for synthetic data are pivotal in gauging the authenticity of the generated data. Particularly in data-sensitive sectors like healthcare, where data precision is crucial, relevant clinical quality measures and assessment metrics for synthetic data can be elusive. Clinicians often grapple with the interpretation of existing criteria when evaluating generative models. Moreover, specific regulations need to be established for the use of synthetic data in medicine and healthcare, ensuring compliance with quality standards while minimizing potential risks.

Secondly, prevailing methods may overlook outliers and exceptional cases present in the original data due to limited attention and domain coverage. Investigating the impact of outliers and regular instances on existing method parameterization can be a valuable avenue for future research. Bridging the gap between detection method performance and a well-designed evaluation matrix is crucial for refining future detection techniques.

Thirdly, underlying biases in models used for synthetic data generation can be unnoticed. Biases stemming from sample selection and class imbalances can significantly affect the performance of algorithms when deployed in settings different from the data collection conditions. Hence, strategies must be developed to address these biases, ensuring that synthetic data generation results in accurate and reliable outcomes across various applications and domains.

Overall, synthetic data usage is emerging as a credible alternative for training models in the face of advancements in simulations and generative models. However, several challenges such as standard tool absence, differentiation between synthetic and real data, and maximizing the effective utilization of imperfect synthetic data by machine learning algorithms need to be addressed to achieve high performance. As models, metrics, and technologies mature, we anticipate that synthetic data generation will have a more substantial impact in the future.


## [State of the art paper](https://www.sciencedirect.com/science/article/abs/pii/S1574013723000138) 


The advent of Information and Communication Technologies (ICT) has revolutionized all facets of life, notably in the medical realm where a shift from traditional human-centric practice to technology-driven healthcare has been noticable. Incorporating ICT into healthcare, exemplified by advanced telemedicine, Electronic Health Records (EHR), personal health assistants, and medical decision support systems, has notably enhanced the efficiency, accuracy, and reliability of health services. However, this integration is highly reliant on access to robust datasets. In healthcare, the availability of high-quality data is central for research, development initiatives, informed medical decisions, and ultimately, a better quality of life. Yet, privacy concerns have led to limitations in sharing healthcare data openly, primarily due to the sensitive nature of medical datasets containing personal information like diagnoses, treatments, and billing records. Privacy regulations like the Health Insurance Portability Accountability Act (HIPAA) and the General Data Protection Regulation (GDPR) impose restrictions on public data release.

Researchers are thus exploring alternatives like synthetic data (SD) creation. Synthetic data, artificially generated yet preserving statistical characteristics of the original data, is being viewed as a viable substitute that is more resilient to privacy breaches. Generating realistic synthetic medical data is gaining popularity despite its inherent complexity. The future holds a broader adoption of synthetic data, accompanied by ongoing efforts to refine generation methods and establish robust evaluation metrics for its effectiveness as a substitute for real data. 

**Synthetic Generation of Medical Data - Overview**

In the field of medical practice and research, ensuring the validity of any new solution necessits access to a vast amount of healthcare data. However, privacy laws often restrict the availability of this data for secondary use. Anonymization techniques, meant to preserve privacy, often fall short in achieving comprehensive privacy solutions, leading to a growing interest in synthetic data as a privacy-preserving data-sharing method. Synthetic datasets present a range of advantages including resilience to privacy breaches, cost-effectiveness, customizable instance generation, the ability to provide virtually unlimited real-like data, and quicker dissemination with fewer regulatory constraints. The synthetic data generation process involves three fundamental steps. First, the real-world data is collected constituting the basis for the generative model. Next, a generative model is constructed, encapsulating the ground truth. Finally, new unseen samples are extracted from this model, ensuring alignment with the ground truth.

synthetic data in healthcare holds promise as a solution to privacy challenges and data scarcity. Its applications span forecasting, technology development, feasibility assessment, education, and more, showcasing its versatile potential in revolutionizing healthcare research and practice. Continued research and development are imperative to unlock its full capabilities and address the unique challenges posed by healthcare data. While synthetic data presents a rapid and cost-effective means of generating data with desired characteristics, its full potential is yet to be acheived. The unique challenges posed by the longitudinal nature and high-dimensional complexity of health data necessitate further research and development to fully exploit the capabilities of synthetic data in healthcare.

**Approaches to Synthetic Medical Data Generation**

Synthetic data generation methods are categorized into three primary approaches based on the source of ground truth: Knowledge-Driven (KD) methods, Data-Driven methods, and Hybrid methods.

**Knowledge-Driven (KD) Approaches:**
Also termed as Theory-driven approaches, KD methods derive ground truth from domain-specific knowledge available in academic or research documents, web resources, or human expertise. Generative models in KD approaches are curated manually based on rules, statistical, mathematical, or computational models. Real data is seldom involved, making these methods resilient against disclosure attacks. However, the usefulness of KD synthetic data heavily relies on the skills and knowledge of the model curator. A good generative model should encompass maximum coverage and completeness of the ground truth, which can be challenging due to the high dimensionality and complex correlations in medical data. Additionally, human intervention can introduce errors and omissions, potentially undermining the truthfulness of the generated data. It's crucial to note that the field of practice contains hidden patterns not yet documented in domain theory, making a purely theory-based model potentially lacking in real-life clinical relevance.

**Data-Driven Approaches:**
Data-driven techniques derive the generative model from actual observed data, which indirectly represents domain theory and the deviances occurring in real-world practice. These approaches have been studied rigorously, mainly because real field data is superior at capturing ground realities compared to theoretical approaches. Furthermore, data-driven methods can be fully automated, enhancing efficiency. However, the quality of generated data heavily depends on the quality of the original data in terms of correctness, diversity, and coverage. These approaches can be categorized into transformative and simulation modes.

- **Transformative Methods:** These techniques transform original data using various masking operations before publishing to guard against privacy leakage. However, this transformation may lead to a significant degradation of data truthfulness to ensure high privacy, especially with medical data.
  
- **Simulations:** In simulation techniques, generative models estimate the probability distribution of real data, and synthetic samples are drawn from it. This maintains semantic similarity in the underlying structure of synthetic and real data, ensuring the synthetic data exhibits the same aggregate structure as real data but with sufficient micro-level differences to avoid privacy leakages.

**Hybrid Methods:**
Hybrid approaches combine knowledge-driven and data-driven elements to generate data. The generative model learns from data and is supplemented with advice from domain theory or experts. This combination enhances model flexibility, comprehensiveness, and can guide generation towards specific regions of the sample space. Integrating these methods in hybrid approaches offers potential to advance synthetic medical data generation by addressing limitations of individual approaches and enhancing the comprehensiveness of the generative model. Further research in this direction is essential for the progress of synthetic medical data generation.


**Selecting ground truth** for the creation of synthetic data in the  knowledge-driven framework involves gathering ample public knowledge from diverse sources, albeit often requiring extensive effort to adapt the knowledge for generative models. This conventional approach is slow and error-prone. Conversely, data-driven methods are highly automatable, ensuring superior reliability and efficiency. However, the quality of synthetic data is heavily dependent on the accuracy and truthfulness of the input data.

In the context of medical datasets, they can be categorized from two perspectives: privacy and structure. Privacy perspective classifies datasets into Private (containing sensitive, non-shareable data), Restricted (data with privacy-safe versions), and Public (synthetic or anonymized versions to mitigate disclosure risk). Structural perspective categorizes datasets as Snapshot/Aggregate (providing a cross-sectional view of health), Longitudinal (recording health information over time), or timeseries datasets.

Longitudinal data captures health information at various points in time, while aggregate or snapshot datasets offer a single-time snapshot of a patient's health status. Health records collected longitudinally at healthcare facilities are granular but necessitate anonymization due to privacy laws. Consequently, privacy-safe representations are derived for public sharing. While finely detailed datasets hold great research potential, they also pose higher privacy risks, explaining the prevalent use of snapshot or aggregated real data representations.

The term "syntheticity" is introduced to describe the proportion of artificial values in a dataset. Higher syntheticity indicates a greater share of synthetic versus real values. The syntheticity of data is indirectly related to privacy risks. Datasets can be partially synthetic, blending real and artificial values, or fully synthetic, devoid of original values. Partially synthetic data, often generated through techniques like Multiple Imputations, balance computational efficiency with disclosure risks. Fully synthetic data, lacking original values, offer high utility with minimal disclosure risks, making them ideal for privacy-sensitive domains like healthcare. However, they still require privacy evaluation due to potential disclosure risks.

Researchers view synthetic data as a promising alternative to original data, provided it meets two key quality attributes: Realism (similarity in behavior to original data) and Privacy Preservation (mitigating potential privacy disclosure risks). Realism should strike a balance between resembling real data and preventing sensitive information leaks, while privacy preservation entails protecting against identity, membership, and attribute disclosures, even though fully synthetic data isn't entirely immune to such threats.

**Hybrid Approaches: Pioneering the Path Forward**

**Intricacies of Medical Data and Generative Modeling**

Both **Knowledge-Driven (KD)** and **Data-Driven (DD)** approaches face distinct challenges. KD-based methods struggle with incompleteness of our knowledge, requiring manual curation. Constructing and evaluating synthetic health records significantly benefit from domain knowledge. However, this process is primarily manual, making it inefficient and error-prone. The transformation to a more automated, machine-ready representation of domain knowledge, consolidated from diverse sources, can enhance the efficiency and accuracy of synthetic data construction.  On the other hand DD methods demand extensive high-quality real data for effective learning. The **hybrid approach**, combining the flexibility of KD automation with the efficiency of DD elements, emerges as an intuitive choice for synthetic health data generation. Current **Hybrid-Based Data (HBD)** methods predominantly rely on KD components, necessitating new hybrid approaches that strike an optimal balance between data and knowledge to exploit the strengths of both methods. Methods like the '**advice**' mechanism hold promise as a way forward in generative models.

**Balancing Granularity and Spectrum in Synthetic Data**

Electronic Health Records (EHRs) offer a wealth of information for medical research and discovery, yet privacy concerns restrict their use. Synthetic EHRs present an opportunity to unlock vast research potential, but their creation at scale necessitates significant volumes of real data. The challenge lies in maintaining realism while accommodating the diversity and complexity of information found in EHRs. Addressing this requires a careful balance between granularity and spectrum in synthetic data creation. Targeted, condition-specific synthesis can reduce complexity and make use of smaller training datasets, enabling comprehensive research while preserving privacy and utility.

**Privacy Evaluation in Synthetic Data Quality**

Privacy evaluation is a critical aspect of assessing synthetic data quality, yet historically, it has received less attention compared to realism evaluation. Synthetic data is not impervious to privacy attacks, necessitating a rigorous assessment of privacy risks before its release. Balancing privacy and utility is key to optimizing the quality of synthetic data for specific applications. More research is needed to understand and formalize the relationship between these two crucial attributes.

**Toward a Standardized Framework for Synthetic Data Quality Evaluation**

As the volume of literature on medical Synthetic Data Generation (SDG) grows, a standardized evaluation framework is imperative. Such a framework would enable practitioners to assess the utility of synthetic data for their target applications and select suitable methods without grappling with technical intricacies. Additionally, it would establish benchmarks and guidelines for further research, contributing to the maturity of the field. Recent advances in SDG evaluation frameworks have begun to address this need, focusing on utility assessment and providing a roadmap for continued enhancement of SD quality evaluation methods.



