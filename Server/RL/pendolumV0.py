import gym
import numpy as np
import random
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import Adam

from collections import deque

class DQN:
    def __init__(self, env , batch_size):
        self.env = env
        self.batch_size = batch_size
        self.memory = deque(maxlen=2000)


        self.epsilon = 1.0
        self.epsilon_min = 0.01
        self.epsilon_decay = 0.995


        self.learning_rate = 0.001
        self.discount_rate = 0.8

        self.model = self.create_model();
        self.target_model = self.create_model();

    def mem(self,data):
        self.memory.append(data);

    def act(self,cur_state):
        self.epsilon *= self.epsilon_decay
        self.epsilon = max(self.epsilon_min, self.epsilon)

        if np.random.random() < self.epsilon :
            return self.env.action_space.sample()
        else:
            predict_array = self.model.predict(cur_state)
            return np.argmax(predict_array)
            # print(predict_array)
            # print(np.argmax(predict_array))
        

    def create_model(self):
        state_shape = self.env.observation_space.shape        
        model = Sequential()
        model.add( Dense(32, input_dim=state_shape[0], activation='relu') )
        model.add(Dense(48, activation="relu"))
        model.add(Dense(24, activation="relu"))
        model.add(Dense(1))
        model.compile(loss="mean_squared_error",
            optimizer=Adam(lr=self.learning_rate))
        return model

    def replay(self):
        minibatch = random.sample(self.memory, self.batch_size)

        for sample_data in minibatch:
            cur_state,new_state,action,reward,done = sample_data
            target_output = self.model.predict(cur_state)
            # print(q_predict)
            if done :
                target_output[0][action] = reward
            else:
                q_future = max( self.model.predict(new_state)[0] )
                target_output[0][action] = reward + self.discount_rate * q_future 
            
            self.model.fit(cur_state, target_output, epochs=1, verbose=0)

    def update_target(self):
        self.target_model.set_weights( self.model.get_weights() );

def main():

    env = gym.make("Pendulum-v0")

    trials  = 3000
    trial_len = 500
    batch_size = 128
    dqn_agent = DQN(env=env,batch_size= batch_size)

      
    # dqn_agent.save_model("success.model")
    for trial in range(trials):
        cur_state = env.reset().reshape(1,3)
        for t in range(trial_len):
            action = dqn_agent.act(cur_state);
           
            listAction = np.expand_dims(action, axis=0)
            print(listAction)
            new_state, reward, done, info = env.step( listAction )
            dqn_agent.mem([cur_state,new_state.reshape(1,3),action,reward,done]);

            if done:
                print("trial "+str(trial)+" finish "+str(t))
                break            

        if len(dqn_agent.memory) > batch_size:
            dqn_agent.replay();
        dqn_agent.update_target();   

       

if __name__ == "__main__":
    main()