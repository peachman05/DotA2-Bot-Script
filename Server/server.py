

from flask import Flask, redirect, url_for, request, jsonify

import psycopg2
import logging
from logging.handlers import RotatingFileHandler
import sys

app = Flask(__name__)

@app.route('/',methods = ['POST','GET'])
def login():

   inputData = {}

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

   print(inputData)

   # if request.method == 'POST':
   #    user = request.form['nm']
   #    return redirect(url_for('success',name = user))
   # else:
   #    user = request.args.get('nm')
   #    return redirect(url_for('success',name = user))

   return "1";#jsonify({'num': 1234})

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=80 , debug=True)
