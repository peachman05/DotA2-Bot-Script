

from flask import Flask, redirect, url_for, request
import psycopg2
import logging
from logging.handlers import RotatingFileHandler
import sys

app = Flask(__name__)

@app.route('/',methods = ['POST','GET'])
def login():

   # if request.method == 'POST':
   #    user = request.form['nm']
   #    return redirect(url_for('success',name = user))
   # else:
   #    user = request.args.get('nm')
   #    return redirect(url_for('success',name = user))

   return "2"

if __name__ == '__main__':
   app.run(debug = True)
