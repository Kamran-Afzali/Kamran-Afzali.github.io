### Responsible use of artificial intelligence (AI) by Canadian Government

Artificial intelligence (AI) technologies offer promise for improving how the Government of Canada serves Canadians. As we explore the use of AI in government programs and services, we are ensuring it is governed by clear values, ethics, and laws.

Our guiding principles
To ensure the effective and ethical use of AI the government will:

understand and measure the impact of using AI by developing and sharing tools and approaches
be transparent about how and when we are using AI, starting with a clear user need and public benefit
provide meaningful explanations about AI decision making, while also offering opportunities to review results and challenge these decisions
be as open as we can by sharing source code, training data, and other relevant information, all while protecting personal information, system integration, and national security and defence
provide sufficient training so that government employees developing and using AI solutions have the responsible design, function, and implementation skills needed to make AI-based public services better



### Techniques Toward Alignment: RLHF 
When it comes to language models like GPT-3, the technique of Reinforcement Learning with Human Feedback (RLHF) is used by OpenAI in ChatGPT. What if whatever candidate you chose in the above example could be trained based on your feedback or the feedback of other humans? This is exactly what happens in RLHF, but it runs the risk of being exceptionally Sycophantic. 

At a high level, RLHF works by learning a reward model for a certain task based on human feedback and then training a policy to optimize the reward received. This means the model is rewarded when it provides a good answer and penalized when it provides a bad one, to improve its answers in use. In doing so, it learns to do good more often. For ChatGPT, the model was rewarded for helpful, harmless, and honest answers. 

A suite of Instruct-GPT models was also trained using RLHF, which involves showing a bunch of samples to a human, asking them to choose the one closest to what they intended, and then using reinforcement learning to optimize the model to match those preferences.

RLHF has generated some impressive outputs, like ChatGPT, but there is a significant amount of disagreement about its potential as a partial or complete solution to the alignment problem. Specifically, RLHF has been posited as a partial or complete solution for the outer alignment problem, which aims to formalize when humans communicate what they want to an AI and it appears to do it and “generalizes the way a human would,” or “an objective function r is outer aligned if all models that perform optimally on r in the limit of perfect training and infinite data are intent aligned.”


What Are the Positive Outlooks on RLHF?
There is a trend for larger models toward better generalization ability. InstructGPT, for example, wasn’t supervised on tasks like following instructions in different languages and for code, but it still performs well in these generalizations. This, however, is probably not just reward model generalization. Otherwise, this behavior wouldn’t pop up in models trained to imitate human demonstrations, with Supervised Fine-Tuning (SFT). It is likely part of a scaling law. Theoretically, RLHF should generalize better than SFT since evaluation is easier than generation for most tasks. 

One approach to alignment could be to train a really robust reward model on human feedback and leverage its ability to generalize to difficult tasks to supervise highly capable agents. A lot of the important properties we want from alignment might be easier for models to understand if they’re already familiar with humans, so it’s plausible that if we fine-tune a large enough language model pretrained on the internet and train a reward model for it, it ends up generalizing the task of doing what humans want really well. The big problem with this approach is, for tasks that humans struggle to evaluate, we won’t know whether the reward model actually generalizes in a way that’s aligned with human intentions since we don’t have an evaluation procedure. In practice, the model learned is likely to overfit the reward model learned, to match the training data too closely. When trained long enough, the policy learns to exploit exceptions in the reward model. Importantly, if we can’t evaluate what the system is doing, we don’t know if its behavior is aligned with our goals. 

Still, RLHF counts as progress. In Learning from Human Preferences, using RLHF, OpenAI trained a reinforcement agent to backflip using around 900 individual bits of feedback from a human evaluator, as opposed to taking two hours to write their own reward function and achieve a much less elegant backflip than the one trained through human feedback. Without RLHF, approximating the reward function for a good backflip was almost impossible. With RLHF, it became possible to obtain a reward function that, when optimized by an RL policy, led to elegant backflips. But to train for human preferences is a bit more complex. Being polite is complex and fragile. Yet, ChatGPT tends to perform politely, more or less. RLHF can withstand more optimization pressure than SFT, so by using RLHF, you can obtain reward functions that withstand more optimization pressure than human-designed reward functions. 

However, there is a compendium of problems with RLHF.

### The Human Side of RLHF
On its surface RLHF appears to be a straightforward approach to outer alignment. However, a closer examination reveals several critical issues with this approach.

There is an oversight problem. In cases where an unaided human doesn’t know whether the AI action is good or bad, they will not be able to provide effective feedback. In cases where the unaided human is actively wrong about whether the action is good or bad, their feedback will actively select for the AI to deceive the humans, to characterize bad as good, to be a Schemer or a Sycophant. 

RLHF requires a ton of human feedback and still often fails. Despite the exorbitant amount of time and money spent hiring human labelers to create a dataset, benign failures still occur. The model is still susceptible to prompt injections, ways around the seed prompt, which can elicit toxic responses, unaligned with human preferences or values, or bypass security measures like guardrails to mitigate bias, which is as big a problem as ever. These guardrails themselves provide some evidence of left-leaning bias. 

As systems grow more advanced, much more effort may be needed to generate more complex data. The cost of obtaining this data may be prohibitive. As we push the limits of compute scale and build models with capabilities beyond that of human beings, the number of qualified annotators may dwindle.

RLHF relies on human feedback as a proxy, which is less reliable than real-time human feedback. Humans are prone to making systematic errors, and the annotators are no exception. In addition, the process of providing feedback for RLHF may have negative impacts on human wellbeing. 


###  Why responsible AI is important
Responsible AI is an emerging area of AI governance and use of the word "responsible" is an umbrella term that covers both ethics and democratization.

The heads of Microsoft and Google have publicly called for AI regulations, but as of this writing, there are no standards for accountability when AI programming creates unintended consequences. Often, bias can be introduced into AI by the data that's used to train machine learning models. When the training data is biased, it naturally follows that decisions made by the programming are also biased.

Now that software programs with artificial intelligence (AI) features are becoming more common, it is increasingly apparent that there is a need for standards in AI beyond those established by Isaac Asimov in his "Three Laws of Robotics." The technology can be misused accidentally (or on purpose) for a number of reasons -- and much of the misuse is caused by a bias in the selection of data to train AI programming.

### What are the principles of responsible AI?
AI and the machine learning models that support it should be comprehensive, explainable, ethical and efficient.

Comprehensiveness – comprehensive AI has clearly defined testing and governance criteria to prevent machine learning from being hacked easily.
explainable AI is programmed to describe its purpose, rationale and decision-making process in a way that can be understood by the average end user.
Ethical AI initiatives have processes in place to seek out and eliminate bias in machine learning models.
Efficient AI is able to run continually and respond quickly to changes in the operational environment.
### Why is responsible AI important?
An important goal of responsible AI is to reduce the risk that a minor change in an input's weight will drastically change the output of a machine learning model.

Within the context of conforming to the four tenets of corporate governance, responsible AI should be:

Each step of the model development process should be recorded in a way that cannot be altered by humans or other programming.
The data used to train machine models should not be biased.
The analytic models that support an AI initiative can be adapted to changing environments without introducing bias.
The organization deploying AI programming is sensitive to its potential impact -- both positive and negative.
### How do you design responsible AI?
Building a responsible AI governance framework can be a lot of work. Ongoing scrutiny is crucial to ensure an organization is committed to providing an unbiased, trustworthy AI. This is why it is crucial for an organization to have a maturity model or rubric to follow while designing and implementing an AI system.

At a base level, to be considered responsible, AI must be built with resources and technology according to a company-wide development standard that mandates the use of:

Shared code repositories
Approved model architectures
Sanctioned variables
Established bias testing methodologies to help determine the validity of tests for AI systems
Stability standards for active machine learning models to make sure AI programming works as intended

### References

https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/responsible-use-ai.html


https://www.microsoft.com/en-us/ai/our-approach?activetab=pivot1%3aprimaryr5

https://www.techtarget.com/searchenterpriseai/definition/responsible-AI

https://arxiv.org/abs/2301.11270

https://bdtechtalks.com/2023/01/16/what-is-rlhf/

https://wandb.ai/ayush-thakur/RLHF/reports/Understanding-Reinforcement-Learning-from-Human-Feedback-RLHF-Part-1--VmlldzoyODk5MTIx

https://en.wikipedia.org/wiki/Reinforcement_learning_from_human_feedback

https://huggingface.co/blog/rlhf

https://sinoglobalcapital.substack.com/p/can-ai-alignment-and-reinforcement

https://www.alignmentforum.org/posts/vwu4kegAEZTBtpT6p/thoughts-on-the-impact-of-rlhf-research
