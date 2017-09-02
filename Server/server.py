from flask import Flask, redirect, url_for, request, jsonify

import logging
from logging.handlers import RotatingFileHandler
import sys

app = Flask(__name__)

@app.route('/',methods = ['POST', 'GET'])
def getValue():
	
   data = request.json
   print(data)
   return str(data['rewardAll']);


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