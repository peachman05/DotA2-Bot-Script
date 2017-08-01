

from flask import Flask, redirect, url_for, request
import psycopg2
import logging
from logging.handlers import RotatingFileHandler
import sys

app = Flask(__name__)

@app.route('/success/<name>')
def success(name):
    try:
        #conn = psycopg2.connect("dbname=test2")
        conn = psycopg2.connect("dbname=test2 user=postgres password=1234")
        c = conn.cursor()
    
        query = "SELECT * FROM person ;"
        c.execute(query)
        value = c.fetchall()
        #conn.close()
        return conn, c
        #return "Success %s" % value
    except:
        print("Can't Connect to database")
        return "Fail"
   # return 'welcomed %s' % name

@app.route('/login',methods = ['POST', 'GET'])
def login():
   # if request.method == 'POST':
   #    user = request.form['nm']
   #    return redirect(url_for('success',name = user))
   # else:
   #    user = request.args.get('nm')
   #    return redirect(url_for('success',name = user))
   return "ddddd"

if __name__ == '__main__':
   app.run(debug = True)
