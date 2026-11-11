# Docker practice — стартовый набор

Курс «Разработка ПО и облачные вычисления», МФТИ. Преподаватель: Бакуркин К.С.

Здесь лежит исходный пример (server + client + docker-compose.yml) **без изменений** —
в нём специально оставлены проблемы, которые вы будете находить и исправлять по заданию
(задания шагов 0–7 преподаватель выдаёт по ходу онлайн-занятия в чате).

```
server/              Dockerfile, server.py, index.html   — HTTP-сервер на порту 1234
client/              Dockerfile, client.py               — клиент, печатает ответ сервера
docker-compose.yml   исходный compose-файл
templates/server_v2.py  шаблон сервера с Redis для шага 5 (с TODO)
scripts/smoke_test.sh   самопроверка ИТОГОВОГО состояния (после шагов 5–6)
REPORT.md            шаблон отчёта — заполняйте по ходу работы
```

Начало работы:

```bash
git init && git add . && git commit -m "step-0: starter"
docker compose up --build
```

После каждого шага: `git commit -am "step-N: ..."`.
Windows: запускайте команды в WSL2 или Git Bash; проследите, чтобы `scripts/smoke_test.sh`
имел окончания строк LF (`git config core.autocrlf input`).
