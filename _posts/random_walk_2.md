
```
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector
import random
import pandas as pd

class RandomWalkerAgent(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)

    def step(self):
        # Use cached random choice for better performance
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False)
        self.model.grid.move_agent(self, random.choice(possible_steps))

class RandomWalkerModel(Model):
    def __init__(self, width=10, height=10, n_steps=20, num_agents=5):
        super().__init__()
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)
        self.num_agents = num_agents
        self.n_steps = n_steps

        # Initialize DataCollector with proper model reporters
        self.datacollector = DataCollector(
            agent_reporters={
                f"pos_x_{i}": lambda a, i=i: a.pos[0] if a.unique_id == i else None
                for i in range(num_agents)
            } | {
                f"pos_y_{i}": lambda a, i=i: a.pos[1] if a.unique_id == i else None
                for i in range(num_agents)
            }
        )

        # Initialize agents in a single comprehension
        for i in range(num_agents):
            agent = RandomWalkerAgent(i, self)
            self.schedule.add(agent)
            self.grid.place_agent(agent, (
                random.randrange(width),
                random.randrange(height)
            ))

    def step(self):
        self.datacollector.collect(self)
        self.schedule.step()

    def run_model(self):
        # Pre-allocate results collection
        for _ in range(self.n_steps):
            self.step()
        return self.datacollector.get_agent_vars_dataframe()


model = RandomWalkerModel()
results_df = model.run_model()
print(results_df.head(10))
```
