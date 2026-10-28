"""Demo-App für den Vortrag: zeigt Hostname und Version groß an, damit Pod-Wechsel
und Rolling Updates am Projektor sichtbar werden."""

import os
import socket

from flask import Flask, jsonify

# Werden beim Build im Dockerfile gesetzt.
VERSION = os.environ.get("APP_VERSION", "dev")
BROKEN = os.environ.get("APP_BROKEN", "false") == "true"

HOSTNAME = socket.gethostname()

app = Flask(__name__)


@app.get("/")
def index():
    # Die Seite fragt laufend /info ab, jede Anfrage kann bei einem anderen Pod landen.
    return app.send_static_file("index.html")


@app.get("/info")
def info():
    response = jsonify(hostname=HOSTNAME, version=VERSION)
    response.headers["Cache-Control"] = "no-store"
    return response


@app.get("/healthz")
def healthz():
    return "", 200


@app.get("/readyz")
def readyz():
    # Die kaputte Version wird nie bereit, der Rollout bleibt dadurch stehen.
    if BROKEN:
        return "", 503
    return "", 200
