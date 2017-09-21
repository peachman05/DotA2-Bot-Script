import gym
import numpy as np
import random
import collections
import itertools
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import Adam

from collections import deque

class DQN:
    def __init__(self, env):
        self.env     = env
        self.memory  = deque(maxlen=2000)
        
        self.gamma = 0.7
        self.epsilon = 1.0
        self.epsilon_min = 0.01
        self.epsilon_decay = 0.995
        self.learning_rate = 0.001
        self.tau = .125

        self.model        = self.create_model()
        self.target_model = self.create_model()

    def create_model(self):
        model   = Sequential()
        state_shape  = self.env.observation_space.shape
        model.add(Dense(24, input_dim=state_shape[0], activation="relu"))
        model.add(Dense(48, activation="relu"))
        model.add(Dense(24, activation="relu"))
        model.add(Dense(self.env.action_space.n))
        model.compile(loss="mean_squared_error",
            optimizer=Adam(lr=self.learning_rate))
        return model

    def act(self, state):
        self.epsilon *= self.epsilon_decay
        self.epsilon = max(self.epsilon_min, self.epsilon)
        if np.random.random() < self.epsilon:
            return self.env.action_space.sample()
        return np.argmax(self.model.predict(state)[0])

    def remember(self, state, action, reward, new_state, done):
        self.memory.append([state, action, reward, new_state, done])

    def replay(self):
        batch_size = 128
        if len(self.memory) < batch_size: 
            return
        # if len(self.memory) > 20:
        #     maxI = len(self.memory) 
        #     minI = maxI - 10
        #     print(collections.deque(itertools.islice(self.memory, minI, maxI)))
        #     print("-----------")

        samples = random.sample(self.memory, batch_size)
        for sample in samples:
            state, action, reward, new_state, done = sample
            target = self.target_model.predict(state)
            if done:
                target[0][action] = reward
            else:
                Q_future = max(self.target_model.predict(new_state)[0])
                target[0][action] = reward + Q_future * self.gamma
            self.model.fit(state, target, epochs=1, verbose=0)

    def replayDone(self,dataMem,i):
        
        state, action, reward, new_state, done = dataMem
        target = self.target_model.predict(state)   
        target[0][action] = reward  
        self.model.fit(state, target, epochs=10, verbose=0)

        maxI = len(self.memory) 
        minI = maxI - i
        samples = collections.deque(itertools.islice(self.memory, minI, maxI))
        for sample in samples:
            state, action, reward, new_state, done = sample
            target = self.target_model.predict(state)
            if done:
                target[0][action] = reward
            else:
                Q_future = max(self.target_model.predict(new_state)[0])
                target[0][action] = reward + Q_future * self.gamma
            self.model.fit(state, target, epochs=3, verbose=0)

    def target_train(self):
        weights = self.model.get_weights()
        target_weights = self.target_model.get_weights()
        for i in range(len(target_weights)):
            target_weights[i] = weights[i] * self.tau + target_weights[i] * (1 - self.tau)
        self.target_model.set_weights(target_weights)

    def save_model(self, fn):
        self.model.save(fn)

def main():
    env     = gym.make("MountainCar-v0")
    gamma   = 0.9
    epsilon = .95

    trials  = 10000
    trial_len = 500

    # updateTargetNetwork = 1000
    dqn_agent = DQN(env=env)
    steps = []
    dqn_agent.save_model("success.model")
    for trial in range(trials):
        cur_state = env.reset().reshape(1,2)
        rewardall = 0
        i = 0
        dataMem = None
        for step in range(trial_len):
            # if trial > 20:
            #     env.render()
            action = dqn_agent.act(cur_state)
            new_state, reward, done, _ = env.step(action)
            

            # reward = reward if not done else -20
            new_state = new_state.reshape(1,2)

            dataMem = [cur_state, action, reward, new_state, done]

            dqn_agent.remember(cur_state, action, reward, new_state, done)
            
            
            
            rewardall += reward
            

            cur_state = new_state
            i += 1

            if done:                
                break

        if i >= 199:

            print("Failed to complete in trial {}".format(trial))
            dqn_agent.replay()       # internally iterates default (prediction) model
            dqn_agent.target_train() # iterates target model
            if step % 10 == 0:
                dqn_agent.save_model("trial-{}.model".format(trial))
        else:
            print("Completed in {} trials".format(trial))
            print(rewardall)
            print(i)

            dqn_agent.replayDone(dataMem,i)
            dqn_agent.target_train()

            for trial2 in range(4):
                cur_state = env.reset().reshape(1,2)
                rewardall = 0
                for step2 in range(trial_len):
                    env.render()
                    action = dqn_agent.act(cur_state)
                    new_state, reward, done, _ = env.step(action)


            dqn_agent.save_model("success.model")
            # break
        
if __name__ == "__main__":
    main()