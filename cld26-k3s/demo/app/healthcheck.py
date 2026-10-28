"""Healthcheck für docker compose, das Image bringt weder curl noch wget mit."""

import urllib.request

urllib.request.urlopen("http://127.0.0.1:8080/healthz", timeout=2)
