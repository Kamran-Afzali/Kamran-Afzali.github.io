# Modeling Disease Spread: The SIR Epidemic Framework

From the aimless wandering of our random walker to the preference-driven relocations in Schelling's segregation model, we've explored how agent-based systems generate emergent patterns through individual behavior. Now we turn to a domain where these principles carry profound real-world implications: epidemic modeling. The spread of infectious diseases through populations represents one of the most pressing applications of agent-based modeling, combining spatial dynamics, state transitions, and temporal evolution into a framework that has guided public health policy for over a century.

The SIR model—representing Susceptible, Infected, and Recovered compartments—provides the foundational paradigm for understanding disease transmission. Originally formulated as a system of differential equations by Kermack and McKendrick in 1927, the model captures the essential dynamics of how infections propagate through populations. Our agent-based implementation brings these classical equations to life, allowing us to observe individual infection events while tracking population-level epidemic curves.

## The Mathematics of Contagion

The classical SIR model operates through a system of ordinary differential equations that describe how populations flow between three states. Let S(t), I(t), and R(t) represent the number of susceptible, infected, and recovered individuals at time t, with total population N = S(t) + I(t) + R(t). The dynamics follow:

dS/dt = -β S I / N

dI/dt = β S I / N - γ I

dR/dt = γ I

Here β represents the transmission rate—the probability per unit time that a susceptible individual becomes infected through contact with an infectious individual. The parameter γ denotes the recovery rate, with 1/γ giving the average duration of infection. The ratio R₀ = β/γ, known as the basic reproduction number, determines whether an epidemic will grow (R₀ > 1) or fade (R₀ < 1).

These differential equations assume homogeneous mixing—every individual has equal probability of contacting every other individual. Our agent-based approach relaxes this assumption, allowing us to incorporate spatial structure, heterogeneous contact patterns, and stochastic effects that deterministic models cannot capture. The agent-based formulation preserves the essential disease dynamics while adding layers of realism through explicit spatial representation.

## Building the Epidemic Agents

Our implementation begins with agents who carry disease states and transition between them according to epidemiological rules. Each agent exists in one of three states at any given time, with transitions governed by both deterministic timing and stochastic transmission:

```python
class PersonAgent(Agent):
    def __init__(self, model, state='S'):
        super().__init__(model)
        self.state = state  # 'S', 'I', or 'R'
        self.infection_time = 0
```

The state attribute encodes the fundamental epidemiological information—whether an individual can contract the disease, currently carries it, or has recovered and gained immunity. The infection_time counter tracks how long an agent has been infected, enabling us to implement recovery after a specified duration. This temporal tracking distinguishes our implementation from simpler models where recovery occurs probabilistically at each time step.

The agent's behavioral logic implements the core transmission dynamics. Infected agents have the opportunity to transmit disease to susceptible neighbors at each time step, with transmission probability determined by the model's infection rate parameter:

```python
def step(self):
    if self.state == 'I':
        self.infect()
        self.infection_time += 1
        # Recover after infection period
        if self.infection_time >= self.model.recovery_time:
            self.state = 'R'
            self.infection_time = 0

def infect(self):
    neighbors = self.model.grid.get_neighbors(
        self.pos, moore=True, include_center=False)
    susceptible_neighbors = [agent for agent in neighbors 
                            if agent.state == 'S']
    for neighbor in susceptible_neighbors:
        if self.random.random() < self.model.infection_rate:
            neighbor.state = 'I'
```

This infection mechanism embodies the spatial nature of disease transmission. Rather than having equal probability of contacting any individual in the population, agents only interact with immediate neighbors on the grid. This spatial constraint more accurately reflects real-world transmission, where diseases spread primarily through local contact networks rather than uniformly across entire populations.

The recovery process operates deterministically—after a fixed number of time steps in the infected state, agents transition to recovered status. This deterministic recovery simplifies the model while capturing the essential feature that infections have finite duration. In reality, recovery times vary across individuals, but the fixed duration provides a reasonable approximation that keeps the model tractable while preserving key dynamics.

## Orchestrating the Epidemic

The model class coordinates the initialization and evolution of the epidemic, managing both the spatial arrangement of agents and the collection of population-level statistics:

```python
class EpidemicModel(Model):
    def __init__(self, width=50, height=50, density=0.8, 
                 initial_infected=5, infection_rate=0.3, recovery_time=10):
        super().__init__()
        self.width = width
        self.height = height
        self.infection_rate = infection_rate
        self.recovery_time = recovery_time
        self.grid = MultiGrid(width, height, torus=True)
        
        # Create agents
        n_agents = int(width * height * density)
        for i in range(n_agents):
            state = 'I' if i < initial_infected else 'S'
            agent = PersonAgent(self, state)
            
            # Place agent on grid
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            self.grid.place_agent(agent, (x, y))
```

The initialization establishes a population where a small number of infected individuals—the index cases—exist within a largely susceptible population. This setup mirrors real epidemic scenarios where diseases typically enter populations through a limited number of initial infections. The random spatial distribution ensures that starting configurations don't bias the subsequent dynamics, though the specific locations of initial infections can significantly influence early epidemic trajectories.

The model's parameters provide levers for exploring different epidemic scenarios. Population density determines how many agents occupy the grid, affecting the average number of neighbors each agent encounters. Higher density increases contact rates, accelerating transmission but also allowing faster spatial spread. The infection rate β controls transmission probability per contact, while the recovery time 1/γ determines infection duration. Together, these parameters determine the epidemic's overall trajectory.

Data collection mechanisms track the population-level dynamics that emerge from individual transmission events:

```python
self.datacollector = DataCollector(
    model_reporters={
        "Susceptible": lambda m: sum(1 for a in m.agents if a.state == 'S'),
        "Infected": lambda m: sum(1 for a in m.agents if a.state == 'I'),
        "Recovered": lambda m: sum(1 for a in m.agents if a.state == 'R')
    }
)
```

These reporters count agents in each state at every time step, generating the familiar epidemic curves that show how disease prevalence evolves over time. The susceptible population typically declines monotonically as individuals become infected, while the infected population first rises then falls as recovery outpaces new infections. The recovered population accumulates over time, eventually comprising most of the population if the epidemic runs its course.

## The Temporal Evolution of Epidemics

The simulation's step function advances the epidemic by allowing all agents to execute their behavioral rules:

```python
def step(self):
    # Shuffle and activate all agents
    self.agents.shuffle_do("step")
    self.datacollector.collect(self)
```

The shuffling ensures that agent activation order doesn't systematically bias transmission patterns—a subtle but important consideration in agent-based models where temporal ordering can affect outcomes. Without shuffling, agents processed early in each step would have systematic advantages or disadvantages compared to those processed later.

Running the simulation reveals the characteristic trajectory of epidemic spread:

```python
model = EpidemicModel(
    width=50, 
    height=50, 
    density=0.8,
    initial_infected=5,
    infection_rate=0.25,
    recovery_time=10
)

for step in range(n_steps):
    grid_state = np.zeros((model.height, model.width))
    for agent in model.agents:
        x, y = agent.pos
        if agent.state == 'S':
            grid_state[y, x] = 0
        elif agent.state == 'I':
            grid_state[y, x] = 1
        elif agent.state == 'R':
            grid_state[y, x] = 2
    grid_states.append(grid_state.copy())
    model.step()
```

This execution loop captures snapshots of the spatial distribution at each time step, enabling visualization of how infection spreads across the population. The progression typically shows initial growth from the index cases, followed by rapid spatial expansion as the infection wave propagates through susceptible neighborhoods, and eventually deceleration as the pool of susceptible individuals depletes.

## Analyzing Epidemic Dynamics

The collected data reveals several key epidemiological features. The epidemic curve—the time series of infected individuals—typically exhibits a characteristic shape: exponential growth during early stages when most contacts involve susceptible individuals, a peak when depletion of susceptibles slows transmission below recovery rates, and eventual decline as few susceptible individuals remain. The timing and magnitude of this peak carry crucial public health implications, determining healthcare system strain and overall disease burden.

```python
data = model.datacollector.get_model_vars_dataframe()

plt.plot(data['Susceptible'], label='Susceptible', color='blue', linewidth=2)
plt.plot(data['Infected'], label='Infected', color='red', linewidth=2)
plt.plot(data['Recovered'], label='Recovered', color='green', linewidth=2)
plt.xlabel('Time Steps', fontsize=12)
plt.ylabel('Number of Agents', fontsize=12)
plt.title('SIR Epidemic Model Dynamics', fontsize=14, fontweight='bold')
plt.legend(fontsize=10)
plt.grid(alpha=0.3)
```

The final size of the epidemic—the total proportion of the population that eventually becomes infected—depends critically on the basic reproduction number R₀. For R₀ > 1, the epidemic takes off, ultimately infecting a substantial fraction of the population. The final size relation provides a transcendental equation connecting R₀ to the proportion escaping infection:

S(∞)/N = exp(-R₀(1 - S(∞)/N))

where S(∞) represents the number of individuals who never become infected. This equation has no closed-form solution but can be solved numerically to predict epidemic outcomes from model parameters.

The spatial visualization captures another critical feature—the wave-like propagation of infection through space:

```python
plt.imshow(grid_states[-1], cmap='RdYlGn_r', interpolation='nearest')
plt.colorbar(ticks=[0, 1, 2], label='State')
plt.title('Final Spatial Distribution', fontsize=14, fontweight='bold')
plt.xlabel('X Position', fontsize=12)
plt.ylabel('Y Position', fontsize=12)
```

Unlike well-mixed models where everyone has equal infection risk, spatial structure creates traveling waves where infection spreads outward from initial foci. These waves generate complex spatial patterns influenced by population density, spatial heterogeneity, and stochastic fluctuations. The final state typically shows clusters of recovered individuals surrounding the initial infection sites, with remaining susceptible individuals concentrated in areas the epidemic wave never reached.

## The Role of Stochasticity

Agent-based epidemic models inherently incorporate stochastic effects that deterministic differential equations cannot capture. In small populations or during early epidemic stages, random fluctuations can significantly alter outcomes. An infection introduced into a population might spark a major epidemic or might stochastically die out before gaining momentum—a phenomenon called "fade-out" that deterministic models cannot represent.

The transmission probability creates binomial uncertainty at each contact event. When an infected agent encounters a susceptible neighbor, transmission occurs with probability β but fails with probability (1-β). This randomness accumulates across many contact events, generating variability in epidemic trajectories even when starting from identical initial conditions. Running multiple replicate simulations reveals this intrinsic stochasticity through the distribution of epidemic sizes and peak timing.

The spatial structure interacts with stochasticity in subtle ways. In spatially structured populations, local clusters of infected individuals can create infection hotspots that drive regional outbreaks. Random placement of index cases determines which regions experience early seeding, setting the stage for different spatial patterns. This interplay between spatial structure and stochastic transmission generates rich dynamics that homogeneous models miss entirely.

## Extensions and Variations

The basic SIR framework admits numerous extensions that capture additional epidemiological realities. Adding an exposed (E) state creates the SEIR model, where newly infected individuals undergo a latency period before becoming infectious. This modification better represents diseases like influenza or COVID-19, where substantial delays exist between infection and symptom onset:

```python
def step(self):
    if self.state == 'E':
        self.exposure_time += 1
        if self.exposure_time >= self.model.latency_period:
            self.state = 'I'
            self.exposure_time = 0
    elif self.state == 'I':
        self.infect()
        self.infection_time += 1
        if self.infection_time >= self.model.recovery_time:
            self.state = 'R'
```

Vital dynamics—births and deaths—transform short-term epidemic models into long-term endemic disease models. Adding a birth rate that creates new susceptible individuals and a natural death rate allows examination of how diseases persist in populations over time. Some diseases reach endemic equilibria where new infections exactly balance recoveries, maintaining constant disease prevalence indefinitely.

Heterogeneous contact patterns provide another important extension. Rather than uniform spatial grids, more realistic models might incorporate social network structures where individuals have varying numbers of contacts. High-degree nodes—individuals with many contacts—play disproportionate roles in disease spread, suggesting targeted interventions focusing on these super-spreaders might efficiently control transmission.

Behavioral responses to epidemics add feedback loops between disease prevalence and transmission rates. As epidemics become more visible, individuals might reduce contacts through social distancing or increase protective behaviors like mask-wearing. These behavioral changes effectively reduce transmission rates β during epidemic peaks, potentially preventing healthcare system collapse but also prolonging epidemic duration by allowing susceptible populations to persist longer.

## Public Health Implications

Agent-based epidemic models inform public health decision-making by allowing exploration of intervention scenarios. Vaccination campaigns can be modeled by moving a proportion of agents from susceptible to recovered states before epidemic initiation. The herd immunity threshold—the vaccination coverage needed to prevent epidemic spread—emerges naturally from simulations, typically occurring when (1 - 1/R₀) of the population gains immunity.

Pharmaceutical interventions like treatment that reduces infection duration can be explored by modifying recovery times for treated individuals. The model can assess how different treatment coverages and timings affect epidemic trajectories, informing resource allocation decisions during disease outbreaks. Non-pharmaceutical interventions like quarantine can be implemented by restricting movement or contacts for infected individuals, revealing how different quarantine strategies influence transmission.

The spatial aspects of agent-based models prove particularly valuable for understanding how local interventions affect regional disease dynamics. Targeted interventions in high-transmission neighborhoods might prevent broader spread more efficiently than population-wide measures. Geographic targeting of limited resources—whether vaccines, treatments, or public health messaging—can be optimized through spatial epidemic simulations.

## Computational Considerations

From an implementation perspective, epidemic models demonstrate efficient use of Mesa's agent-based modeling capabilities. The state-based agent architecture cleanly separates different disease stages while the grid structure naturally represents spatial contact patterns. Data collection through Mesa's DataCollector provides automatic time series generation without manual bookkeeping.

The visualization capabilities showcase the power of combining temporal and spatial representations:

```python
fig_anim, ax_anim = plt.subplots(figsize=(8, 8))
im_anim = ax_anim.imshow(grid_states[0], cmap='RdYlGn_r', interpolation='nearest', vmin=0, vmax=2)
plt.colorbar(im_anim, ax=ax_anim, ticks=[0, 1, 2], label='State (0=S, 1=I, 2=R)')
title_anim = ax_anim.set_title('SIR Epidemic Spread - Step 0', fontsize=14, fontweight='bold')

stats_text = ax_anim.text(0.02, 0.98, '', transform=ax_anim.transAxes, 
                          fontsize=10, verticalalignment='top',
                          bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

def animate(frame):
    im_anim.set_array(grid_states[frame])
    title_anim.set_text(f'SIR Epidemic Spread - Step {frame}')
    
    s_count = int(data['Susceptible'].iloc[frame])
    i_count = int(data['Infected'].iloc[frame])
    r_count = int(data['Recovered'].iloc[frame])
    stats_text.set_text(f'S: {s_count}\nI: {i_count}\nR: {r_count}')
    
    return [im_anim, title_anim, stats_text]

anim = FuncAnimation(fig_anim, animate, frames=range(0, len(grid_states), 2), 
                     interval=100, blit=True, repeat=True)
```

These animations reveal spatial-temporal dynamics that static plots cannot capture, showing how infection waves propagate through populations and how spatial heterogeneities influence disease spread. The real-time statistics overlay provides quantitative context for the visual patterns, connecting individual transmission events to population-level epidemic curves.

## Limitations and Future Directions

While agent-based epidemic models offer significant advantages over classical differential equation approaches, they also face important limitations. Computational costs scale with population size, potentially limiting the size of populations that can be simulated efficiently. Large-scale epidemic modeling might require hybrid approaches combining agent-based detail in critical regions with coarser representations elsewhere.

Parameter estimation presents another challenge. Real epidemic data typically provide only aggregate counts of cases over time, not detailed information about individual transmission events or contact patterns. Calibrating agent-based models to real data requires sophisticated inference methods, often involving computationally intensive approaches like approximate Bayesian computation or likelihood-free inference.

Model validation remains an ongoing concern. Agent-based models involve numerous design choices—grid topology, neighborhood structures, agent behaviors—that might influence outcomes in ways that aren't immediately obvious. Careful sensitivity analysis examining how results depend on these structural assumptions becomes essential for building confidence in model predictions.

Despite these challenges, agent-based epidemic modeling continues advancing, incorporating increasing realism through detailed demographic structure, realistic contact networks derived from empirical data, and sophisticated behavioral responses. These enhanced models played crucial roles in guiding policy responses to recent disease outbreaks, demonstrating how computational modeling can directly inform public health decision-making.

## From Individuals to Populations

The SIR epidemic model exemplifies how agent-based approaches bridge individual behavior and population-level outcomes. Each agent follows simple rules—attempt to infect neighbors when infected, recover after a specified duration—yet these individual actions aggregate into complex population dynamics characterized by exponential growth, epidemic peaks, and eventual decline. The spatial patterns emerging from local transmission create traveling waves and clustering phenomena absent from well-mixed models.

This connection between individual and collective scales appears throughout agent-based modeling, from our original random walker exploring space to Schelling agents creating segregated neighborhoods. In each case, simple individual rules generate emergent patterns that transcend their components. For epidemic models, this emergence carries life-and-death consequences, making the careful study of how individual transmission events shape population health trajectories not just intellectually fascinating but critically important.

As we continue exploring agent-based modeling techniques, the epidemic framework provides a template for thinking about state transitions, temporal dynamics, and spatial propagation. These concepts recur across domains—from information spreading through social networks to innovations diffusing through markets—suggesting that the lessons learned from modeling disease spread extend far beyond epidemiology itself. The fundamental insight remains constant: understanding how systems evolve requires examining both the rules governing individual behavior and the structures through which those individuals interact.



```python
try:
    import mesa
except ImportError:
    !pip install -q mesa
    import mesa

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from IPython.display import HTML
from mesa import Agent, Model
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector

# Agent class
class PersonAgent(Agent):
    def __init__(self, model, state='S'):
        super().__init__(model)
        self.state = state  # 'S', 'I', or 'R'
        self.infection_time = 0
        
    def step(self):
        if self.state == 'I':
            self.infect()
            self.infection_time += 1
            # Recover after infection period
            if self.infection_time >= self.model.recovery_time:
                self.state = 'R'
                self.infection_time = 0
    
    def infect(self):
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False)
        susceptible_neighbors = [agent for agent in neighbors 
                                if agent.state == 'S']
        for neighbor in susceptible_neighbors:
            if self.random.random() < self.model.infection_rate:
                neighbor.state = 'I'

# Model class
class EpidemicModel(Model):
    def __init__(self, width=50, height=50, density=0.8, 
                 initial_infected=5, infection_rate=0.3, recovery_time=10):
        super().__init__()
        self.width = width
        self.height = height
        self.infection_rate = infection_rate
        self.recovery_time = recovery_time
        self.grid = MultiGrid(width, height, torus=True)
        
        # Create agents
        n_agents = int(width * height * density)
        for i in range(n_agents):
            state = 'I' if i < initial_infected else 'S'
            agent = PersonAgent(self, state)
            
            # Place agent on grid
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            self.grid.place_agent(agent, (x, y))
        
        # Data collection
        self.datacollector = DataCollector(
            model_reporters={
                "Susceptible": lambda m: sum(1 for a in m.agents if a.state == 'S'),
                "Infected": lambda m: sum(1 for a in m.agents if a.state == 'I'),
                "Recovered": lambda m: sum(1 for a in m.agents if a.state == 'R')
            }
        )
        self.datacollector.collect(self)
    
    def step(self):
        # Shuffle and activate all agents
        self.agents.shuffle_do("step")
        self.datacollector.collect(self)

# Run simulation and collect frames for animation
print("Running SIR Epidemic Model with animation...")
model = EpidemicModel(
    width=50, 
    height=50, 
    density=0.8,
    initial_infected=5,
    infection_rate=0.25,
    recovery_time=10
)

# Store grid states for animation
grid_states = []
n_steps = 100

for step in range(n_steps):
    # Capture grid state
    grid_state = np.zeros((model.height, model.width))
    for agent in model.agents:
        x, y = agent.pos
        if agent.state == 'S':
            grid_state[y, x] = 0
        elif agent.state == 'I':
            grid_state[y, x] = 1
        elif agent.state == 'R':
            grid_state[y, x] = 2
    grid_states.append(grid_state.copy())
    
    model.step()
    if step % 20 == 0:
        print(f"Step {step}/{n_steps}")

print("Simulation complete! Creating visualizations...")
    
# Get and plot results
data = model.datacollector.get_model_vars_dataframe()

# Create figure with 3 subplots
fig = plt.figure(figsize=(16, 5))

# Plot 1: Time series
ax1 = plt.subplot(1, 3, 1)
plt.plot(data['Susceptible'], label='Susceptible', color='blue', linewidth=2)
plt.plot(data['Infected'], label='Infected', color='red', linewidth=2)
plt.plot(data['Recovered'], label='Recovered', color='green', linewidth=2)
plt.xlabel('Time Steps', fontsize=12)
plt.ylabel('Number of Agents', fontsize=12)
plt.title('SIR Epidemic Model Dynamics', fontsize=14, fontweight='bold')
plt.legend(fontsize=10)
plt.grid(alpha=0.3)

# Plot 2: Final state visualization
ax2 = plt.subplot(1, 3, 2)
plt.imshow(grid_states[-1], cmap='RdYlGn_r', interpolation='nearest')
plt.colorbar(ticks=[0, 1, 2], label='State')
plt.title('Final Spatial Distribution', fontsize=14, fontweight='bold')
plt.xlabel('X Position', fontsize=12)
plt.ylabel('Y Position', fontsize=12)

# Plot 3: Animation frame
ax3 = plt.subplot(1, 3, 3)
im = ax3.imshow(grid_states[0], cmap='RdYlGn_r', interpolation='nearest', vmin=0, vmax=2)
plt.colorbar(im, ax=ax3, ticks=[0, 1, 2], label='State')
title = ax3.set_title('Animation - Step 0', fontsize=14, fontweight='bold')
ax3.set_xlabel('X Position', fontsize=12)
ax3.set_ylabel('Y Position', fontsize=12)

plt.tight_layout()
plt.show()

print(f"\nFinal Statistics (after {len(data)} steps):")
print(f"Susceptible: {data['Susceptible'].iloc[-1]}")
print(f"Infected: {data['Infected'].iloc[-1]}")
print(f"Recovered: {data['Recovered'].iloc[-1]}")
print(f"Peak infection: {data['Infected'].max()} at step {data['Infected'].idxmax()}")

# Create animation
print("\nCreating animation (this may take a moment)...")
fig_anim, ax_anim = plt.subplots(figsize=(8, 8))
im_anim = ax_anim.imshow(grid_states[0], cmap='RdYlGn_r', interpolation='nearest', vmin=0, vmax=2)
plt.colorbar(im_anim, ax=ax_anim, ticks=[0, 1, 2], label='State (0=S, 1=I, 2=R)')
title_anim = ax_anim.set_title('SIR Epidemic Spread - Step 0', fontsize=14, fontweight='bold')
ax_anim.set_xlabel('X Position', fontsize=12)
ax_anim.set_ylabel('Y Position', fontsize=12)

# Add statistics text
stats_text = ax_anim.text(0.02, 0.98, '', transform=ax_anim.transAxes, 
                          fontsize=10, verticalalignment='top',
                          bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

def animate(frame):
    im_anim.set_array(grid_states[frame])
    title_anim.set_text(f'SIR Epidemic Spread - Step {frame}')
    
    # Update statistics
    s_count = int(data['Susceptible'].iloc[frame])
    i_count = int(data['Infected'].iloc[frame])
    r_count = int(data['Recovered'].iloc[frame])
    stats_text.set_text(f'S: {s_count}\nI: {i_count}\nR: {r_count}')
    
    return [im_anim, title_anim, stats_text]

# Create animation (sample every 2 frames for speed)
anim = FuncAnimation(fig_anim, animate, frames=range(0, len(grid_states), 2), 
                     interval=100, blit=True, repeat=True)

plt.close()  # Close the figure to prevent duplicate display
print("Animation ready!")

# Display animation
HTML(anim.to_jshtml())
```
