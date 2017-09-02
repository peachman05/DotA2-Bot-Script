from flask import Flask, redirect, url_for, request, jsonify
############  
import psycopg2
import logging
from logging.handlers import RotatingFileHandler
import sys

############ for csv
import csv
import pandas as pd
import numpy as np

app = Flask(__name__)

@app.route('/',methods = ['POST','GET'])
def login():

   inputData = dict()

   method = request.form['method']

   inputData['hp_me'] = request.form['hp_me']
   inputData['hp_enemy']  = request.form['hp_enemy']
   inputData['mp_me'] = request.form['mp_me']
   inputData['mp_enemy'] = request.form['mp_enemy']
   inputData['distance'] = request.form['distance']
   inputData['level_s1'] = request.form['level_s1']
   inputData['level_s2'] = request.form['level_s2']
   inputData['level_s3'] = request.form['level_s3']
   inputData['cd_s1'] = request.form['cd_s1']
   inputData['cd_s2'] = request.form['cd_s2']
   inputData['cd_s3'] = request.form['cd_s3']

   if(method == "predict"):

       print(predict);
   else:

      inputData['output'] = request.form['output']

      df = pd.DataFrame()
      df = df.append(inputData,ignore_index=True)

      with open('dataTrain.csv', 'a') as f:
          df.to_csv(f, header=False, sep=',', encoding='utf-8',index=False)


   print(inputData)



   return "1";

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=80 , debug=True)