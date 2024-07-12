from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Adria Gateway Service DEV ENV   v2"