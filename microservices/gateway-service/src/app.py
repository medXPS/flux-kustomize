from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return " Hello from adria : using image update automation : v 3.5.0-32"
