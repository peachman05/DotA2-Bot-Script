from flask import Flask, redirect, url_for, request, jsonify
import logging
from logging.handlers import RotatingFileHandler
import sys

#### CSV
import csv
import pandas as pd
import numpy as np

PREDICT_STATE = 0
UPDATE_STATE = 0


app = Flask(__name__)

@app.route('/',methods = ['POST', 'GET'])
def getValue():
	
   data = request.json
   print(data)
   # if data['state'] == PREDICT_STATE :
   #    return predictNextState(data['observation']);
   # elif data['state'] == UPDATE_STATE:
      
      # sess.run([optimizer,loss], feed_dict={state: data['statesArray'], advantages: rewardArray_vector, actions: actionsArray})
      # return "ok"



   # df = pd.DataFrame()

   # df = df.append(data,ignore_index=True)

   # with open('my_csv.csv', 'a') as f:
   #     df.to_csv(f, header=False, sep=',', encoding='utf-8',index=False)

   return "1";

# def policy_gradient():
#     with tf.variable_scope("policy"):
#         params = tf.get_variable("policy_parameters",[6,3]) ## 6 input
#         state = tf.placeholder("float",[None,6]) ## 6 input
#         actions = tf.placeholder("float",[None,3]) ## 3 action
#         advantages = tf.placeholder("float",[None,1]) ## reward
#         linear = tf.matmul(state,params)
#         probabilities = tf.nn.softmax(linear)
#         mulProb = tf.multiply(probabilities, actions)
#         good_probabilities = tf.reduce_sum(mulProb,reduction_indices=[1])
#         eligibility = tf.log(good_probabilities) * advantages
#         loss = -tf.reduce_sum(eligibility)
#         optimizer = tf.train.AdamOptimizer(0.01).minimize(loss)
#         return probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss , good_probabilities

# def predictNextState(obs_vector,policy_grad):

#     probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss,good_probabilities = policy_grad

#     probs,pa,li = sess.run([probabilities,params,linear],feed_dict={state: obs_vector})


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

