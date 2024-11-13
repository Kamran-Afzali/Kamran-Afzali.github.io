When planning secure data storage solutions for health research, it’s important to understand the specific security, compliance, and operational needs of the data to create a tailored solution that aligns with both analytical requirements and stringent regulatory standards. Therefore, it’s helpful to categorize the discussion into eight key areas. First, **Data Characteristics** helps assess the level of protection needed based on the data's nature and risks. **Compliance and Regulatory Requirements** identify any legal standards that govern data handling, particularly with health-related information. **Data Access and User Permissions** clarify who will access the data and under what conditions, while **Data Encryption and Protection** addresses safeguarding the data in storage and transit. **Data Retention, Archival, and Disposal** requirements guide how long data should be kept and protocols for eventual deletion. Understanding **Data Processing and Analysis Requirements** ensures that the storage solution can support the anticipated computational needs. **Audit and Monitoring Needs** help establish accountability and track data usage, and finally, **Incident Response and Breach Notification** protocols outline response plans for any data security incidents. Together, these categories provide a comprehensive framework to address the unique storage and security demands of health research data.
Following questions should cover aspects of data sensitivity, access control, regulatory compliance, and data lifecycle management to ensure the solution aligns with legal, ethical, and technical requirements.

Here are key questions to guide this understanding:

### 1. **Data Characteristics**
   - **Data Volume and Format** (What is the expected volume of data to be stored?, In what file formats will the data be stored?, Are there any specific software requirements for data analysis?)
   - **What types of sensetive data will be stored?** (e.g., Personally Identifiable Information [PII], Protected Health Information [PHI], genomic data)
   - **Is the data anonymized or pseudonymized?** If yes, ask for details on the anonymization or pseudonymization techniques they have used or plan to use.
   - **Are there any specific risks associated with this data?** For example, would unauthorized access lead to any critical personal, financial, or institutional harm?

### 2. **Data Compliance and Regulatory Requirements**
   - **What regulatory frameworks or standards apply to your data?** (e.g., HIPAA, PIPEDA, GDPR, CIHR guidelines for Canadian research, provincial health privacy laws like Quebec’s Law 25 on privacy)
   - **Are there specific data residency requirements?** For example, does the data need to stay within Quebec, Canada, or a specific jurisdiction?
   - **Are there any institutional or grant-related data security requirements?** Some grants or institutions may impose additional data handling standards.

### 3. **Data Access and User Permissions**
   - **Who will need access to this data?** Gather details about users, their roles, and their access levels (e.g., read-only, write, administrative).
   - **What access control measures are needed?** For example, are multi-factor authentication (MFA), VPN access, etc.?
   - **How often will this data be accessed, and by how many users?** This can influence storage capacity and performance requirements.
   - **Will data be shared with collaborators outside your institution or country?** If yes, clarify the security and compliance requirements for cross-institutional or cross-border data sharing. What level of access control and anonymization will be required for sharing?

### 4. **Data Encryption and Protection**
   - **Is data encryption required at rest and in transit?** If yes, ask if there are specific encryption standards they must follow (e.g., AES-256).
   - **Will any additional security layers, such as specific firewall configurations, intrusion detection, or monitoring, be necessary?**
   - **Does the project require secure backup and recovery options?** If so, determine the preferred frequency and retention period for backups.

### 5. **Data lifecycle**
   - **Data Collection and Transfer** (How will the data be collected and transferred to Calcul Quebec servers?, Are there any security measures needed during the transfer process?)
   - **What are the data retention requirements?** (e.g., short-term, long-term, or indefinite storage based on the project's lifecycle)
   - **Is there a need for archival storage?** Some research data might need a lower-cost, long-term storage solution after the project completes.
   - **What are the data disposal requirements?** Ask if data needs to be securely deleted or if there are specific data sanitization protocols they must follow at the end of the storage period.

### 6. **Data Processing and Analysis Requirements**
   - **What kinds of analyses will be performed on this data?** (e.g., machine learning, statistical modeling, genetic sequencing)
   - **Are there performance or compute requirements for data analysis?** For example, some applications may require high I/O speeds or high-memory configurations.
   - **Will the analysis process require moving data between different storage or computing systems?** If so, ask about requirements for data transfer security and bandwidth.

### 7. **Audit and Monitoring Needs**
   - **Is auditing of access and changes to the data required?** Determine if they need logs of access events, changes to files, or administrative actions.
   - **How frequently should the audit logs be reviewed, and who should have access to them?**
   - **Are there specific reporting needs for compliance audits or internal reviews?**

### 8. **Incident Response and Breach Notification**
   - **What is the protocol for security incidents or breaches involving this data?** Clarify if there are specific timelines or procedures for notifying stakeholders in case of a breach.
   - **Does the project require a formal incident response plan?** This might include steps for containment, investigation, and mitigation in case of an incident.

These questions will help you assess the technical requirements, compliance obligations, and operational needs for storing and handling health research data securely within Calcul Québec's infrastructure. After gathering this information, you can tailor a storage solution that meets both their analytical and regulatory needs, ensuring they maintain control over sensitive information throughout the data lifecycle.

To help researchers answer these questions accurately, a range of resources is available to guide them in understanding data sensitivity, regulatory compliance, security best practices, and technical requirements. Here’s an overview of useful resources:

### 1. **Institutional Policies and Compliance Offices**
   - **University Research Ethics Boards (REBs)** or **Institutional Review Boards (IRBs)**: These boards provide guidelines on ethical data handling and security standards, especially for sensitive health data.
   - **Privacy and Compliance Offices**: Most universities and research institutions have offices that can help researchers interpret regulations like HIPAA, GDPR, and PIPEDA. These offices can often answer questions about data residency, anonymization, and access control requirements.
   - **Information Technology Services**: University IT departments often publish security policies, encryption standards, and recommended data handling practices.

### 2. **National and Provincial Health Data Privacy Regulations**
   - **Digital Research Alliance of Canada**: This national body provides resources and best practices for data management in Canadian research. They offer guidance on secure data storage and computational practices in alignment with national standards.
   - **Government Health Data Guidelines**: Canadian resources like Health Canada and provincial bodies such as the Commission d’accès à l’information du Québec (CAI) offer specific regulatory guidance on handling health data and adhering to privacy laws, including Quebec’s Law 25.
   - **HIPAA and GDPR Guidelines**: The U.S. Department of Health and Human Services (HHS) provides HIPAA guidance, while the European Commission offers resources for GDPR compliance, both of which are often relevant for international research collaborations.

### 3. **Research Data Management Plans (DMP)**
   - **DMP Assistant** (Canada) or **DMPTool** (U.S.): These online platforms guide researchers through creating data management plans, which include considerations for data storage, access, and security.
   - **Institutional DMP Templates**: Many universities provide templates and tools to help researchers plan data management, including privacy considerations, retention schedules, and compliance with funding requirements.

### 4. **Data Classification and Sensitivity Guidelines**
   - **National Institute of Standards and Technology (NIST)**: NIST provides guidelines on data classification, risk assessment, and security measures, including encryption and access control.
   - **Research Institutions’ Classification Standards**: Many universities have specific data classification guides that help researchers determine the sensitivity level of their data and match it to appropriate security measures.

### 5. **Data Security and Privacy Best Practices**
   - **Calcul Québec and Alliance Training Resources**: Calcul Québec, as part of the Digital Research Alliance of Canada, offers workshops and resources on data security, secure storage, and handling sensitive data on shared infrastructure.
   - **CITI Program and Other Online Courses**: The Collaborative Institutional Training Initiative (CITI) offers training modules on data security, research ethics, and handling sensitive data, which are tailored for academic researchers.

### 6. **Health Data Anonymization and De-identification Guides**
   - **Canadian Institutes of Health Research (CIHR)**: CIHR offers recommendations on de-identification and data anonymization to comply with Canadian privacy standards in health research.
   - **ISO Standards for Anonymization**: The International Organization for Standardization (ISO) provides guidance on anonymization techniques and best practices for protecting privacy in datasets.

### 7. **Audit and Monitoring Tools**
   - **University IT Audit Guidelines**: Many institutions provide internal resources on how researchers can maintain access logs and monitor data usage, often with templates for compliance audits.
   - **Data Protection Officer (DPO)**: If the institution has a DPO, they can provide specific requirements for logging and monitoring access as per GDPR or institutional requirements.
   - **Calcul Québec Logging and Monitoring Services**: Calcul Québec may offer specific logging and access-monitoring tools for researchers storing sensitive data, especially when additional security and auditing are required.

### 8. **Incident Response Planning and Data Breach Protocols**
   - **Institutional Incident Response Plans**: Many universities offer pre-defined incident response protocols for research data, often found through the institution’s IT security or compliance office.
   - **Digital Research Alliance of Canada Guidelines**: The Alliance often has resources on cybersecurity for research data, including breach response best practices tailored to the Canadian research environment.
   - **Provincial and Federal Guidelines for Data Breaches**: For example, in Quebec, the Commission d’accès à l’information provides protocols for incident response and reporting in case of data breaches involving sensitive information.

By consulting these resources, researchers can better understand their responsibilities and the available infrastructure, ensuring compliance with security and privacy requirements while effectively managing their data.
Here are some key resources with links that researchers can use to find guidance on data sensitivity, compliance, security, and best practices in managing health data securely:


_________________________________________________________________



To help researchers answer the questions related to data management, security, and storage for health research projects, there are several valuable resources available. Here are some key resources with links where possible:

### Data Management and Security Guidelines

- **Canadian Institutes of Health Research (CIHR)**
CIHR provides comprehensive [guidelines on research data management](https://cihr-irsc.gc.ca/e/50727.html), including security considerations for health data.
- **Tri-Agency Research Data Management Policy**
This policy outlines requirements for data management in research funded by Canada's federal research agencies: [Tri-Agency Research Data Management Policy](https://science.gc.ca/site/science/en/interagency-research-funding/policies-and-guidelines/research-data-management/tri-agency-research-data-management-policy)
- **Digital Research Alliance of Canada (Alliance)**: The Alliance provides training, resources, and guidelines for advanced research computing and secure data management in Canada. [Alliance Resources and Services](https://alliancecan.ca/en)  
- **DMP Assistant (Canada)**: A Canadian tool for creating data management plans with guidance on privacy, storage, and access. [DMP Assistant](https://assistant.portagenetwork.ca/)  
- **U.S. DMPTool**: A tool for creating data management plans in the U.S., useful for international collaborators. [DMPTool](https://dmptool.org/)  

### Health Data Compliance and Privacy Regulations
- **Office of the Privacy Commissioner of Canada (PIPEDA)**: Information on Canada’s federal privacy law, PIPEDA, applicable to private-sector organizations handling personal data. [PIPEDA Information](https://www.priv.gc.ca/en/)  
- **HIPAA (U.S. Department of Health and Human Services)**: Resources for HIPAA compliance, which may be required for international collaborations involving U.S. data. [HIPAA Guidance](https://www.hhs.gov/hipaa/for-professionals/index.html)  
- **GDPR (European Commission)**: Guidelines on GDPR compliance, relevant for collaborations with European researchers. [GDPR Compliance Overview](https://ec.europa.eu/info/law/law-topic/data-protection_en)  
- **Quebec's Law 25**: Information about Quebec’s privacy law, including requirements for data security and incident response. [Commission d’accès à l’information du Québec](https://www.cai.gouv.qc.ca/)  
- **Health Canada's Best Practices for Protecting Individual Privacy in Conducting Survey Research**
While focused on surveys, this resource provides valuable insights on data protection:
[Health Canada's Best Practices for Protecting Individual Privacy in Conducting Survey Research](https://www.canada.ca/en/health-canada/services/science-research/science-advice-decision-making/research-ethics-board/privacy-confidentiality/best-practices-protecting-individual-privacy-conducting-survey-research.html) 


### Regulatory Compliance

- **Tri-Council Policy Statement: Ethical Conduct for Research Involving Humans ([TCPS 2](https://ethics.gc.ca/eng/policy-politique_tcps2-eptc2_2018.html))**
This policy statement provides ethical guidelines for research involving humans, including health research:
[TCPS 2](https://ethics.gc.ca/eng/policy-politique_tcps2-eptc2_2018.html)

- **[Personal Health Information Protection Act (PHIPA) in Ontario](https://www.ontario.ca/laws/statute/04p03)**
For researchers in Ontario, this act governs the collection, use, and disclosure of personal health information: [Personal Health Information Protection Act (PHIPA) in Ontario](https://www.ontario.ca/laws/statute/04p03)


### Data Sharing and Open Science

- **Open Science at CIHR**
[CIHR's open science policy and resources](https://cihr-irsc.gc.ca/e/50068.html)


- **Portage Network**
A national research data management network that provides resources and tools for Canadian researchers:
[Portage Network](https://portagenetwork.ca/) 


### Incident Response and Data Breach Protocols 
- **Government of Canada - Data Breach Guidelines**: Best practices for managing data breaches, including notification requirements and incident response plans. [Government of Canada - Data Breach Guidelines](https://www.priv.gc.ca/en/privacy-topics/privacy-breaches/)  

- **Commission d’accès à l’information du Québec (CAI)**: Provides specific protocols for managing breaches of sensitive data in Quebec. [CAI Incident Response](https://www.cai.gouv.qc.ca/)  


### Anonymization and De-identification Resources 
- **Canadian Institutes of Health Research (CIHR)**: Guidelines on managing health data, including best practices for de-identification to meet Canadian privacy standards. [CIHR Ethical Guidelines for Health Research](https://cihr-irsc.gc.ca/e/29134.html)  

- **ISO Standards for Anonymization**: Guidelines from the International Organization for Standardization on anonymizing data. [ISO/IEC 20889:2018 Anonymization Techniques](https://www.iso.org/standard/69373.html)  

_________________________________________________________________


Lors de la planification de solutions de stockage de données sécurisées pour la recherche en santé, il est important de comprendre les besoins spécifiques en matière de sécurité, de conformité et d’opérations pour créer une solution adaptée qui respecte à la fois les exigences analytiques et les normes réglementaires strictes. Il est donc utile de diviser cette discussion en huit domaines clés. Tout d’abord, les **caractéristiques des données** permettent d’évaluer le niveau de protection nécessaire en fonction de la nature et des risques des données. Les **exigences de conformité et réglementaires** identifient les normes légales qui régissent le traitement des données, en particulier dans le domaine de la santé. **L’accès aux données et les autorisations des utilisateurs** précisent qui aura accès aux données et dans quelles conditions, tandis que **le chiffrement et la protection des données** traitent de la sécurisation des données en stockage et en transit. Les exigences de **conservation, archivage et élimination des données** orientent la durée de conservation des données et les protocoles de suppression. Comprendre les **besoins de traitement et d’analyse des données** garantit que la solution de stockage peut supporter les besoins informatiques prévus. Les **besoins d’audit et de surveillance** aident à établir la responsabilité et à suivre l’utilisation des données, et enfin, les **protocoles de réponse aux incidents et de notification de violation** définissent les plans d’intervention en cas d’incident de sécurité des données. Ensemble, ces catégories fournissent un cadre complet pour répondre aux besoins uniques de stockage et de sécurité des données de recherche en santé.

Les questions suivantes doivent aborder les aspects de sensibilité des données, de contrôle d’accès, de conformité réglementaire et de gestion du cycle de vie des données pour garantir que la solution respecte les exigences légales, éthiques et techniques.

Voici des questions clés pour guider cette compréhension :

### 1. **Caractéristiques des Données**
   - **Volume et Format des Données** (Quel est le volume attendu de données à stocker ?, Sous quels formats de fichiers les données seront-elles stockées ?, Y a-t-il des exigences logicielles spécifiques pour l’analyse des données ?)
   - **Quels types de données sensibles seront stockés ?** (par ex., informations personnellement identifiables [PII], informations de santé protégées [PHI], données génomiques)
   - **Les données sont-elles anonymisées ou pseudonymisées ?** Si oui, demandez des détails sur les techniques d’anonymisation ou de pseudonymisation utilisées ou prévues.
   - **Y a-t-il des risques spécifiques associés à ces données ?** Par exemple, un accès non autorisé causerait-il des dommages personnels, financiers ou institutionnels critiques ?

### 2. **Exigences de Conformité et Réglementaires**
   - **Quelles normes réglementaires s’appliquent à vos données ?** (par ex., HIPAA, LPRPDE, RGPD, directives des IRSC pour la recherche canadienne, lois provinciales sur la confidentialité des données de santé comme la Loi 25 du Québec sur la vie privée)
   - **Y a-t-il des exigences spécifiques de résidence des données ?** Par exemple, les données doivent-elles rester au Québec, au Canada, ou dans une juridiction spécifique ?
   - **Y a-t-il des exigences de sécurité des données imposées par une institution ou une subvention ?** Certaines subventions ou institutions peuvent imposer des normes supplémentaires pour la gestion des données.

### 3. **Accès aux Données et Permissions des Utilisateurs**
   - **Qui aura besoin d’accéder à ces données ?** Rassemblez des détails sur les utilisateurs, leurs rôles et leurs niveaux d’accès (par ex., lecture seule, écriture, administration).
   - **Quelles mesures de contrôle d’accès sont nécessaires ?** Par exemple, une authentification multifacteur (MFA), un accès VPN, etc. sont-ils requis ?
   - **À quelle fréquence et par combien d’utilisateurs ces données seront-elles consultées ?** Cela peut influencer la capacité de stockage et les exigences de performance.
   - **Les données seront-elles partagées avec des collaborateurs extérieurs à votre institution ou pays ?** Si oui, clarifiez les exigences de sécurité et de conformité pour le partage de données interinstitutionnel ou transfrontalier. Quel niveau de contrôle d’accès et d’anonymisation sera nécessaire pour le partage ?

### 4. **Chiffrement et Protection des Données**
   - **Un chiffrement des données au repos et en transit est-il nécessaire ?** Si oui, demandez s’il y a des normes de chiffrement spécifiques à respecter (par ex., AES-256).
   - **Des couches de sécurité supplémentaires, telles que des configurations de pare-feu spécifiques, la détection d'intrusions ou la surveillance, seront-elles nécessaires ?**
   - **Le projet nécessite-t-il des options de sauvegarde et de récupération sécurisées ?** Si oui, déterminez la fréquence préférée et la période de conservation des sauvegardes.

### 5. **Cycle de Vie des Données**
   - **Collecte et Transfert des Données** (Comment les données seront-elles collectées et transférées vers les serveurs de Calcul Québec ?, Y a-t-il des mesures de sécurité nécessaires pendant le transfert ?)
   - **Quelles sont les exigences de conservation des données ?** (par ex., stockage à court terme, à long terme, ou indéfini en fonction du cycle de vie du projet)
   - **Y a-t-il un besoin de stockage archivistique ?** Certaines données de recherche peuvent nécessiter une solution de stockage à long terme et à faible coût après la fin du projet.
   - **Quelles sont les exigences d’élimination des données ?** Demandez si les données doivent être supprimées de manière sécurisée ou s’il y a des protocoles spécifiques de nettoyage des données à suivre en fin de période de stockage.

### 6. **Exigences de Traitement et d’Analyse des Données**
   - **Quels types d’analyses seront effectuées sur ces données ?** (par ex., apprentissage machine, modélisation statistique, séquençage génétique)
   - **Y a-t-il des exigences de performance ou de calcul pour l’analyse des données ?** Par exemple, certaines applications peuvent nécessiter des vitesses I/O élevées ou des configurations à haute mémoire.
   - **Le processus d’analyse nécessitera-t-il le déplacement de données entre différents systèmes de stockage ou de calcul ?** Si oui, demandez les exigences en matière de sécurité de transfert de données et de bande passante.

### 7. **Besoins en Audit et Surveillance**
   - **L’audit de l’accès et des modifications aux données est-il requis ?** Déterminez s’ils ont besoin de journaux d’événements d’accès, de modifications de fichiers ou d’actions administratives.
   - **À quelle fréquence les journaux d’audit doivent-ils être examinés, et qui doit y avoir accès ?**
   - **Y a-t-il des besoins spécifiques en matière de rapports pour les audits de conformité ou les revues internes ?**

### 8. **Réponse aux Incidents et Notification de Violation**
   - **Quel est le protocole pour les incidents de sécurité ou les violations impliquant ces données ?** Clarifiez s’il existe des délais ou des procédures spécifiques pour notifier les parties prenantes en cas de violation.
   - **Le projet nécessite-t-il un plan de réponse aux incidents formel ?** Celui-ci peut inclure les étapes de confinement, d'enquête et de mitigation en cas d'incident.

Ces questions vous aideront à évaluer les exigences techniques, les obligations de conformité et les besoins opérationnels pour stocker et gérer les données de recherche en santé de manière sécurisée au sein de l’infrastructure de Calcul Québec. Après avoir recueilli ces informations, vous pourrez concevoir une solution de stockage qui répond à leurs besoins analytiques et réglementaires, garantissant le contrôle des informations sensibles tout au long du cycle de vie des données.

### Directives de Gestion et Sécurité des Données

- **Instituts de recherche en santé du Canada (IRSC)**
Les IRSC fournissent des [directives complètes sur la gestion des données de recherche](https://cihr-irsc.gc.ca/e/50727.html), y compris des considérations de sécurité pour les données de santé.
- **Politique de gestion des données de recherche des trois organismes**
Cette politique décrit les exigences de gestion des données dans les recherches financées par les organismes fédéraux de recherche du Canada : [Politique de gestion des données de recherche des trois organismes](https://science.gc.ca/site/science/fr/financement-interorganismes-recherche/politiques-et-directives/gestion-donnees-recherche/politique-gestion-donnees-recherche-trois-organismes)
- **Alliance de la recherche numérique du Canada (Alliance)** : L'Alliance fournit des formations, des ressources et des directives pour le calcul informatique avancé et la gestion sécurisée des données au Canada. [Ressources et services de l'Alliance](https://alliancecan.ca/en)  
- **Assistant PGD (Canada)** : Un outil canadien pour créer des plans de gestion des données avec des indications sur la confidentialité, le stockage et l'accès. [Assistant PGD](https://assistant.portagenetwork.ca/)  
- **DMPTool des États-Unis** : Un outil pour créer des plans de gestion des données aux États-Unis, utile pour les collaborateurs internationaux. [DMPTool](https://dmptool.org/)  

### Conformité des Données de Santé et Règlements sur la Confidentialité
- **Commissariat à la protection de la vie privée du Canada (LPRPDE)** : Informations sur la loi fédérale canadienne sur la vie privée, LPRPDE, applicable aux organisations du secteur privé traitant des données personnelles. [Informations sur la LPRPDE](https://www.priv.gc.ca/en/)  
- **HIPAA (Département de la Santé et des Services sociaux des États-Unis)** : Ressources pour la conformité HIPAA, qui peut être requise pour les collaborations internationales impliquant des données américaines. [Guide HIPAA](https://www.hhs.gov/hipaa/for-professionals/index.html)  
- **RGPD (Commission Européenne)** : Directives sur la conformité au RGPD, pertinentes pour les collaborations avec des chercheurs européens. [Aperçu de la conformité au RGPD](https://ec.europa.eu/info/law/law-topic/data-protection_en)  
- **Loi 25 du Québec** : Informations sur la loi québécoise sur la vie privée, y compris les exigences de sécurité des données et de réponse aux incidents. [Commission d’accès à l’information du Québec](https://www.cai.gouv.qc.ca/)  
- **Pratiques exemplaires de Santé Canada pour protéger la vie privée individuelle dans la réalisation de recherches par sondage**
Bien que centrée sur les sondages, cette ressource fournit des informations précieuses sur la protection des données :
[Pratiques exemplaires de Santé Canada pour protéger la vie privée individuelle dans la réalisation de recherches par sondage](https://www.canada.ca/en/health-canada/services/science-research/science-advice-decision-making/research-ethics-board/privacy-confidentiality/best-practices-protecting-individual-privacy-conducting-survey-research.html) 


### Conformité Règlementaire

- **Énoncé de politique des trois Conseils : Éthique de la recherche avec des êtres humains ([EPTC 2](https://ethics.gc.ca/eng/policy-politique_tcps2-eptc2_2018.html))**
Cet énoncé de politique fournit des directives éthiques pour la recherche impliquant des humains, y compris la recherche en santé :
[EPTC 2](https://ethics.gc.ca/eng/policy-politique_tcps2-eptc2_2018.html)

- **[Loi sur la protection des renseignements personnels sur la santé (LPRPS) en Ontario](https://www.ontario.ca/laws/statute/04p03)**
Pour les chercheurs en Ontario, cette loi régit la collecte, l'utilisation et la divulgation des renseignements personnels sur la santé : [Loi sur la protection des renseignements personnels sur la santé (LPRPS) en Ontario](https://www.ontario.ca/laws/statute/04p03)


### Partage de Données et Science Ouverte

- **Science ouverte aux IRSC**
[Politique et ressources des IRSC sur la science ouverte](https://cihr-irsc.gc.ca/e/50068.html)


- **Réseau Portage**
Un réseau national de gestion des données de recherche qui fournit des ressources et des outils pour les chercheurs canadiens :
[Réseau Portage](https://portagenetwork.ca/) 


### Réponse aux Incidents et Protocoles de Violation de Données 
- **Gouvernement du Canada - Directives sur les violations de données** : Pratiques exemplaires pour gérer les violations de données, y compris les exigences de notification et les plans de réponse aux incidents. [Directives du gouvernement du Canada sur les violations de données](https://www.priv.gc.ca/en/privacy-topics/privacy-breaches/)  

- **Commission d’accès à l’information du Québec (CAI)** : Fournit des protocoles spécifiques pour gérer les violations de données sensibles au Québec. [Réponse aux incidents de la CAI](https://www.cai.gouv.qc.ca/)  


### Ressources sur l'Anonymisation et la Dé-identification 
- **Instituts de recherche en santé du Canada (IRSC)** : Directives sur la gestion des données de santé, y compris les pratiques exemplaires de dé-identification pour répondre aux normes canadiennes de confidentialité. [Directives éthiques des IRSC pour la recherche en santé](https://cihr-irsc.gc.ca/e/29134.html)  

- **Normes ISO pour l'anonymisation** : Directives de l'Organisation internationale de normalisation sur l'anonymisation des données. [ISO/IEC 20889:2018 Techniques d'anonymisation](https://www.iso.org/standard/69373.html)  




