
import gym
import numpy as np
import random

env = gym.make("Pendulum-v0")
# for trial in range(100):
#         cur_state = env.reset()
#         for t in range(500):
#             # action = dqn_agent.act(cur_state);
           
#             listAction = env.action_space.sample()
#             print(listAction)
#             new_state, reward, done, info = env.step( listAction )