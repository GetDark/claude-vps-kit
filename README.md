# claude-vps-kit

Разворачивает полное окружение Claude Code на новом VPS за один запуск.

## Что включено

| Файл | Назначение |
|------|-----------|
| `install.sh` | Автоустановщик: MCP серверы, плагины, конфиги |
| `settings.json` | Разрешения, плагины, marketplace |
| `models.json` | Маршрутизация Haiku/Sonnet/Opus по задачам |
| `CLAUDE.template.md` | Шаблон CLAUDE.md для нового проекта |

## Требования

- VPS с Ubuntu/Debian
- Node.js 18+ (`node -v`)
- VSCode + Claude Code extension установлены и запущены хотя бы раз

## Быстрый старт

```bash
# 1. Клонировать репозиторий на сервер
ssh root@YOUR_VPS_IP
git clone git@github.com:GetDark/claude-vps-kit.git
cd claude-vps-kit
bash install.sh

# 3. Перезапустить VSCode/Claude Code

# 4. Скопировать шаблон в рабочую директорию
cp /root/claude-export/CLAUDE.template.md /root/projects/CLAUDE.md
# Отредактировать под свой проект (домены, порты, бот-токены)
```

## Что установится

### MCP серверы (12 штук)
| Сервер | Назначение |
|--------|-----------|
| `playwright` | Управление браузером, скриншоты, тестирование UI |
| `context7` | Актуальная документация библиотек и фреймворков |
| `postgres` | Прямые SQL-запросы к PostgreSQL |
| `docker` | Управление контейнерами без Bash |
| `filesystem` | Расширенные операции с файлами |
| `sequential-thinking` | Структурированное мышление для сложных задач |
| `github` | PR, issues, поиск по коду, push файлов |
| `redis` | Чтение/запись ключей Redis |
| `duckduckgo` | Поиск в интернете (бесплатно, без API ключа) |
| `memory` | Граф знаний для хранения дизайн-решений между сессиями |
| `fetch` | HTTP-запросы к любым URL (Python-based, uvx) |
| `extract-design-system` | Вытащить дизайн-токены с любого сайта |

### Плагины (4 штуки)
| Плагин | Назначение |
|--------|-----------|
| `superpowers` | Процессные skills: brainstorming, debugging, plans, TDD |
| `frontend-design` | UI/UX skills для фронтенда |
| `ui-ux-pro-max` | Дизайн-система, brand, banner skills |
| `get-design-done` | 96 design skills: /gdd:brief, /gdd:plan, /gdd:design, /gdd:audit, /gdd:verify |

### Маршрутизация моделей
- **Haiku** — поиск файлов, логи, документация, gate-проверки
- **Sonnet** — стандартная разработка (backend, frontend, конфиги)
- **Opus** — архитектура, дизайн (3 концепции), code review, сложный дебаг

## После установки: настройка

### 1. Настроить Postgres MCP (если нужен)
В `~/.claude.json` найти секцию `postgres` и поменять строку подключения:
```json
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://USER:PASS@localhost/DBNAME"]
}
```

### 2. Настроить GitHub MCP (если нужен)
```bash
export GITHUB_TOKEN=ghp_your_token_here
```
Или добавить в `~/.bashrc` / `~/.zshrc`.

### 3. Настроить Figma MCP (опционально)
```bash
export FIGMA_API_KEY=your_figma_key
# Затем добавить через Claude Code: Settings → MCP → Add
```

### 4. Создать CLAUDE.md для своего проекта
```bash
cp CLAUDE.template.md /root/projects/CLAUDE.md
```
Заменить в файле:
- `YOURDOMAIN.COM` → свой домен
- `YOUR_VPS_IP` → IP сервера
- `YOUR_EMAIL` → email для certbot
- `YOUR_BOT_TOKEN` → токен Telegram бота (если используется)
- Добавить свои порты/домены в таблицу

## Структура рекомендуемых проектов

```
/root/projects/
├── CLAUDE.md               ← Копия из CLAUDE.template.md (заполненная)
├── MASTER_PLAN.md          ← Карта всех проектов
├── _shared/                ← Shared PostgreSQL + Redis
│   └── docker-compose.yml
├── _docs/
│   ├── PROJECT_INDEX.md
│   └── GOTCHAS.md
├── 01-project-one/
│   ├── SPEC.md
│   ├── PROJECT_STATUS.md
│   ├── docker-compose.yml
│   ├── frontend/
│   └── backend/
└── ...
```

## Диагностика

```bash
# Проверить установленные MCP
claude mcp list

# Проверить Claude binary
find ~/.vscode-server/extensions -name "claude" -type f 2>/dev/null | tail -1

# Проверить uv/uvx
uvx --version

# Проверить Node.js
node -v && npm -v
```

## Обновление

Чтобы обновить только MCP серверы без переустановки плагинов:
```bash
# Удалить старый и добавить новый
claude mcp remove <name>
claude mcp add <name> -- npx -y @package/name@latest
```

## Известные особенности

- **fetch MCP** использует Python (`uvx mcp-server-fetch`) — JS-версия не существует
- **get-design-done** создаёт `~/.claude/models.json` — не удалять, это маршрутизация моделей
- **settings.json** защищён gdd-хуком — изменять только через `python3 -c "import json; ..."`
- **bcrypt**: всегда использовать `bcrypt==3.2.2` + `passlib[bcrypt]==1.7.4` (не обновлять!)
- **Docker hostname**: в docker-compose сервисы обращаются друг к другу по имени сервиса, не `localhost`
- **environment vs env_file**: `environment:` перекрывает `env_file:` — использовать только `env_file: .env`
