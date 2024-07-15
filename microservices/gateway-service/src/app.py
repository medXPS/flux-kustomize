from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "switch to adria's project"