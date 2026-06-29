#!/bin/bash
# ============================================================
# Claude Code — Автоустановщик окружения
# Запуск: bash install.sh
# Требования: Ubuntu/Debian, Claude Code (VSCode extension)
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "══════════════════════════════════════════"
echo "  Claude Code Environment Installer"
echo "══════════════════════════════════════════"
echo ""

# --- 1. Node.js 20 LTS ---
NODE_VERSION=20
if command -v node >/dev/null 2>&1 && node -e "process.exit(parseInt(process.version.slice(1)) >= 18 ? 0 : 1)" 2>/dev/null; then
    log "Node.js $(node -v) найден"
else
    warn "Устанавливаю Node.js $NODE_VERSION LTS..."
    if command -v apt-get >/dev/null 2>&1; then
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - >/dev/null 2>&1
        apt-get install -y nodejs >/dev/null 2>&1
    elif command -v yum >/dev/null 2>&1; then
        curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash - >/dev/null 2>&1
        yum install -y nodejs >/dev/null 2>&1
    else
        fail "Пакетный менеджер не найден. Установи Node.js вручную: https://nodejs.org"
    fi
    log "Node.js $(node -v) установлен"
fi
command -v npx >/dev/null 2>&1 || fail "npx не найден после установки Node.js"

# --- 2. Системные пакеты ---
echo ""
warn "Устанавливаю системные пакеты..."

apt-get update -qq 2>/dev/null

# git
if command -v git >/dev/null 2>&1; then
    log "git $(git --version | awk '{print $3}') найден"
else
    apt-get install -y git >/dev/null 2>&1 && log "git установлен" || warn "git: ошибка установки"
fi

# Python 3 + pip
if command -v python3 >/dev/null 2>&1; then
    log "Python $(python3 --version | awk '{print $2}') найден"
else
    apt-get install -y python3 python3-pip >/dev/null 2>&1 && log "Python3 установлен" || warn "Python3: ошибка установки"
fi
command -v pip3 >/dev/null 2>&1 || apt-get install -y python3-pip >/dev/null 2>&1

# nginx
if command -v nginx >/dev/null 2>&1; then
    log "nginx найден"
else
    apt-get install -y nginx >/dev/null 2>&1 && log "nginx установлен" || warn "nginx: ошибка установки"
fi

# certbot
if command -v certbot >/dev/null 2>&1; then
    log "certbot найден"
else
    apt-get install -y certbot python3-certbot-nginx >/dev/null 2>&1 && log "certbot установлен" || warn "certbot: ошибка установки"
fi

# PostgreSQL client
if command -v psql >/dev/null 2>&1; then
    log "psql найден"
else
    apt-get install -y postgresql-client >/dev/null 2>&1 && log "psql установлен" || warn "psql: ошибка установки"
fi

# Redis client
if command -v redis-cli >/dev/null 2>&1; then
    log "redis-cli найден"
else
    apt-get install -y redis-tools >/dev/null 2>&1 && log "redis-cli установлен" || warn "redis-cli: ошибка установки"
fi

# ufw
if command -v ufw >/dev/null 2>&1; then
    log "ufw найден"
else
    apt-get install -y ufw >/dev/null 2>&1 && log "ufw установлен" || warn "ufw: ошибка установки"
fi

# fail2ban
if command -v fail2ban-client >/dev/null 2>&1; then
    log "fail2ban найден"
else
    apt-get install -y fail2ban >/dev/null 2>&1 && log "fail2ban установлен" || warn "fail2ban: ошибка установки"
fi

# Docker
if command -v docker >/dev/null 2>&1; then
    log "Docker $(docker --version | awk '{print $3}' | tr -d ',') найден"
else
    warn "Устанавливаю Docker..."
    curl -fsSL https://get.docker.com | sh >/dev/null 2>&1 && log "Docker установлен" || warn "Docker: ошибка установки"
fi

# docker-compose (v2 plugin)
if docker compose version >/dev/null 2>&1; then
    log "docker compose v2 найден"
elif command -v docker-compose >/dev/null 2>&1; then
    log "docker-compose найден"
else
    apt-get install -y docker-compose-plugin >/dev/null 2>&1 \
        && ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose 2>/dev/null \
        && log "docker-compose установлен" || warn "docker-compose: ошибка установки"
fi

# --- 3. uv (Python package manager для MCP серверов) ---
if ! command -v uvx >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/uvx" ]; then
    warn "Устанавливаю uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.local/bin/env" 2>/dev/null || true
    log "uv установлен"
else
    log "uv уже установлен"
fi

UVX=$(command -v uvx 2>/dev/null || echo "$HOME/.local/bin/uvx")

# --- 4. Найти бинарник Claude Code ---
CLAUDE=$(find "$HOME/.vscode-server/extensions" -name "claude" -type f 2>/dev/null | sort -V | tail -1)
if [ -z "$CLAUDE" ]; then
    CLAUDE=$(command -v claude 2>/dev/null || "")
fi
if [ -z "$CLAUDE" ]; then
    fail "Бинарник Claude Code не найден. Убедись что VSCode + Claude Code extension установлены."
fi
log "Claude Code: $CLAUDE"

# --- 5. Создать ~/.claude если нет ---
mkdir -p "$HOME/.claude"

# --- 6. Скопировать конфиги ---
log "Копирую settings.json..."
cp settings.json "$HOME/.claude/settings.json"

log "Копирую models.json..."
cp models.json "$HOME/.claude/models.json"

# --- 7. Установить плагины ---
echo ""
warn "Устанавливаю плагины..."

# get-design-done (устанавливается через npx, сам прописывается в settings.json)
log "get-design-done (96 design skills)..."
npx -y @hegemonart/get-design-done@latest 2>/dev/null || warn "get-design-done: возможна ошибка, проверь вручную"

# --- 8. Установить MCP серверы ---
echo ""
warn "Устанавливаю MCP серверы..."

$CLAUDE mcp add playwright    -- npx @playwright/mcp@latest                                    2>/dev/null && log "playwright MCP"      || warn "playwright: уже существует или ошибка"
$CLAUDE mcp add context7      -- npx -y @upstash/context7-mcp@latest                           2>/dev/null && log "context7 MCP"        || warn "context7: уже существует или ошибка"
$CLAUDE mcp add postgres      -- npx -y @modelcontextprotocol/server-postgres postgresql://localhost/postgres 2>/dev/null && log "postgres MCP" || warn "postgres: уже существует или ошибка"
$CLAUDE mcp add docker        -- npx -y docker-mcp                                             2>/dev/null && log "docker MCP"          || warn "docker: уже существует или ошибка"
$CLAUDE mcp add filesystem    -- npx -y @modelcontextprotocol/server-filesystem /root/projects 2>/dev/null && log "filesystem MCP"      || warn "filesystem: уже существует или ошибка"
$CLAUDE mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking 2>/dev/null && log "sequential-thinking" || warn "sequential-thinking: уже существует или ошибка"
$CLAUDE mcp add github        -- npx -y @modelcontextprotocol/server-github                    2>/dev/null && log "github MCP"          || warn "github: уже существует или ошибка"
$CLAUDE mcp add redis         -- npx -y @modelcontextprotocol/server-redis redis://localhost:6379 2>/dev/null && log "redis MCP"         || warn "redis: уже существует или ошибка"
$CLAUDE mcp add duckduckgo    -- npx -y mcp-duckduckgo                                         2>/dev/null && log "duckduckgo MCP"      || warn "duckduckgo: уже существует или ошибка"
$CLAUDE mcp add memory        -- npx -y @modelcontextprotocol/server-memory                    2>/dev/null && log "memory MCP"          || warn "memory: уже существует или ошибка"
$CLAUDE mcp add fetch         -- "$UVX" mcp-server-fetch                                       2>/dev/null && log "fetch MCP"           || warn "fetch: уже существует или ошибка"
$CLAUDE mcp add extract-design-system -- npx -y extract-design-system-mcp                     2>/dev/null && log "extract-design-system MCP" || warn "extract-design-system: уже существует или ошибка"

# --- 9. Figma MCP (опционально, требует API ключ) ---
echo ""
warn "Figma MCP — опционально (требует FIGMA_API_KEY):"
echo "  Если нужен Figma:"
echo "  export FIGMA_API_KEY=your_key"
echo "  npx -y figma-developer-mcp --stdio"
echo "  Добавь в Claude Code: Settings → MCP → Add"

# --- 10. Создать CLAUDE.md в рабочей директории ---
if [ ! -f "$(pwd)/CLAUDE.md" ] && [ -f "CLAUDE.template.md" ]; then
    cp CLAUDE.template.md "$(pwd)/CLAUDE.md"
    log "CLAUDE.md создан в $(pwd)"
fi

# --- Готово ---
echo ""
echo "══════════════════════════════════════════"
log "Установка завершена!"
echo ""
echo "  Следующие шаги:"
echo "  1. Перезапусти VSCode / Claude Code"
echo "  2. Скопируй CLAUDE.template.md в свой проект как CLAUDE.md"
echo "  3. Настрой .env переменные (GITHUB_TOKEN, POSTGRES_URL и т.д.)"
echo "  4. Если используешь Figma — добавь FIGMA_API_KEY"
echo "══════════════════════════════════════════"
echo ""
