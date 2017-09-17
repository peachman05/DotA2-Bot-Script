import tensorflow as tf
import numpy as np
import random
import gym
import math
import matplotlib.pyplot as plt
import copy


probGlo = None

def softmax(x):
    e_x = np.exp(x - np.max(x))
    out = e_x / e_x.sum()
    return out


def policy_gradient():
    with tf.variable_scope("policy"):
        params = tf.get_variable("policy_parameters",[4,2])
        state = tf.placeholder("float",[None,4])
        actions = tf.placeholder("float",[None,2])
        advantages = tf.placeholder("float",[None,1])
        linear = tf.matmul(state,params)
        probabilities = tf.nn.softmax(linear)
        mulProb = tf.multiply(probabilities, actions)
        good_probabilities = tf.reduce_sum(mulProb,reduction_indices=[1])
        eligibility = tf.log(good_probabilities) * advantages
        loss = -tf.reduce_sum(eligibility)
        optimizer = tf.train.AdamOptimizer(0.01).minimize(loss)
        return probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss , good_probabilities


def run_episode(env, policy_grad, sess):
    probabilities, state, actions, advantages, optimizer , params , linear , mulProb,loss,good_probabilities = policy_grad
    
    observation = env.reset()
    totalreward = 0
    statesArray = []
    actionsArray = []
 
    rewardArray = []
    pa = None

    global probGlo

    for t in range(200):
        # env.render()
        # calculate policy
        obs_vector = np.expand_dims(observation, axis=0)
        # print(obs_vector)
        # probs = sess.run(pl_calculated,feed_dict={pl_state: obs_vector})
        probs,pa,li = sess.run([probabilities,params,linear],feed_dict={state: obs_vector})
        
        probGlo = pa
        # print(observation)
        # print(probs)
        # print(li)
        # print(mP)

        action = 0 if random.uniform(0,1) < probs[0][0] else 1
        # action = 0 if probs[0][0] > probs[0][1] else 1
        # record the transition
        statesArray.append(observation.tolist())
        actionblank = np.zeros(2)
        actionblank[action] = 1
        actionsArray.append(actionblank)
        # take the action in the environment
        observation, reward, done, info = env.step(action)
        rewardArray.append(reward)
        totalreward += reward

        # mP = sess.run([pl_mulProb],feed_dict={pl_state: obs_vector, pl_actions: actions})
        # rewardArray_vector = np.expand_dims(rewardArray, axis=1)    
        # op,ls,gp,mP,at = sess.run([optimizer,loss,good_probabilities,mulProb,actions], feed_dict={state: statesArray, advantages: rewardArray_vector, actions: actionsArray}) 
        # print("ls :"+str(ls))
        # print("prob :"+str(probs))
        # print("at"+str(at))
        # print("mP :"+str(mP))
        # print("gp: "+str(gp))

        # print("---------------")
        if done:
            
            break

    

    # advantages_vector = np.expand_dims(advantages, axis=1)
    rewardArray_vector = np.expand_dims(rewardArray, axis=1)    
    # print(type(statesArray[0]))
    # print(statesArray)
    # print(type(rewardArray_vector))
    # print(type(actionsArray))
    ls = sess.run([optimizer,loss], feed_dict={state: statesArray, advantages: rewardArray_vector, actions: actionsArray})
    print("Episode finished after {} timesteps".format(totalreward))
    # print("Episode finished after {} timesteps".format(totalreward))
    # print(ls)
    return totalreward


env = gym.make('CartPole-v0')
# env.monitor.start('cartpole-hill/', force=True)
policy_grad = policy_gradient()
sess = tf.InteractiveSession()
sess.run(tf.initialize_all_variables())
for i in range(2000):
    reward = run_episode(env, policy_grad, sess)
    # print(probGlo)
    #print("reward :"+str(reward))
    if reward == 200:
        print("reward 200")
        print(i)
        break
t = 0
for _ in range(1000):
    reward = run_episode(env, policy_grad, sess)
    print(probGlo)
    t += reward
print(t / 1000)

writer = tf.summary.FileWriter('/tmp/tensorflow_logs/example', graph=sess.graph)
print("Run the command line:\n" \
          "--> tensorboard --logdir=/tmp/tensorflow_logs " \
          "\nThen open http://0.0.0.0:6006/ into your web browser")
# env.monitor.close()