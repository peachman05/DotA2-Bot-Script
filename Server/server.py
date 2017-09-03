from flask import Flask, redirect, url_for, request, jsonify
import logging
from logging.handlers import RotatingFileHandler
import sys

#### CSV
import csv
import pandas as pd
import numpy as np


app = Flask(__name__)

@app.route('/',methods = ['POST', 'GET'])
def getValue():
	
   data = request.json
   print(data)

   df = pd.DataFrame()

   # dictTemp  = dict()
   # dictTemp['hp_weight'] = 1
   # dictTemp['distance_weight'] = 2
   # dictTemp['baseDamage_weight'] = 3
   # dictTemp['attackSpeed_weight'] = 4
   # dictTemp['creepDamageTaken_weight'] = 4
   # dictTemp['maxReward'] = 4

   df = df.append(data,ignore_index=True)

   with open('my_csv.csv', 'a') as f:
       df.to_csv(f, header=False, sep=',', encoding='utf-8',index=False)

   return str(data['maxReward']);


if __name__ == '__main__':
   app.run(host='0.0.0.0', port=8080 , debug=True)


# def run_episode(env, parameters):  
#     observation = env.reset()
#     totalreward = 0
#     for _ in xrange(200):
#         action = 0 if np.matmul(parameters,observation) < 0 else 1
#         observation, reward, done, info = env.step(action)
#         totalreward += reward
#         if done:
#             break
#     return totalreward


# bestparams = None  
# bestreward = 0  
# for _ in xrange(100):  
#     parameters = np.random.rand(4) * 2 - 1
#     reward = run_episode(env,parameters)
#     if reward > bestreward:
#         bestreward = reward
#         bestparams = parameters
#         # considered solved if the agent lasts 200 timesteps
#         if reward == 200:
#             break