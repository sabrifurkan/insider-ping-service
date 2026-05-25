"""Tests for the ping service.

These are intentionally tiny: the service is tiny. Their job is to give the CI
pipeline something real to run and to catch regressions in the two endpoints.
We use Flask's built-in test client, so no server/network is needed.
"""

from app import app


def test_ping_returns_pong():
    client = app.test_client()
    resp = client.get("/ping")
    assert resp.status_code == 200
    assert resp.data == b"pong"


def test_healthz_returns_ok():
    client = app.test_client()
    resp = client.get("/healthz")
    assert resp.status_code == 200
    assert resp.get_json() == {"status": "ok"}
