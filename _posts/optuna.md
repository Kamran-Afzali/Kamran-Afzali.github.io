
Il s’agirait de dire qu’on wrap cette librairie dans Clover (pas besoin de vraiment la décrire), et qu’on utilise la méthode par défaut (plusieurs sont proposées par Optuna): TPE (Tree-structured Parzen Estimator), qui est une version de l’optimisation bayésienne. 

Voici le site de la librairie: https://optuna.org/ et sa page GitHub: https://github.com/optuna/optuna 
Le lien direct vers la fonction qu’on utilise principalement (optimize): https://optuna.readthedocs.io/en/stable/reference/generated/optuna.study.Study.html#optuna.study.Study.optimize
Le lien direct vers le sampler par défaut: https://optuna.readthedocs.io/en/stable/reference/samplers/generated/optuna.samplers.TPESampler.html#optuna.samplers.TPESampler

Le premier article recommandé sur le site d’Optuna pour mieux comprendre le TPE: https://proceedings.neurips.cc/paper_files/paper/2011/file/86e8f7ab32cfd12577bc2619bc635690-Paper.pdf

Un article plus bref est ici: http://neupy.com/2016/12/17/hyperparameter_optimization_for_neural_networks.html#tree-structured-parzen-estimators-tpe
