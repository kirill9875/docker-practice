#!/usr/bin/env python3
"""Шаблон сервера для шага 5 (Redis-счётчик). Скопируйте в server/server.py и заполните TODO.

Контракт (его проверяет scripts/smoke_test.sh):
  GET /            -> static/index.html
  GET /health      -> 200 {"status": "ok"}, если Redis отвечает на PING, иначе 503
  GET /api/visits  -> 200 {"visits": <int>, "hostname": <str>}, счётчик увеличивается на 1 (INCR)
Вся конфигурация — через переменные окружения.
"""
import json
import os
import socket
import time
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

import redis  # TODO: не забудьте requirements.txt и pip install в Dockerfile

PORT = int(os.getenv("PORT", "1234"))
STATIC_DIR = os.getenv("STATIC_DIR", "static")
REDIS_HOST = os.getenv("REDIS_HOST", "redis")   # почему не localhost?
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
STARTUP_DELAY = float(os.getenv("STARTUP_DELAY", "0"))

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, socket_connect_timeout=2, decode_responses=True)


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=STATIC_DIR, **kwargs)

    def _json(self, code, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            # TODO: r.ping(); при redis.RedisError вернуть 503
            return self._json(501, {"status": "TODO"})
        if self.path == "/api/visits":
            # TODO: visits = r.incr("visits"); вернуть {"visits": visits, "hostname": socket.gethostname()}
            return self._json(501, {"error": "TODO"})
        return super().do_GET()


def main():
    if STARTUP_DELAY > 0:
        time.sleep(STARTUP_DELAY)
    httpd = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    # TODO (шаг 6): обработать SIGTERM, чтобы `docker compose stop` не ждал 10 секунд
    print(f"listening on {PORT}", flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
