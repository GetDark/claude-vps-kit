[English](#english) | [Русский](#русский)

---

<a name="english"></a>
# claude-vps-kit

One-command setup for a complete Claude Code environment on a VPS. Installs system dependencies, MCP servers, plugins, and config files — ready to use with the Claude Code VSCode extension.

## What's included

**System packages:** Node.js 20 LTS, Python 3, git, nginx, certbot, Docker, PostgreSQL client, Redis client, UFW, fail2ban, uv

**MCP Servers:**

| Server | Purpose |
|--------|---------|
| playwright | Browser automation |
| context7 | Library documentation |
| postgres | PostgreSQL queries |
| docker | Docker management |
| filesystem | File system access |
| sequential-thinking | Structured reasoning |
| github | GitHub API |
| redis | Redis access |
| duckduckgo | Web search |
| memory | Persistent memory |
| fetch | HTTP requests |
| extract-design-system | Design system extraction |

**Plugin:** `get-design-done` (96 design skills)

**Config files:** `settings.json`, `models.json`, `CLAUDE.template.md`

## Quick Start

```bash
git clone https://github.com/GetDark/claude-vps-kit.git
cd claude-vps-kit
bash install.sh
```

> **Requirements:** Ubuntu/Debian, Claude Code VSCode extension installed

## After Install

1. Restart VSCode / Claude Code
2. Copy `CLAUDE.template.md` to your project as `CLAUDE.md`
3. Set environment variables (`GITHUB_TOKEN`, `POSTGRES_URL`, etc.)
4. Optionally add `FIGMA_API_KEY` for Figma MCP

---

<a name="русский"></a>
# claude-vps-kit

Одна команда — полное окружение Claude Code на VPS. Устанавливает системные зависимости, MCP-серверы, плагины и конфиги — готово к работе с расширением Claude Code для VSCode.

## Что включено

**Системные пакеты:** Node.js 20 LTS, Python 3, git, nginx, certbot, Docker, psql-клиент, redis-cli, UFW, fail2ban, uv

**MCP-серверы:**

| Сервер | Назначение |
|--------|-----------|
| playwright | Автоматизация браузера |
| context7 | Документация библиотек |
| postgres | Запросы к PostgreSQL |
| docker | Управление Docker |
| filesystem | Доступ к файловой системе |
| sequential-thinking | Структурированные рассуждения |
| github | GitHub API |
| redis | Доступ к Redis |
| duckduckgo | Веб-поиск |
| memory | Постоянная память |
| fetch | HTTP-запросы |
| extract-design-system | Извлечение дизайн-системы |

**Плагин:** `get-design-done` (96 дизайн-навыков)

**Конфиги:** `settings.json`, `models.json`, `CLAUDE.template.md`

## Быстрый старт

```bash
git clone https://github.com/GetDark/claude-vps-kit.git
cd claude-vps-kit
bash install.sh
```

> **Требования:** Ubuntu/Debian, установленное расширение Claude Code для VSCode

## После установки

1. Перезапустить VSCode / Claude Code
2. Скопировать `CLAUDE.template.md` в проект как `CLAUDE.md`
3. Задать переменные окружения (`GITHUB_TOKEN`, `POSTGRES_URL` и т.д.)
4. Опционально — добавить `FIGMA_API_KEY` для Figma MCP
