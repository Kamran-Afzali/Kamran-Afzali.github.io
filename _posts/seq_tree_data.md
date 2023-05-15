

While there isn't a specific algorithm widely known as "Sequential Trees" for data generation, there are techniques and methods that combine decision trees with sequential processes to generate synthetic data. One such approach is called "Sequential Regression Imputation" (SRI), which involves using decision trees iteratively for data generation. Here's a high-level overview of the SRI algorithm:

Training Phase: In the training phase, a decision tree model is trained using a dataset that includes complete observations for the target variable.

Initialization: Start with an incomplete dataset where the target variable has missing values that need to be generated.

Iteration: Repeat the following steps until all missing values are generated:

a. Data Splitting: Split the dataset into two subsets: one subset with complete observations for the target variable and one subset with missing values for the target variable.

b. Decision Tree Generation: Build a decision tree using the subset with complete target variable observations. The decision tree uses the predictor variables as input and the target variable as the output.

c. Prediction: Use the decision tree to predict the missing values in the subset with missing target variable values. Each instance in the subset is traversed through the decision tree, and the predicted value is assigned to the missing target variable.

d. Imputation: Replace the missing values in the original dataset with the predicted values from the decision tree.

Completion: Once all missing values are generated and imputed, the dataset is considered complete.

The Sequential Regression Imputation (SRI) algorithm combines decision trees with a sequential process, where the decision trees are built iteratively to generate missing values for the target variable. This approach allows the generated data to capture the relationships between the predictor variables and the target variable.

It's worth noting that this is just one example of how decision trees can be used sequentially for data generation. There may be variations or alternative methods that employ similar principles. Additionally, the specific implementation details and variations of this approach may depend on the software or library being used.


## References

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7810457/

https://unece.org/fileadmin/DAM/stats/documents/ece/ces/ge.46/20150/Paper_33_Session_2_-_Univ._Edinburgh__Nowok_.pdf
