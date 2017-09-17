from flask import Flask, redirect, url_for, request, jsonify
import logging
from logging.handlers import RotatingFileHandler
import sys

## ML
import tensorflow as tf
import numpy as np
import random
from pathlib import Path
import os



#### CSV
import csv
import pandas as pd
import numpy as np

PREDICT_STATE = 20
UPDATE_STATE = 21

LAST_HIT_ACTION = 0;
ATTACK_ACTION = 1;
RETREAT_ACTION = 2;

dirFile = os.path.dirname(__file__)
filename = os.path.join(dirFile, 'tmp/model.ckpt')

e = 0.1

def policy_gradient():
    with tf.variable_scope("policy"):
        params = tf.get_variable("policy_parameters",[6,3]) ## 6 input
        state = tf.placeholder("float",[None,6]) ## 6 input
        actions = tf.placeholder("float",[None,3]) ## 3 action
        advantages = tf.placeholder("float",[None,1]) ## reward
        linear = tf.matmul(state,params)
        probabilities = tf.nn.softmax(linear)
        mulProb = tf.multiply(probabilities, actions)
        good_probabilities = tf.reduce_sum(mulProb,reduction_indices=[1])
        eligibility = tf.log(good_probabilities) * advantages
        loss = -tf.reduce_sum(eligibility)
        optimizer = tf.train.AdamOptimizer(0.01).minimize(loss)
        return probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss , good_probabilities

def predictNextState(obs_vector,policy_grad,sess):

   probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss,good_probabilities = policy_grad
   

   actionTodo = None
   if np.random.rand(1) < e:
       actionTodo = random.randint(0, 2)
   else:
       probs,pa,li = sess.run([probabilities,params,linear],feed_dict={state: obs_vector})
       actionTodo = np.argmax(probs)

   # print(actionTodo)
   return actionTodo



policy_grad = policy_gradient()
sess = None
saver = tf.train.Saver()

my_file = Path("/tmp/model.ckpt")
if my_file.is_file():
   saver.restore(sess, filename)
else:
   sess = tf.InteractiveSession()
   sess.run(tf.global_variables_initializer())






app = Flask(__name__)

@app.route('/',methods = ['POST', 'GET'])
def getValue():
	
   data = request.json
   
   # print(type(data['method']))
   if data['method'] == PREDICT_STATE :
      # print("predict")
      obs_vector = np.expand_dims( data['observation'] , axis=0)
      return str(predictNextState(obs_vector,policy_grad,sess));
   elif data['method'] == UPDATE_STATE:
      probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss,good_probabilities = policy_grad
      print("update state")      
      # data['observation']
      print(data)

      rewardArray_vector = np.expand_dims(data['observation']['reward'], axis=1)
      # action_vector = np.expand_dims(data['observation']['action'], axis=1)
      # print(action_vector)

      obeservation_numpy = np.asarray(data['observation']['observation'], dtype=None, order=None)
      actions_numpy = np.asarray(data['observation']['action'], dtype=None, order=None)
      # print(obeservation_numpy)
      # print(rewardArray_vector)
      print(len(data['observation']['reward']))
      print(len(data['observation']['observation']))
      print(len(data['observation']['action']))
      
      stateTemp = [ [0,0,0,0,0,1],[1,1,1,1,1,1] ]
      actionTemp = [[0,0,1],[1,0,0]]

      # sess.run([optimizer,loss], feed_dict={state: obeservation_numpy, advantages: rewardArray_vector, actions:actions_numpy })
      sess.run([mulProb], feed_dict={state: data['observation']['observation'] , actions: data['observation']['action'] })

      save_path = saver.save(sess, filename)
      print("Model saved in file: %s" % save_path)

      return "0"      
      # return "ok"



   # df = pd.DataFrame()

   # df = df.append(data,ignore_index=True)

   # with open('my_csv.csv', 'a') as f:
   #     df.to_csv(f, header=False, sep=',', encoding='utf-8',index=False)





# def run_episode(env, policy_grad, sess):
#     probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss,good_probabilities = policy_grad
    
#     observation = env.reset()
#     totalreward = 0
#     statesArray = []
#     actionsArray = []
 
#     rewardArray = []
#     pa = None

#     for t in range(200):
 
#         obs_vector = np.expand_dims(observation, axis=0)
    
#         probs,pa,li = sess.run([probabilities,params,linear],feed_dict={state: obs_vector})
        

#         action = 0 if random.uniform(0,1) < probs[0][0] else 1
#         # record the transition
#         statesArray.append(observation)
#         actionblank = np.zeros(2)
#         actionblank[action] = 1
#         actionsArray.append(actionblank)
#         # take the action in the environment
#         observation, reward, done, info = env.step(action)
#         rewardArray.append(reward)
#         totalreward += reward
 
#         if done:
            
#             break

    

 
#     rewardArray_vector = np.expand_dims(rewardArray, axis=1)    
#     ls = sess.run([optimizer,loss], feed_dict={state: statesArray, advantages: rewardArray_vector, actions: actionsArray})
#     print("Episode finished after {} timesteps".format(totalreward))

#     return totalreward

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=8080 , debug=True)

