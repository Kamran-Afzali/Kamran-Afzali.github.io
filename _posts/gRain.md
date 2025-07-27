# Graphical Independence Networks with the gRain Package

## Overview

The gRain package implements probability propagation in Bayesian networks, also known as graphical independence networks. The package uses the junction tree algorithm to transform a Bayesian network model into a tree, combining the efficiency of belief propagation and the sum-product method for efficient computation of posterior probabilities.

## Mathematical Formalism

### Bayesian Networks

A Bayesian network is defined by:
- A directed acyclic graph (DAG) G = (V, E) where V represents random variables and E represents conditional dependencies
- A set of conditional probability distributions P(Xi | Pa(Xi)) for each variable Xi given its parents Pa(Xi)

The joint probability distribution factors as:
```
P(X₁, X₂, ..., Xₙ) = ∏ᵢ P(Xᵢ | Pa(Xᵢ))
```

### Junction Tree Algorithm

The junction tree algorithm performs exact inference through:

1. **Moralization**: Convert the DAG to an undirected graph by:
   - Adding edges between all pairs of parents of each node (marrying parents)
   - Dropping edge directions

2. **Triangulation**: Add edges to eliminate cycles of length > 3

3. **Junction Tree Construction**: 
   - Find maximal cliques in the triangulated graph
   - Connect cliques to form a tree satisfying the running intersection property

4. **Probability Propagation**: Use message passing between cliques to compute marginal probabilities

### Mathematical Properties

**Running Intersection Property**: For any variable X appearing in cliques Ci and Cj, X must appear in all cliques on the path between Ci and Cj.

**Clique Potential**: Each clique C has an associated potential φC(xC) representing the joint probability over variables in C.

**Message Passing**: Messages between adjacent cliques i and j:
```
m_{i→j}(S_{ij}) = ∑_{C_i \setminus S_{ij}} φ_i(C_i) ∏_{k ∈ ne(i) \setminus j} m_{k→i}(S_{ki})
```

where Sij is the separator between cliques Ci and Cj.

## R Code Examples

### Installation and Setup

```r
# Install gRain package
install.packages("gRain")
library(gRain)

# Required dependencies
library(gRbase)
library(Rgraphviz)  # For visualization
```

### Example 1: Simple Bayesian Network

```r
# Define variables and their states
yn <- c("yes", "no")

# Create conditional probability tables
# P(Asia)
asia <- cptable(~asia, values=c(1,99), levels=yn)

# P(Tuberculosis | Asia)
tub.asia <- cptable(~tub|asia, values=c(5,95,1,99), levels=yn)

# P(Smoking)
smoke <- cptable(~smoke, values=c(50,50), levels=yn)

# P(Lung cancer | Smoking)
lung.smoke <- cptable(~lung|smoke, values=c(10,90,1,99), levels=yn)

# P(Bronchitis | Smoking)
bronc.smoke <- cptable(~bronc|smoke, values=c(60,40,30,70), levels=yn)

# P(Either | Tuberculosis, Lung cancer)
either.tub.lung <- cptable(~either|tub:lung, 
                          values=c(1,0,1,0,1,0,0,1), levels=yn)

# P(X-ray | Either)
xray.either <- cptable(~xray|either, values=c(98,2,5,95), levels=yn)

# P(Dyspnoea | Either, Bronchitis)
dysp.either.bronc <- cptable(~dysp|either:bronc, 
                            values=c(90,10,70,30,80,20,10,90), levels=yn)

# Compile the network
plist <- compileCPT(list(asia, tub.asia, smoke, lung.smoke, 
                        bronc.smoke, either.tub.lung, 
                        xray.either, dysp.either.bronc))

# Create the grain object (graphical independence network)
chest.grain <- grain(plist)

# Print summary
summary(chest.grain)
```

### Example 2: Inference and Evidence

```r
# Query marginal probabilities
querygrain(chest.grain, nodes=c("lung", "bronc"))

# Set evidence
chest.grain.ev <- setEvidence(chest.grain, 
                             nodes=c("asia", "dysp"), 
                             states=c("yes", "yes"))

# Query with evidence
querygrain(chest.grain.ev, nodes=c("lung", "bronc"))

# Most probable explanation
pFinding(chest.grain.ev)

# Simulate from the network
simulate(chest.grain, nsim=1000)
```

### Example 3: Learning from Data

```r
# Load example data
data(lizard, package="gRbase")

# Create graphical model
g <- list(~diam + locc, ~diam + spec, ~locc + spec + height)

# Fit the model
gm <- ggm(g, data=lizard)

# Convert to grain object
grain.fit <- as.grain(gm)

# Compile and propagate
grain.compiled <- compile(grain.fit)
grain.prop <- propagate(grain.compiled)

# Query the fitted model
querygrain(grain.prop, nodes="spec")
```

### Example 4: Network Visualization

```r
# Plot the network structure
plot(chest.grain)

# Alternative visualization with Rgraphviz
library(Rgraphviz)
plot(chest.grain$dag)

# Display clique tree
plot(chest.grain$triangulated)
```

### Example 5: Advanced Operations

```r
# Extract network components
getNodes(chest.grain)
getEdges(chest.grain)

# Independence testing
dsep(chest.grain$dag, "asia", "bronc", "smoke")

# Clique and separator information
getCliques(chest.grain)
getSeparators(chest.grain)

# Absorption and distribution operations
absorbed <- absorbEvidence(chest.grain.ev)
distributed <- distributeEvidence(absorbed)
```

## Key Functions in gRain

| Function | Purpose |
|----------|---------|
| `grain()` | Create graphical independence network |
| `cptable()` | Create conditional probability tables |
| `compileCPT()` | Compile list of CPTs |
| `setEvidence()` | Set evidence/observations |
| `querygrain()` | Query marginal probabilities |
| `propagate()` | Perform belief propagation |
| `pFinding()` | Probability of findings |
| `simulate()` | Generate random samples |

## Theoretical Background

### Junction Tree Properties

1. **Completeness**: Every maximal clique in the triangulated graph appears as a node in the junction tree
2. **Minimality**: The junction tree has the minimum number of edges
3. **Running Intersection**: Ensures consistent probability propagation

### Computational Complexity

- **Time Complexity**: O(|C|² × 2^w) where |C| is the number of cliques and w is the treewidth
- **Space Complexity**: O(∑c |Sc|) for all clique states Sc

The treewidth determines the computational feasibility of exact inference.

## Applications

- Medical diagnosis systems
- Risk assessment models  
- Expert systems
- Fault diagnosis
- Genetic analysis
- Environmental modeling

## References and Hyperlinks

### Primary References

1. **Main gRain Paper**: 
   - Højsgaard, S. (2012). "Graphical Independence Networks with the gRain Package for R." *Journal of Statistical Software*, 46(10), 1-26.
   - DOI: [10.18637/jss.v046.i10](https://doi.org/10.18637/jss.v046.i10)
   - URL: https://www.jstatsoft.org/article/view/v046i10

2. **Comprehensive Book**:
   - Højsgaard, S., Edwards, D., & Lauritzen, S. (2012). *Graphical Models with R*. Springer UseR! Series.

### Package Documentation

- **CRAN Page**: https://cran.r-project.org/package=gRain
- **GitHub Repository**: https://github.com/hojsgaard/gRain
- **Package Documentation**: https://cran.r-project.org/web/packages/gRain/gRain.pdf
- **Author's Website**: https://people.math.aau.dk/~sorenh/software/gR/

### Theoretical Background

3. **Junction Tree Algorithm**:
   - Lauritzen, S.L. & Spiegelhalter, D.J. (1988). "Local computations with probabilities on graphical structures and their application to expert systems." *Journal of the Royal Statistical Society B*, 50(2), 157-224.

4. **Bayesian Networks Theory**:
   - Pearl, J. (1988). *Probabilistic Reasoning in Intelligent Systems*. Morgan Kaufmann.
   - Koller, D. & Friedman, N. (2009). *Probabilistic Graphical Models*. MIT Press.

### Online Resources

- **Wikipedia - Bayesian Networks**: https://en.wikipedia.org/wiki/Bayesian_network
- **Wikipedia - Junction Tree Algorithm**: https://en.wikipedia.org/wiki/Junction_tree_algorithm
- **R Documentation**: https://rdrr.io/cran/gRain/

### Related R Packages

- **gRbase**: Graphical modeling base functions
- **bnlearn**: Bayesian network learning algorithms  
- **deal**: Learning Bayesian networks with mixed variables
- **RHugin**: Interface to Hugin Bayesian network software

## Citation Format

To cite the gRain package in publications:

```
Højsgaard S (2012). "Graphical Independence Networks with the gRain Package for R." 
Journal of Statistical Software, 46(10), 1-26. 
URL: https://www.jstatsoft.org/v46/i10/
```

In R, use: `citation("gRain")`

## Installation Notes

For full functionality, ensure you have:
- R (≥ 3.5.0)
- Rgraphviz (for network visualization)
- RBGL (graph algorithms)
- Bioconductor packages if needed:

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(c("Rgraphviz", "RBGL"))
```
