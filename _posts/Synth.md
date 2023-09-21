

Machine learning grants intelligent computer systems the ability to autonomously handle tasks, pushing the boundaries of innovation across industries. Through the integration of high-performance computing, contemporary modeling, and simulations, machine learning has become a crucial tool for managing and analyzing vast amounts of data. However, it's important to acknowledge that machine learning doesn't always solve problems or yield optimal solutions. Despite the consensus that we are in an artificial intelligence golden age, significant challenges persist in developing and applying machine learning technology. Overcoming these obstacles is vital to fully unleash the potential of machine learning and its transformative influence on diverse sectors.

One major challenge lies in data quality, where subpar data can lead to inaccurate predictions due to confusion and misinterpretation. Additionally, data scarcity poses a considerable hurdle, as obtaining sufficient, labeled data can be costly and challenging. Data privacy and fairness are also concerns, necessitating ethical and secure practices to mitigate risks associated with synthetic data.

Addressing these challenges is crucial to harnessing the complete potential of machine learning and its impact on various industries. Synthetic data, artificially generated through computer algorithms or simulations, plays a vital role, especially when real data is either unavailable or needs to be kept private. This paper aims to provide a comprehensive overview of state-of-the-art approaches for synthetic data generation in machine learning research, covering domains, generative models, privacy concerns, evaluation strategies, and future research avenues.


Synthetic data presents a compelling array of benefits, making it an attractive option for a wide range of applications. It significantly streamlines the processes involved in training, testing, and deploying AI solutions, promoting more efficient and effective development. Furthermore, this cutting-edge technology plays a crucial role in reducing the risk of exposing sensitive information, thereby ensuring customer security and privacy. As researchers transition synthetic data from the lab to practical implementations, its real-world applications continue to expand. This section delves into several noteworthy domains where synthetic data generation significantly impacts addressing real-world challenges.

A. Vision
Supervised learning heavily relies on having labeled data. However, in many applications, especially in computer vision, manual labeling is often a necessity. Tasks such as segmentation, depth estimation, and optical flow estimation can be exceedingly challenging to label manually. Synthetic data emerges as a transformative solution in this context, vastly improving the labeling process. For example, Sankaranarayanan et al. introduced a generative adversarial network (GAN) that narrows the gap between embeddings in the learned feature space, enabling Visual Domain Adaptation. This approach facilitates semantic segmentation across different domains, demonstrating the potency of synthetic data in enhancing machine learning applications in vision-related tasks.

Moreover, a Microsoft research team showcased the effectiveness of synthetic data in face-related tasks. They combined a parametric 3D face model with an extensive library of hand-crafted assets to generate training images with remarkable realism and diversity. Synthetic data, in this scenario, proved sufficient for training machine learning systems for tasks such as landmark localization and face parsing, achieving comparable accuracy to real data. It was noted that synthetic data alone can effectively detect faces in unconstrained settings.

B. Voice
The field of synthetic voice is at the forefront of technological advancement, and its evolution is happening rapidly. With the advent of machine learning and deep learning, creating synthetic voices for various applications, such as video production, digital assistants, and video games, has become easier and more accurate. This interdisciplinary field encompasses acoustics, linguistics, and signal processing. Researchers continually strive to enhance the accuracy and naturalness of synthetic voices, anticipating their increased prevalence in our daily lives, enriching experiences across multiple domains.

In the realm of synthetic voice, there are various approaches and models, such as spectral modeling for statistical parametric speech synthesis. This technique uses untransformed spectral envelope parameters for voice synthesis, significantly improving naturalness and avoiding oversmoothing in speech synthesis. Synthetic data has also found applications in Text-to-Speech (TTS) systems, achieving near-human naturalness. Additionally, it has been leveraged for automatic speech recognition, reducing the need for production data and associated costs while maintaining state-of-the-art techniques.

C. Natural Language Processing (NLP)
The surge in interest surrounding synthetic data has led to a diverse array of deep generative models in the field of natural language processing (NLP). NLP involves categorizing, routing, filtering, and searching for relevant information across various domains. Despite advancements, challenges persist due to the contextual variability of words and phrases and the presence of homonyms with distinct meanings. To tackle these, innovative models like BLEURT have been proposed, utilizing millions of synthetic examples to bolster pre-training schemes and enhance model generalization. Another notable model, RelGAN, showcases potential in enhancing NLP tasks through improved sampling quality and diversity.

D. Healthcare
Synthetic data has gained significant attention in the healthcare industry due to its potential to protect health information and enhance research reproducibility. Generating synthetic data modeled after patient information is crucial in understanding diseases while preserving patient confidentiality and privacy. Furthermore, it has been instrumental in drug discovery, particularly in de novo drug design, where generative models learn from existing drug databases to draw novel samples, potentially revolutionizing pharmaceutical research.

In the healthcare domain, patient information is often stored in electronic health records (EHR) format, and the availability of such data has facilitated research in medicine. Models like MedGAN are able to generate realistic synthetic patient records, aiding in research by reducing regulatory barriers that hindered data sharing and integration in the past. Synthetic data enables efficient sharing and integration of patient data across multiple organizations, enhancing research scope and efficiency while reducing biases in results.

In summary, synthetic data holds immense promise in various domains, significantly impacting the advancement and efficiency of AI applications. From vision to voice, natural language processing, and healthcare, the integration of synthetic data is poised to reshape these fields, enabling more accurate, efficient, and privacy-conscious solutions.


**fairness**

The challenge of fairness arises when generating synthetic data that accurately reflects the key statistical characteristics of real-world data. However, these synthetic datasets can inadvertently carry biases from data preprocessing, collection methods, and the algorithms used. Addressing fairness in synthetic data involves three main methods: preprocessing, in-processing, and postprocessing. Preprocessing modifies the input data to eliminate correlations with sensitive attributes, often using techniques like massaging, reweighting, or sampling. In contrast, in-processing integrates fairness constraints into the model learning process, while postprocessing adjusts model predictions after training. Existing fairness-aware data synthesis methods primarily utilize preprocessing techniques, leveraging balanced synthetic datasets from Generative Adversarial Networks (GANs) to mitigate disparate impact caused by imbalances in minoritized subgroups.

However, the preprocessing approach requires prior knowledge of all correlations, biases, and variable distributions in existing datasets. The latter two methods (in-processing and postprocessing) are less developed for ensuring fairness in synthetic data. Additionally, the introduction of differential privacy amplifies fairness concerns in the original data, particularly affecting the influence of majority subgroups and reducing synthetic data utility in downstream tasks. Fairness metrics for synthesized data have been proposed to analyze covariate-level disparities, considering protected attributes to assess bias. It's crucial to regulate the real-world data used to create the synthetic data distribution, ensuring the quality and minimizing biases. Moreover, ongoing scrutiny and the removal of sensitive and toxic information from both data and models are necessary to govern the outcomes generated by foundation models and prevent harm and discrimination.

**Assuring Reliability**

In the era of data-powered decision-making across various sectors, the emergence of synthetic data has gained traction. Synthetic data, artificially generated to mimic real-world scenarios, offers a workaround for challenges linked to real data, such as privacy issues, scarcity, and data collection complexities. However, the credibility of synthetic data remains a topic of ongoing discussion, pivoting on elements like data fidelity, privacy safeguarding, and potential prejudices.

To be reliable, synthetic data must accurately mirror the statistics of the original data, encompassing its inherent diversity and structure. The peril lies in oversimplifying or distorting the complexities present in real-world data, possibly resulting in erroneous conclusions or ineffective solutions during analysis or modeling. Privacy preservation stands as a critical aspect in the creation of synthetic data. It is frequently utilized in situations where using real data might breach privacy regulations or ethical boundaries. Although synthetic data offers a degree of anonymity, debates persist about its potential for de-anonymization.

Furthermore, potential biases in synthetic data pose a significant worry. Despite being artificially generated, synthetic data often relies on real-world data for its formation. Consequently, if the real-world data is biased, these biases might inadvertently seep into the synthetic data, perpetuating flawed patterns and undermining its trustworthiness.

Additionally, evaluating the trustworthiness of synthetic data involves scrutinizing the methods employed in its creation. Transparency in the generation process, including a clear comprehension of the underlying algorithms and parameters, plays a vital role in assessing the trustworthiness of the resulting synthetic data.

In summary, while synthetic data offers substantial advantages, its credibility relies on its faithfulness to the original data, preservation of privacy, and avoidance of biases. Acknowledging and tackling these concerns empowers researchers and professionals to make well-informed decisions regarding the authenticity and ethical implications of synthetic data. Open and robust methods for generating synthetic data are crucial in nurturing this credibility.


**Evaluation Approaches**

In this section, we explore different methodologies for assessing the quality of synthetic data, a crucial aspect in ascertaining the effectiveness and relevance of synthetic data generation techniques in real-world contexts. We classify these assessment approaches as follows:

1. **Human Assessment**: Directly evaluating synthesized data involves seeking feedback from domain experts or non-experts to judge aspects like similarity to real data, usability in specific applications, or overall quality. For instance, in speech synthesis, evaluators blindly rate both synthesized and real human speech. However, this method has drawbacks, including high cost, time intensiveness, susceptibility to errors, and limited scalability. It's particularly challenging for high-dimensional data not easily visualized by humans.

2. **Statistical Comparison**: This approach entails calculating diverse statistical metrics on both synthetic and real datasets and comparing the outcomes. For example, statistics on features like medical concept frequency or patient-level clinical attributes can be employed to evaluate generated electronic health record (EHR) data. Smaller differences in statistical properties between synthetic and real data indicate higher quality in the synthetic dataset.

3. **Model-based Evaluation**: Utilizing a pre-trained machine learning model, especially the discriminator in Generative Adversarial Networks (GANs), helps distinguish between synthetic and real data. The performance of the discriminator on synthetic data serves as an indicator of the realism achieved by the generator, allowing assessment not only in GANs but also in other generative models using pre-trained machine learning models.

4. **Training and Testing on Real Data**: Here, synthetic data is utilized to train machine learning models, and their predictive performance is evaluated on real test data in downstream applications. Strong performance on real test data suggests successful capture of essential real data characteristics, establishing synthetic data as a valuable proxy for training. This strategy offers insights into the effectiveness of synthetic data in training machine learning models across various tasks and domains.

5. **Domain-specific Evaluation**: Depending on the specific domain or application, specialized evaluation techniques tailored to unique requirements, like regulatory compliance, privacy considerations, or specific performance metrics, may be employed to assess the synthesized data's quality. By evaluating synthesized data in its intended use context, a more precise assessment of its quality and suitability can be achieved.

These evaluation strategies offer diverse avenues to measure the quality of synthesized data, aiding researchers and professionals in determining the efficacy of synthetic data generation methods in real-world scenarios. Employing a blend of these strategies can furnish a comprehensive understanding of the synthetic data's strengths and weaknesses, facilitating ongoing enhancements in synthetic data generation techniques.

**Challenges and Prospects**

The objective of this study is to provide an extensive overview of synthetic data generation, a burgeoning and promising technique in contemporary deep learning. This survey delineates existing real-world applications and identifies potential directions for future research in this evolving field. Synthetic data utilization has proven effective across a wide spectrum of tasks and domains. In this section, we explore the hurdles and possibilities within this swiftly advancing domain.

Firstly, robust evaluation metrics for synthetic data are pivotal in gauging the authenticity of the generated data. Particularly in data-sensitive sectors like healthcare, where data precision is crucial, relevant clinical quality measures and assessment metrics for synthetic data can be elusive. Clinicians often grapple with the interpretation of existing criteria when evaluating generative models. Moreover, specific regulations need to be established for the use of synthetic data in medicine and healthcare, ensuring compliance with quality standards while minimizing potential risks.

Secondly, prevailing methods may overlook outliers and exceptional cases present in the original data due to limited attention and domain coverage. Investigating the impact of outliers and regular instances on existing method parameterization can be a valuable avenue for future research. Bridging the gap between detection method performance and a well-designed evaluation matrix is crucial for refining future detection techniques.

Thirdly, underlying biases in models used for synthetic data generation can be unnoticed. Biases stemming from sample selection and class imbalances can significantly affect the performance of algorithms when deployed in settings different from the data collection conditions. Hence, strategies must be developed to address these biases, ensuring that synthetic data generation results in accurate and reliable outcomes across various applications and domains.

Overall, synthetic data usage is emerging as a credible alternative for training models in the face of advancements in simulations and generative models. However, several challenges such as standard tool absence, differentiation between synthetic and real data, and maximizing the effective utilization of imperfect synthetic data by machine learning algorithms need to be addressed to achieve high performance. As models, metrics, and technologies mature, we anticipate that synthetic data generation will have a more substantial impact in the future.


#### State of the art paper https://www.sciencedirect.com/science/article/abs/pii/S1574013723000138


The advent of Information and Communication Technologies (ICT) has revolutionized all facets of life, notably in the medical realm where a shift from traditional human-centric practice to technology-driven healthcare has been transformative. Incorporating ICT into healthcare, exemplified by advanced telemedicine, Electronic Health Records (EHR), personal health assistants, and medical decision support systems, has notably enhanced the efficiency, pervasiveness, accuracy, and reliability of health services. However, this integration is highly reliant on access to robust datasets.

In healthcare, the availability of high-quality data is pivotal for research, development initiatives, informed medical decisions, and ultimately, a better quality of life. Yet, privacy concerns have led to limitations in sharing healthcare data openly, primarily due to the sensitive nature of medical datasets containing personal information like diagnoses, treatments, and billing records. Privacy regulations like the Health Insurance Portability Accountability Act (HIPAA) and the General Data Protection Regulation (GDPR) impose restrictions on public data release.

Researchers are thus exploring alternatives like synthetic data (SD) creation. Synthetic data, artificially generated yet preserving statistical characteristics of the original data, is being viewed as a viable substitute that is more resilient to privacy breaches. Generating realistic synthetic medical data is gaining traction despite its inherent complexity and longitudinal nature, with a surge in research publications in this domain. The future holds a broader adoption of synthetic data, accompanied by ongoing efforts to refine generation methods and establish robust evaluation metrics for its effectiveness as a substitute for real data. Consolidation of knowledge and concepts in this evolving field is deemed essential for a comprehensive understanding.

**Synthetic Generation of Medical Data - Overview**

In the field of medical practice and research, ensuring the validity of any new solution is paramount, necessitating access to a vast amount of healthcare data. However, privacy laws often restrict the availability of this data for secondary use. Anonymization techniques, meant to preserve privacy, often fall short in achieving comprehensive privacy solutions, leading to a growing interest in synthetic data as a privacy-preserving data-sharing method. Synthetic datasets present a range of advantages including resilience to privacy breaches, cost-effectiveness, customizable instance generation, the ability to provide virtually unlimited real-like data, and quicker dissemination with fewer regulatory constraints.

Applications of synthetic data in healthcare are diverse and impactful. It serves in predicting epidemics and aiding in urban planning based on disease patterns. Additionally, synthetic data is instrumental in testing and developing new healthcare devices and algorithms, such as in the development of diabetic foot treatment insoles. It offers a cost-effective method for a preliminary assessment of the utility of real data before actual procurement, saving both cost and effort. Furthermore, synthetic data encourages innovation without compromising privacy, making it suitable for use in data science competitions and hackathons. In academic settings, synthetic data facilitates practical training and improves understanding of critical concepts, particularly in data science challenges. Additionally, synthetic data serves as valuable test data for software and hardware tools, aiding in benchmarking and estimating re-identification risks associated with anonymized data. When combined with real data, synthetic data enhances the performance of AI models, a critical aspect of medical decision-making.

The synthetic data generation process involves three fundamental steps. First, relevant facts and theories are collected from the real-world, constituting the basis for the generative model. Next, a generative model is constructed, encapsulating the necessary ground truth. Finally, new unseen samples are extracted from this model, ensuring alignment with the ground truth.

While synthetic data presents a rapid and cost-effective means of generating data with desired characteristics, its full potential in the medical domain remains untapped. The unique challenges posed by the longitudinal nature and high-dimensional complexity of health data necessitate further research and development to fully exploit the capabilities of synthetic data in healthcare.

In summary, synthetic data in healthcare holds promise as a solution to privacy challenges and data scarcity. Its applications span forecasting, technology development, feasibility assessment, education, and more, showcasing its versatile potential in revolutionizing healthcare research and practice. Continued research and development are imperative to unlock its full capabilities and address the unique challenges posed by healthcare data.



#### Narrative review paper https://doi.org/10.1371/journal.pdig.0000082

**Definition and Categorization of Synthetic Data**

The term "synthetic data" is often defined based on the US Census Bureau's perspective, emphasizing the generation of new data values using statistical models that replicate the statistical properties of original data. This strategic use of synthetic data aims to enhance data utility while safeguarding privacy and confidentiality. Depending on the generation method, synthetic datasets can offer reverse disclosure protection, allowing appropriate multivariate analyses while preventing inferences about parameters in statistical models.

Synthetic data is broadly categorized into three types: fully synthetic, partially synthetic, and hybrid. Fully synthetic data involves creating entirely fabricated data, devoid of any real data, providing strong privacy control but limited analytic value due to data loss. Partially synthetic data replaces sensitive variables with synthetic versions while retaining original values, posing some reidentification risk. Hybrid synthetic data combines original and synthetic data, balancing privacy control and utility, albeit with increased processing time and memory requirements.

The UK's Office for National Statistics (ONS) has delineated a detailed spectrum of synthetic data types, ranging from the lowest, purely synthetic structural dataset developed using metadata only (with minimal analytic value and no disclosure risk), to a replica level synthetically-augmented dataset that closely mirrors real data, preserving format, structure, joint distribution, patterns, and geographies at the cost of higher disclosure risks. This categorization aids in understanding the varying utility and privacy aspects of synthetic data across different levels of replication and augmentation.


**Synthetic Data: Opportunities, Challenges, and Validation**

Synthetic data has emerged as a potent tool addressing three pivotal challenges in healthcare data. Primarily, it safeguards individual privacy and record confidentiality by generating data that is difficult to re-identify, being a blend of "fake" and original data. Secondly, it enhances accessibility to health data for researchers and various users due to minimal disclosure risk in synthesized datasets. This opens doors for a broader array of users, accelerating research. Thirdly, synthetic data fills the void of realistic data for software development and testing, providing cost-effective and authentic test data for software applications.

Leveraging synthetic data offers substantial opportunities to bolster data infrastructure, especially in confronting emerging health challenges. Restrictions on sharing mental health data, like opioid use disorder (OUD) records, have impeded research and public health initiatives. Synthetic longitudinal records, mirroring individuals diagnosed with OUD and those lost to opioid overdose, provide essential data for pattern analysis, risk identification, policy simulations, and program evaluation. Synthetic data proves crucial in studying communicable diseases and stigmatized populations like those diagnosed with HIV, where data sharing barriers persist.

The COVID-19 pandemic heightened the demand for timely and accessible data. Initiatives like the National COVID Cohort Collaborative (N3C) have utilized synthetic data to broaden data availability for research. Studies exploring the use of synthetic data for COVID-19-related clinical research have indicated that synthetic data can effectively act as a proxy for real datasets, significantly enhancing its value and utility.

However, despite these advantages, there are notable limitations. Synthetic data strives to provide artificial variables to preserve record confidentiality, but there's a risk of original data leakage. Adversarial machine learning techniques and data outliers can compromise the confidentiality intended by synthetic data. Additionally, not all synthetic data accurately replicate the content and properties of the original dataset, limiting its use in clinical research.

Addressing these limitations requires thorough validation of synthetic data and the models used for its generation. Presently, there's a lack of standardized benchmarks for validation. Various frameworks and approaches have been proposed to validate the realism of synthetic data, comparing synthetic data results with real-world data to assess accuracy. Clinical quality measures have been suggested as a validation approach, aiding in understanding the limitations of synthetic data in modeling diverse outcomes.

In conclusion, synthetic data presents immense promise in healthcare, overcoming critical challenges while offering a wealth of opportunities. However, addressing its limitations and ensuring validation frameworks are crucial for maximizing its potential in transforming healthcare data infrastructure and research. Researchers and data users need to consider these factors and validation results when utilizing specific synthetic datasets.

**Utilizations of Synthetic Health Data**

While relatively new, the utilization of synthetic data in various realms of health care has gained recognition in both peer-reviewed and grey literature. The value of synthetic data has been acknowledged in health care research, education, data management, and health IT development. 

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

In summary, synthetic health data demonstrates versatile applicability across health care research, education, IT development, and more. Its significance continues to grow, addressing challenges and contributing to advancements in diverse domains.
