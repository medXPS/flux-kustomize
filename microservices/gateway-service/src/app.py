from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return " Hello from Adria : this is Tag 3.5.0-55"
