#!/usr/bin/env bash
# Автоматическая проверка итогового решения. Запуск из корня проекта: ./scripts/smoke_test.sh
set -euo pipefail
PORT="${SERVER_HOST_PORT:-1234}"
ok()   { echo "  [OK]   $*"; }
fail() { echo "  [FAIL] $*"; exit 1; }

echo "1) Конфигурация compose валидна"
docker compose config -q || fail "docker compose config"; ok "docker compose config"

echo "2) Сборка и запуск redis+server с ожиданием healthy"
docker compose build -q && docker compose up -d --wait redis server || fail "сервисы не стали healthy (docker compose ps; docker compose logs server)"; ok "server и redis healthy"

echo "3) Статика и счётчик с хоста"
curl -fsS "http://localhost:${PORT}/" | grep -q "hello world" || fail "GET / не отдаёт index.html"; ok "GET / отдаёт index.html"
v1=$(curl -fsS "http://localhost:${PORT}/api/visits" | python3 -c 'import sys,json;print(json.load(sys.stdin)["visits"])')
v2=$(curl -fsS "http://localhost:${PORT}/api/visits" | python3 -c 'import sys,json;print(json.load(sys.stdin)["visits"])')
[ "$v2" -eq $((v1+1)) ] && ok "счётчик растёт: $v1 -> $v2" || fail "счётчик не растёт"

echo "4) Клиент по DNS-имени сервиса"
docker compose run --rm client > /tmp/client.out; cat /tmp/client.out
grep -q "visits=" /tmp/client.out || fail "клиент не получил счётчик"; ok "клиент получил счётчик"

echo "5) Персистентность: down (без -v) + up"
docker compose down
docker compose up -d --wait redis server
v3=$(curl -fsS "http://localhost:${PORT}/api/visits" | python3 -c 'import sys,json;print(json.load(sys.stdin)["visits"])')
[ "$v3" -gt "$v2" ] && ok "после перезапуска visits=$v3 > $v2" || fail "данные потерялись"

echo "6) Non-root"
u=$(docker compose exec -T server id -u)
[ "$u" != "0" ] && ok "server работает под uid=$u" || fail "server работает под root"

echo "7) Graceful stop (< 5 c)"
start=$(date +%s); docker compose stop server >/dev/null 2>&1; end=$(date +%s)
[ $((end-start)) -lt 5 ] && ok "server остановлен за $((end-start)) c" || fail "остановка заняла $((end-start)) c"

echo "8) Размеры образов"
docker image ls --format '{{.Repository}}:{{.Tag}}\t{{.Size}}' | grep mipt-practice || echo '  (образы mipt-practice/* не найдены — задайте image: в compose)'

docker compose down
echo "Все проверки пройдены."
