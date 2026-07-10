from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return "<h1>Python (Flask) App</h1><p>Served via Gunicorn behind Apache</p>"


@app.route("/health")
def health():
    return {"status": "ok", "stack": "python"}
