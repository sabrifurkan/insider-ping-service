import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/ping")
def ping():
    """Smoke-test endpoint. Cheap, no dependencies, returns plain text 'pong'."""
    return "pong", 200


@app.get("/healthz")
def healthz():
    """Health endpoint for Kubernetes probes.

    Returns JSON so we can extend it later (e.g. checking a DB) without
    breaking callers that only look at the HTTP status code.
    """
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    # This block runs ONLY for local development (`python app.py`).
    # Inside the container we run gunicorn instead (see Dockerfile) because
    # Flask's built-in server is single-threaded and not meant for production.
    port = int(os.environ.get("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
