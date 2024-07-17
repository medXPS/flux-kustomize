from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "sync test ON AKS With fluxCD & Kustomize v2"