from flask import Flask, redirect, url_for, request, jsonify
import logging
from logging.handlers import RotatingFileHandler
import sys

import logging
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

## ML
import tensorflow as tf
from keras import backend as K
import numpy as np
import random
from pathlib import Path
import os
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import Adam
from collections import deque



#### CSV
import csv
import pandas as pd
import numpy as np


PREDICT_STATE = 20;
UPDATE_STATE = 21;

app = Flask(__name__)



class DQN:
    def __init__(self, num_obs,num_action):
        self.num_obs = num_obs
        self.num_action = num_action
        self.memory  = deque(maxlen=2000)
        
        self.gamma = 0.85
        self.epsilon = 1.0
        self.epsilon_min = 0.01
        self.epsilon_decay = 0.995
        self.learning_rate = 0.005
        self.tau = .125

        self.model        = self.create_model()
        self.target_model = self.create_model()

    def create_model(self):
        model   = Sequential()        
        model.add(Dense(24, input_dim= self.num_obs, activation="relu"))
        model.add(Dense(48, activation="relu"))
        model.add(Dense(24, activation="relu"))
        model.add(Dense(self.num_action))
        model.compile(loss="mean_squared_error",
            optimizer=Adam(lr=self.learning_rate))
        return model

    def act(self, state):
        self.epsilon *= self.epsilon_decay
        self.epsilon = max(self.epsilon_min, self.epsilon)
        if np.random.random() < self.epsilon:
            return random.randint(0, self.num_action - 1)
        return np.argmax(self.model.predict(state)[0])

    def remember(self, state, action, reward, new_state, done):
        self.memory.append([state, action, reward, new_state, done])

    def replay(self):
        batch_size = 32
        if len(self.memory) < batch_size: 
            return

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

    def target_train(self):
        weights = self.model.get_weights()
        target_weights = self.target_model.get_weights()
        for i in range(len(target_weights)):
            target_weights[i] = weights[i] * self.tau + target_weights[i] * (1 - self.tau)
        self.target_model.set_weights(target_weights)

    def save_model(self, fn):
        self.model.save(fn)

dqn_save = None
checkFirst = True
old_state = []

@app.route('/',methods = ['POST', 'GET'])
def getValue():
	   
  data = request.json

  global old_state , dqn_save , checkFirst  
  

  dqn_agent = None
  if checkFirst:
    dqn_agent = dqn_agent = DQN(num_obs=6,num_action=3)
    checkFirst = False
  else:
    dqn_agent = dqn_save

  if data['method'] == PREDICT_STATE :
      reward = data['reward'] #2
      done = False
      new_state = np.asarray(data['observation']).reshape(1,6) #np.asarray([1,1,1,1,1,1]).reshape(1,6)
      # print("predict state")
      # print(data)
      print(reward)

      action = dqn_agent.act(new_state)
      # print("kkkkkkkkk"+str(action))

      if len(old_state) != 0 :
        dqn_agent.remember(old_state, action, reward, new_state, done)
        dqn_agent.replay()       # internally iterates default (prediction) model
        dqn_agent.target_train() # iterates target model
        dqn_agent.save_model("success.model") 

      dqn_save = dqn_agent
      old_state = new_state

      return str(action)
  elif data['method'] == UPDATE_STATE:
      print("update state")
  
  return "0"; 

if __name__ == '__main__':
  print("ready")
  app.run(host='0.0.0.0', port=8080 , debug=True)

