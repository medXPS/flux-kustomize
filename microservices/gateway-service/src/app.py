from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from ADRIA v1.0.0.0"