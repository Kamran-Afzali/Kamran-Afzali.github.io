---
editor_options: 
  markdown: 
    wrap: 72
---

### Collective Active Inference and Group-Level Free Energy Minimization

Following on our previous posts on the free energy principle (FEP), this
post explores how collective active inference might account for social
adaptation, decision-making, and coordinated action in multi-agent
systems. Active inference at the individual level involves an ongoing
interplay between perception and action. An agent uses a generative
model a probabilistic account of how hidden causes produce observable
outcomes to interpret its environment. It updates its beliefs as new
observations arrive and acts in ways that change those observations.
When applied to groups, this framework considers how interacting agents
coordinate their inferences and actions, sometimes through shared or
partially aligned models. The extension introduces new complexities,
particularly around how diverse beliefs are integrated and under what
conditions individual adaptation supports collective performance.

## From Individual Inference to Collective Behavior

Collective active inference considers how individuals, each responding
to local information, can produce coordinated group behavior. In
*Collective behavior from surprise minimization*, researchers show that
cohesion, milling, and directed movement can emerge in simulated groups
of active inference agents without explicitly prescribing the
corresponding behavioral rules. The model also connects individual
assumptions about uncertainty to collective decision-making accuracy.
These results provide a computational account of how local inference can
generate organized group dynamics; they do not, by themselves, establish
that every coordinated group minimizes a single group-level free energy
function. This distinction matters. Collective behavior can emerge from
interactions among agents without requiring that the group possess a
unified model or act as a single cognitive agent. Kaufmann and
colleagues (2021), for example, investigate how individual cognitive
capabilities can support collective intelligence in a minimal
agent-based model. Their work treats the relationship between individual
and collective inference as a problem to be modeled, rather than
assuming that the two levels are automatically aligned.

## Shared Generative Models and Belief Sharing

A central concept in some accounts of collective active inference is the
**shared** generative model. If agents use compatible models of a common
environment, they may distribute parts of the inference process across
the group. Rather than requiring every agent to observe everything
directly, agents can use information supplied by others to update their
own beliefs. This provides one way to connect individual information
processing with collective problem-solving.
[mdpi](https://www.mdpi.com/1099-4300/23/7/830)

Such coordination requires some common ground: agents need a way to
interpret one another’s observations, actions, or messages. In a formal
model, this may involve specifying corresponding representations across
agents. An “isomorphism between beliefs” would describe a
structure-preserving correspondence between those representations. It
should not be treated as a general requirement for all forms of
cooperation, however. The extent of the correspondence needed depends on
the task and the architecture of the model.

Belief sharing is particularly relevant when agents have complementary
perspectives. One agent may observe something that another cannot,
allowing the group to draw on information distributed across its
members. Still, receiving social information is not enough; agents must
also determine how much weight to give it. In the collective-motion
model, excessive reliance on social information can reduce sensitivity
to useful external information, whereas insufficient reliance can
undermine group cohesion. Collective accuracy depends on balancing these
sources rather than simply maximizing agreement.
[pnas](https://www.pnas.org/doi/10.1073/pnas.2320239121)

## Communication and Coordinated Inference

Communication provides a possible mechanism for coordinating beliefs
about a shared world. When agents have access to different observations,
exchanging information may help them resolve uncertainty that would
remain unresolved individually. Within an active inference account, this
process can be modeled through the relationships among observations,
beliefs about other agents, and subsequent actions. Kaufmann and
colleagues explore a related mechanism by equipping agents with the
ability to infer aspects of a partner’s state and goals.
[mdpi](https://www.mdpi.com/1099-4300/23/7/830)

The broader idea of federated inference concerns how inference can be
distributed across interacting agents rather than concentrated in a
single controller. Friston and colleagues’ *Designing ecosystems of
intelligence from first principles* (2024) develops a related approach
to distributed intelligence. The practical question is how agents can
exchange useful information while retaining their own perspectives and
responsibilities. [arxiv](https://arxiv.org/html/2501.19368v1)

Language raises a further question: how do agents establish and maintain
the conventions that make their messages interpretable? Shared
expectations about what signals mean may support coordination, but an
account of belief exchange is not yet a complete explanation of
language. Claims that linguistic structure, Universal Grammar, or
Optimality Theory follows from free energy minimization require separate
arguments and evidence. These connections are better presented as
questions for investigation than as established consequences of the
framework.

## Cumulative Culture, Norms, and Institutions

Cumulative culture offers a possible setting in which to investigate
collective active inference. From this perspective, social learning and
communication could help individuals preserve, revise, and transmit
models of their environment across generations. The central question is
whether these processes can explain not only the maintenance of shared
knowledge but also its modification and accumulation.

Social norms and institutions can likewise be considered within this
framework. Shared expectations may help people anticipate one another’s
behavior and coordinate without repeatedly negotiating every
interaction. Kaufmann and colleagues discuss shared norms as a possible
extension of the cognitive capabilities supporting collective
intelligence, although their simulations focus on theory of mind and
goal alignment rather than directly testing institutional or cultural
change. [mdpi](https://www.mdpi.com/1099-4300/23/7/830)

An active inference interpretation does not, however, establish that
norms will adapt successfully when circumstances change. Nor does
reduced uncertainty necessarily imply a desirable social outcome. A
convincing account must distinguish the stability of a shared
expectation from its accuracy, adaptability, or benefit to the people
affected by it. Empirical research would need to establish when shared
expectations support adaptation and when they obstruct it.

## Individual Autonomy and Group-Level Coherence

A significant challenge in collective active inference is the balance
between individual autonomy and group-level coherence. Individuals must
respond to their own circumstances while also coordinating with others.
Their goals may overlap, but they need not coincide. A group-level
account therefore needs to explain how local and collective objectives
become aligned—and what happens when they do not.
[mdpi](https://www.mdpi.com/1099-4300/23/7/830)

Kaufmann and colleagues (2021) examine this problem using a minimal
model of two interacting agents. They compare agents with different
combinations of theory of mind and goal alignment. Their illustrative
simulations suggest that these capabilities can improve collective
performance by helping reconcile individual and shared objectives. The
result is useful as a demonstration of a possible mechanism, but it
should not be read as evidence that the same intervention will improve
decision-making in human organizations.
[mdpi](https://www.mdpi.com/1099-4300/23/7/830)

Decentralized coordination also does not necessarily require explicit
belief sharing. In the collective-motion model, organized behavior
emerges through agents sensing and responding to their neighbors.
Distinguishing coordination through local interaction from coordination
through explicit communication helps clarify which mechanisms a
particular model actually explains.
[pnas](https://www.pnas.org/doi/10.1073/pnas.2320239121)

## Practical Applications and Future Directions

The framework raises practical questions for organizational management
and artificial intelligence. What would it mean to implement shared
generative modeling in a team? How could socially adaptive AI agents
exchange beliefs without assuming that every agent represents the world
in the same way? These questions require concrete model specifications,
not only a general appeal to collective uncertainty reduction.

For example, a study of collaborative planning in a remote team could
specify which information each member receives, what they believe about
the task, how they communicate uncertainty, and how their decisions
change after exchanging information. Researchers could then compare the
active inference model with alternative accounts using measures such as
prediction accuracy, decision quality, and coordination time. This would
turn a broad theoretical proposal into a set of claims that could be
evaluated.

Similar care is needed in distributed AI. A model should specify what
agents share—observations, parameter estimates, beliefs about hidden
states, or intended actions—and how recipients interpret that
information. It should also identify when cooperation improves
performance relative to agents acting independently. Existing
simulations show how particular assumptions about uncertainty and goal
alignment influence collective outcomes, but extending those findings to
practical systems requires further testing.
[pnas](https://www.pnas.org/doi/10.1073/pnas.2320239121)

Accessibility matters here as well. Terms such as “generative model,”
“shared priors,” and “group-level free energy” should be defined in
relation to the system being studied. Otherwise, the same vocabulary can
obscure important differences between a formal computational model, a
description of human experience, and a proposal for organizational
practice.

Collective active inference offers a way to investigate how individual
inference and action contribute to coordinated behavior. Its main
contribution is not the claim that all groups seek agreement or minimize
uncertainty in the same way. Rather, it provides tools for making
explicit the assumptions that connect individual models, social
interactions, and collective outcomes. Computational studies illustrate
some of these connections, while also showing that performance depends
on how agents weigh information and align their goals.
[pnas](https://www.pnas.org/doi/10.1073/pnas.2320239121)

Future work should establish clearer empirical criteria for evaluating
group-level free energy minimization, incorporate data from
organizational, social, and ecological settings, and develop
reproducible simulation tools. It should also compare active inference
models with alternative explanations of the same behavior. The
framework’s practical value will depend on whether it produces testable
predictions and useful interventions beyond what existing approaches
already provide.

**References**

1.  [Collective behavior from surprise
    minimization](https://www.pnas.org/doi/10.1073/pnas.2320239121)
    Albarracin, D., et al. (2022).

2.  [Emergent sensing and decision making in animal
    groups](https://www.science.org/doi/10.1126/science.1225883)
    Berdahl, A. M., et al. (2013). *Science*, *339*(6119), 574-576.

3.  [Statistical Decision Theory: Foundations, Concepts, and
    Methods](https://www.amazon.com/Statistical-Decision-Theory-Foundations-Statistics/dp/0387904719)
    Berger, J. O. (1980). Springer-Verlag.

4.  [Bounded rational decision-making models suggest capacity-limited
    concurrent motor planning in human posterior parietal and frontal
    cortex](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1010585)
    Braun, D. A., et al. (2011). *PLOS Computational Biology*.

5.  [Active interoceptive inference and the emotional
    brain](https://pubmed.ncbi.nlm.nih.gov/28080966/) Bruineberg, J., et
    al. (2018). *Philosophical Transactions of the Royal Society B:
    Biological Sciences*, *373*(1740), 20170141.

6.  [The Minimalist
    Program](https://mitpress.mit.edu/9780262531283/the-minimalist-program/)
    Chomsky, N. (2017). MIT Press.

7.  [Embodied predictive coding: a theoretical framework for
    sensorimotor contingencies and perceptual
    presence](https://link.springer.com/article/10.1007/s12559-018-9584-5)
    Constant, A., et al. (2019). *Cognitive Computation*, *11*(2),
    269-290.

8.  [Effective leadership and decision-making in animal groups on the
    move](https://www.nature.com/articles/nature03236) Couzin, I. D., et
    al. (2005). *Nature*, *433*(7025), 513-516.

9.  [Expectation propagation for graphical
    models](https://scispace.com/pdf/extending-expectation-propagation-for-graphical-models-19r531y5o4.pdf)\
    Dauwels, J. (2007). In *Probability and Statistics* (pp. 141-153).
    ISTE.

10. [Self-evidencing and the epistemic
    imperative](https://www.frontiersin.org/articles/10.3389/fpsyg.2021.636029/full)\
    Fields, C., et al. (2021). *Frontiers in Psychology*, *12*, 636029.

11. [The free-energy principle: a unified brain
    theory?](https://www.nature.com/articles/nrn2787)\
    Friston, K. (2010). *Nature Reviews Neuroscience*, *11*(2), 127-138.

12. [Life as we know
    it](https://royalsocietypublishing.org/doi/10.1098/rsif.2013.0475)\
    Friston, K. (2013). *Journal of the Royal Society Interface*,
    *10*(80), 20130475.

13. [Distributed Science](https://arxiv.org/abs/2201.09674)\
    Friston, K., et al. (2022).

14. [Learning fixed and random reward
    structures](https://www.jneurosci.org/content/30/27/9287)\
    Gershman, S. J., & Niv, Y. (2010). *Journal of Neuroscience*,
    *30*(27), 9287-9292.

15. [Bayesian reinforcement learning: A
    survey](https://www.nowpublishers.com/article/Details/MAL-050)\
    Ghavamzadeh, M., et al. (2016). *Foundations and Trends® in Machine
    Learning*, *8*(5-6), 359-613.

16. [Collective information use, spatial scale, and coping with
    environmental
    change](https://esajournals.onlinelibrary.wiley.com/doi/full/10.1890/14-0702.1)\
    Hein, A. M., et al. (2015). *Ecology*, *96*(1), 74-84.

17. [The self-evidencing
    brain](https://onlinelibrary.wiley.com/doi/abs/10.1111/nous.12062)\
    Hohwy, J. (2016). *Noûs*, *50*(2), 259-285.

18. [Bayesian surprise attracts human
    attention](https://www.sciencedirect.com/science/article/abs/pii/S0042698909001053)\
    Itti, L., & Baldi, P. (2009). *Vision Research*, *49*(12),
    1295-1306.

19. [Bayes
    factors](https://www.tandfonline.com/doi/abs/10.1080/01621459.1995.10476572)\
    Kass, R. E., & Raftery, A. E. (1995). *Journal of the American
    Statistical Association*, *90*(430), 773-795.

20. [Small Steps for Mankind](https://arxiv.org/abs/2308.07870)\
    Kastel, A., et al. (2022).

21. [Stepwise cognitive transitions increase collective intelligence in
    an active inference model](https://www.mdpi.com/1099-4300/23/7/830)\
    Kaufmann, T., et al. (2021). *Entropy*, *23*(7), 830.

22. [Risk-sensitive behavior explains direct choices in uncertain
    environments](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.0010053)\
    Klyubin, A. S., et al. (2005). *PLoS Computational Biology*, *1*(5),
    e53.

23. [On a measure of the information provided by an
    experiment](https://projecteuclid.org/journals/annals-of-mathematical-statistics/volume-27/issue-4/On-a-Measure-of-the-Information-Provided-by-an-Experiment/10.1214/aoms/1177728069.full)\
    Lindley, D. V. (1956). *The Annals of Mathematical Statistics*,
    *27*(4), 986-1005.

24. [Information-based objective functions for active data
    selection](https://direct.mit.edu/neco/article-abstract/4/3/405/6053/Information-Based-Objective-Functions-for-Active-Data)\
    Mackay, D. J. C. (1992). *Neural Computation*, *4*(3), 405-447.

25. [Predictive processing as a framework, not a theory: commentary on
    Kirchhoff, Parr, Palacios, Friston and
    Clark](https://link.springer.com/article/10.1007/s11229-021-03156-6)\
    Michel, M. (2022). *Synthese*, *200*(3), 1-9.

26. [Thermodynamics as a theory of decision-making with
    information-processing
    costs](https://royalsocietypublishing.org/doi/10.1098/rspa.2012.0699)\
    Ortega, P. A., & Braun, D. A. (2013). *Proceedings of the Royal
    Society A: Mathematical, Physical and Engineering Sciences*,
    *469*(2153), 20120699.

27. [Generalized free energy and active inference; the Markovian
    niche](https://www.mdpi.com/1099-4300/21/1/43)\
    Parr, T., & Friston, K. J. (2019). *Entropy*, *21*(1), 43.
