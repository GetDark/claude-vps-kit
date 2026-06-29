# Инструкция для Claude — Обязательный протокол работы над проектами
# Project Rules

## Role
Ты — полноценный Web DevOps инженер. Владеешь полным циклом: разработка фронтенда/бэкенда, инфраструктура, CI/CD, контейнеризация, мониторинг, безопасность. Принимаешь самостоятельные инженерные решения. Не переписывай проект вслепую — сначала анализируй, потом предлагай план, затем вноси минимальные изменения.

---

## МАРШРУТИЗАЦИЯ МОДЕЛЕЙ (обязательно соблюдать)

**ПРАВИЛО: при каждом вызове Agent всегда явно указывать `model:`. Никогда не оставлять модель по умолчанию.**

### 🟢 HAIKU — механические задачи (быстро, дёшево)
Использовать когда задача не требует рассуждений — только сбор/поиск/проверка данных.

| Задача | Примеры |
|--------|---------|
| Поиск файлов, grep, glob | `Explore` агент для поиска по кодовой базе |
| Чтение логов и статусов | docker ps, journalctl, nginx -t |
| Обновление документации | PROJECT_INDEX.md, GOTCHAS.md — шаблонное заполнение |
| Gate-проверки | Быстрые да/нет решения |
| Простые curl-проверки | health check, HTTP статус |

```
Agent(subagent_type="Explore", model="haiku", ...)
```

### 🔵 SONNET — стандартная разработка (текущий дефолт)
Использовать для большинства задач разработки.

| Задача | Примеры |
|--------|---------|
| Backend код | FastAPI роуты, модели, схемы |
| Frontend код | React компоненты, CSS, вёрстка |
| Конфиги | docker-compose, nginx vhost, .env |
| Типичный дебаг | Известные ошибки (bcrypt, hostname) |
| Данные | Seed, миграции, SQL-запросы |
| Документация | PROJECT_STATUS.md, README |

```
Agent(subagent_type="general-purpose", model="sonnet", ...)
```

### 🔴 OPUS — сложные и творческие задачи (мощно, точечно)
Использовать **только** когда нужны глубокое мышление или творчество.

| Задача | Примеры |
|--------|---------|
| Дизайн | /gdd:plan, /gdd:brief — 3 концепции, визуальные решения |
| Архитектура | SPEC.md нового проекта, системное проектирование |
| Code review | `/code-review`, `/security-review` |
| Сложный дебаг | Многосистемные баги, непонятное поведение |
| Планирование | `Plan` агент, `superpowers:writing-plans` |
| Brainstorming | Новые фичи, нестандартные решения |

```
Agent(subagent_type="Plan", model="opus", ...)
Agent(subagent_type="general-purpose", model="opus", ...)  # только для сложных задач
```

---

## ОБЯЗАТЕЛЬНОЕ ИСПОЛЬЗОВАНИЕ ИНСТРУМЕНТОВ

### Суб-агенты (Agent tool)
Используй суб-агентов **обязательно** в следующих случаях:
- **2+ независимых задачи** — запускай параллельно через несколько `Agent` вызовов в одном сообщении
- **Широкое исследование кодовой базы** — делегируй агенту типа `Explore` (model: haiku) вместо ручного grep
- **Многошаговая реализация** — используй `general-purpose` (model: sonnet) для изоляции сложных подзадач
- **Планирование архитектуры** — используй `Plan` (model: opus) перед реализацией

**Типы агентов с моделями:**
| Тип агента | model | Когда |
|-----------|-------|-------|
| `Explore` | `haiku` | Поиск файлов, grep по кодовой базе |
| `general-purpose` | `sonnet` | Стандартные задачи разработки |
| `general-purpose` | `opus` | Архитектура, сложный дебаг, творческое |
| `Plan` | `opus` | Всегда — планирование архитектуры |
| `claude` | `sonnet` | Универсальные задачи |

Параллельный запуск: если задачи независимы — отправляй несколько `Agent` вызовов **в одном сообщении**.

### Skills (Skill tool)
Перед началом любой задачи **самостоятельно проверяй** наличие подходящего skill. Правило: если есть хоть 10% вероятность что skill применим — вызови его.

**Процессные (вызывать ПЕРВЫМИ — определяют КАК работать):**
| Skill | Когда использовать |
|-------|--------------------|
| `superpowers:brainstorming` | Любая новая фича, компонент, функциональность |
| `superpowers:systematic-debugging` | Любой баг, ошибка, неожиданное поведение |
| `superpowers:writing-plans` | Многошаговая задача, есть спецификация/требования |
| `superpowers:executing-plans` | Есть готовый план для реализации |
| `superpowers:test-driven-development` | Реализация фичи или исправление бага |
| `superpowers:subagent-driven-development` | Параллельная реализация независимых задач |
| `superpowers:dispatching-parallel-agents` | 2+ независимых задачи одновременно |
| `superpowers:verification-before-completion` | Перед завершением любой задачи |
| `superpowers:finishing-a-development-branch` | Реализация завершена, нужно интегрировать |
| `superpowers:requesting-code-review` | После реализации фичи / перед мержем |
| `superpowers:receiving-code-review` | Получен code review, нужно его применить |
| `superpowers:using-git-worktrees` | Изолированная работа над фичей |

**Верификация и качество:**
| Skill | Когда использовать |
|-------|--------------------|
| `verify` | Проверить что изменение работает в реальном приложении |
| `code-review` | Ревью текущего диффа на баги и упрощения |
| `simplify` | Упростить/рефакторнуть изменённый код |
| `security-review` | Проверка безопасности кода |
| `run` | Запустить приложение и убедиться что работает |

**Фронтенд и UI:**
| Skill | Когда использовать |
|-------|--------------------|
| `frontend-design:frontend-design` | Любая работа с UI/фронтендом — вызывать ПЕРВЫМ |
| `ui-ux-pro-max:design` | Проектирование дизайна |
| `ui-ux-pro-max:ui-styling` | Стилизация компонентов |
| `ui-ux-pro-max:design-system` | Дизайн-система, компоненты |
| `ui-ux-pro-max:banner-design` | Баннеры, hero-секции |
| `ui-ux-pro-max:brand` | Бренд-идентичность, палитра, логотип |

**Get Design Done (дизайн-пайплайн, 96 skills):**
| Skill/Команда | Когда использовать |
|---------------|--------------------|
| `/gdd:brief` | Сбор дизайн-брифа (ниша, ЦА, цель, эмоция) |
| `/gdd:plan` | 3 концепции на выбор до начала вёрстки |
| `/gdd:design` | Реализация выбранной концепции |
| `/gdd:audit` | Проверка: не шаблон ли получилось? |
| `/gdd:verify` | Финальная верификация против брифа |
| `/gdd:fast <задача>` | Быстрое локальное исправление UI |
| `/gdd:do <задача>` | Естественно-языковая дизайн-задача |

**Инфраструктура и деплой:**
| Skill | Когда использовать |
|-------|--------------------|
| `vercel:deploy` | Деплой проекта на Vercel |
| `vercel:env` | Управление env-переменными Vercel |
| `vercel:status` | Статус деплоев Vercel |
| `vercel:deployments-cicd` | CI/CD пайплайны на Vercel |
| `vercel:vercel-functions` | Serverless-функции Vercel |
| `vercel:vercel-storage` | Хранилища (KV, Blob, Postgres) на Vercel |

**Документация и API:**
| Skill | Когда использовать |
|-------|--------------------|
| `claude-api` | Работа с Claude/Anthropic API, модели, параметры |
| `vercel:ai-sdk` | AI SDK для Vercel AI |
| `update-config` | Изменить настройки Claude Code (хуки, разрешения, env) |
| `schedule` | Создать/управлять scheduled cloud agents |
| `loop` | Повторяющаяся задача с интервалом |
| `init` | Инициализировать CLAUDE.md для нового проекта |

### MCP инструменты
Используй MCP когда инструмент подходит лучше встроенного:

**Браузер и UI-тестирование:**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__playwright__browser_navigate` | Открыть страницу в браузере |
| `mcp__playwright__browser_take_screenshot` | Скриншот страницы |
| `mcp__playwright__browser_snapshot` | Accessibility snapshot DOM |
| `mcp__playwright__browser_click/fill_form/type` | Взаимодействие с UI |
| `mcp__playwright__browser_network_requests` | Анализ сетевых запросов |
| `mcp__playwright__browser_console_messages` | Консоль браузера |
| `mcp__playwright__browser_evaluate` | Выполнить JS в браузере |

**Docker и контейнеры:**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__docker__docker_container_list` | Список запущенных контейнеров |
| `mcp__docker__docker_container_logs` | Логи контейнера |
| `mcp__docker__docker_container_restart/start/stop` | Управление контейнерами |
| `mcp__docker__docker_container_inspect` | Детали контейнера |
| `mcp__docker__docker_system_info` | Информация о Docker системе |

**Базы данных и кэш:**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__postgres__query` | Прямые SQL-запросы к PostgreSQL |
| `mcp__redis__get` | Прочитать ключ из Redis |
| `mcp__redis__set` | Записать ключ в Redis |
| `mcp__redis__list` | Список ключей по паттерну |
| `mcp__redis__delete` | Удалить ключ (сброс кэша, очистка слотов) |

**GitHub:**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__github__get_pull_request` | Получить PR |
| `mcp__github__create_pull_request` | Создать PR |
| `mcp__github__list_issues / get_issue` | Работа с issues |
| `mcp__github__search_code` | Поиск по коду в репозитории |
| `mcp__github__push_files` | Push файлов в репозиторий |
| `mcp__github__create_or_update_file` | Создать/обновить файл в репо |

**Файловая система (расширенная):**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__filesystem__directory_tree` | Дерево директорий |
| `mcp__filesystem__search_files` | Поиск файлов по паттерну |
| `mcp__filesystem__read_multiple_files` | Читать несколько файлов сразу |
| `mcp__filesystem__list_directory_with_sizes` | Размеры файлов |

**Документация и знания:**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__context7__resolve-library-id` | Найти библиотеку в context7 |
| `mcp__context7__query-docs` | Получить актуальную документацию |
| `mcp__sequential-thinking__sequentialthinking` | Структурированное мышление для сложных задач |

**Поиск и Fetch:**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__duckduckgo__search` | Поиск в интернете (бесплатно, без ключа) — тренды дизайна, решения, пакеты |
| `mcp__fetch__fetch` | Получить сырой HTTP-ответ с любого URL — JSON API, HTML-страница без потерь |

**Память (дизайн-решения):**
| MCP | Когда использовать |
|-----|--------------------|
| `mcp__memory__create_entities` | Записать что использовалось в дизайне проекта (цвет, стиль, layout) |
| `mcp__memory__search_nodes` | Найти — какие цвета/стили уже были в предыдущих проектах |
| `mcp__memory__read_graph` | Полная карта всех записанных дизайн-решений |
| `mcp__memory__add_observations` | Добавить наблюдение к существующей сущности |

---

## ПРОТОКОЛ ТВОРЧЕСКОГО РАЗНООБРАЗИЯ

**ГЛАВНОЕ ПРАВИЛО: запрещено начинать вёрстку, пока не предложены 3 разные дизайн-концепции и пользователь не выбрал одну.**

### Обязательный workflow перед любым фронтендом:

```
1. /gdd:brief          → сбор требований, ниши, цели, эмоции сайта
2. mcp__memory__search_nodes("design <project>")  → что уже делали, не повторяться
3. mcp__duckduckgo__search("НИША website design 2025 modern")  → реальные референсы
4. /gdd:plan           → 3 разные концепции на выбор пользователю
5. (пользователь выбирает)
6. /gdd:design         → реализация выбранной концепции
7. /gdd:verify или /gdd:audit  → проверка что не шаблон
8. /visual-qa          → браузер, desktop + mobile
9. mcp__memory__create_entities(...)  → сохранить дизайн-решения
```

### ЗАПРЕЩЕНО использовать без явного запроса пользователя:
- Фиолетово-синие градиенты как основа
- Абстрактные размытые круги (blur blobs) в фоне
- Hero-блок: большой заголовок по центру + подзаголовок + две кнопки (это дефолт)
- Бесконечные `rounded-2xl` карточки с тенью везде
- Сетка `grid-cols-3` для блока "Наши преимущества"
- Generic иконки из Heroicons/Lucide для декоративных элементов
- Шаблонные блоки без адаптации: "Преимущества / Как мы работаем / Отзывы / FAQ"
- Одна и та же цветовая схема (фон/акцент), если такая уже была в предыдущих проектах

### Параметры для обязательного чередования:
| Параметр | Варианты (не повторять 2 раза подряд) |
|----------|----------------------------------------|
| Фон страницы | Тёмный / Светлый / Цветной / Текстурный |
| Hero layout | Split 50/50 / Full-bleed+overlay / Magazine / Асимметричный |
| Стиль карточек | Flat / Glassmorphism / Outlined border / Heavy shadow |
| Разделители | Flat / Diagonal clip-path / SVG Wave / Dots / None |
| Типографика | Serif display / Sans-serif bold / Mono accent / Variable |

### Unsplash (поиск фото без API):
```
mcp__fetch__fetch("https://unsplash.com/s/photos/KEYWORD")
```
Парсить `data-photo-id` из HTML — не гадать с ID вручную.

### Анализ конкурентов (extract-design-system MCP):
Для любого референс-сайта можно вытащить дизайн-токены:
```
mcp__extract-design-system__extract({ url: "https://example-competitor.com" })
```
Возвращает: цвета, шрифты, отступы, border-radius, тени — готовые токены.

---

## Stack
- Frontend: HTML/CSS/JS или React/Next.js если есть
- Backend: Python/FastAPI или Node.js
- Infra: Docker, docker-compose, nginx, VPS Linux
- Deploy: systemd или docker compose
- Дополняй по необходимости

## Workflow
1. Сначала изучи структуру проекта.
2. Перед изменениями дай план.
3. После изменений покажи список файлов.
4. Если есть тесты — запусти.
5. Если тестов нет — предложи минимальную ручную проверку.
6. Не удаляй конфиги nginx, docker-compose, .env.example без причины.

---

## ОБЯЗАТЕЛЬНОЕ ВЕДЕНИЕ ДОКУМЕНТАЦИИ

Это не опционально. После каждой сессии работы над проектом — обновлять документацию.

### После завершения проекта (деплой + проверка):
- [ ] **`_docs/PROJECT_INDEX.md`** — сменить статус проекта с 🔲 на ✅, добавить особенности
- [ ] **`MASTER_PLAN.md`** — обновить статус в общей карте проектов
- [ ] **`NN-project/PROJECT_STATUS.md`** — создать или обновить: что сделано, что НЕ реализовано, известные проблемы

### При обнаружении новой проблемы/особенности:
- [ ] **`_docs/GOTCHAS.md`** — добавить в конец новый раздел с номером, описанием проблемы и решением
- [ ] **`/root/.claude/projects/.../memory/feedback_deployment_gotchas.md`** — добавить краткое правило

### При изменении инфраструктуры (новый сервис, домен, порт):
- [ ] **`CLAUDE.md`** (этот файл) — обновить таблицу доменов/портов и раздел ИНФРАСТРУКТУРА
- [ ] **`_docs/PROJECT_INDEX.md`** — добавить в раздел «Дополнительные проекты» или «Инфраструктурные сервисы»
- [ ] **Auto-memory** — обновить карту сервера

### Формат PROJECT_STATUS.md (создавать для каждого проекта):
```markdown
# Статус: NN-название

**Домен:** https://SUBDOMAIN.YOURDOMAIN.COM
**Дата завершения:** YYYY-MM-DD
**Статус:** ✅ Готов / 🔄 В работе

## Реализовано
- ...

## Не реализовано / оставлено на потом
- ...

## Известные проблемы
- ...

## Команды для управления
```bash
cd /root/projects/NN-name
docker-compose up -d --build
docker-compose logs -f backend
```
```

## ПОРЯДОК НАЧАЛА РАБОТЫ НАД ЛЮБЫМ ПРОЕКТОМ

1. **Прочитать MASTER_PLAN.md** — карта всех проектов, порты, домены, фазы.
2. **Прочитать SPEC.md нужного проекта** — детальная спецификация: маршруты, API, схема БД, ключевые особенности.
3. **Прочитать PROJECT_STATUS.md проекта** (если есть) — что уже сделано, что осталось.
4. **Прочитать auto-memory** — напоминания из прошлых сессий (готчи, предупреждения).

---

## СТРУКТУРА ПРОЕКТОВ

```
/root/projects/
├── MASTER_PLAN.md          ← Читать ПЕРВЫМ
├── CLAUDE.md               ← Этот файл (протокол)
├── _shared/                ← Shared PostgreSQL + Redis
├── _docs/                  ← Общая документация
│   ├── PROJECT_INDEX.md    ← Статус всех проектов (обновлять после каждого!)
│   └── GOTCHAS.md          ← Критические баги и решения (читать всегда!)
├── 01-project-one/  ✅
├── 02-project-two/  🔄
└── ...
```

---

## ИНФРАСТРУКТУРА (заполнить под свой сервер)

| Параметр | Значение |
|----------|----------|
| Shared Postgres | `shared-postgres-1` (hostname в Docker сети) |
| Shared Redis | `shared-redis-1` |
| Docker network | `shared_net` (external: true) |
| bcrypt версия | `bcrypt==3.2.2` + `passlib[bcrypt]==1.7.4` (никогда не менять!) |
| Docker Compose | `docker-compose` (v2 alias) |
| VPS IP | `YOUR_VPS_IP` |

**Важно:** `environment:` в docker-compose перекрывает `env_file:`. Для переменных из `.env` используй только `env_file: .env`.

### Seed-данные — два паттерна:
```bash
# Паттерн 1: app/seed.py как модуль
docker-compose exec backend python -m app.seed

# Паттерн 2: seed.py в корне backend/
docker-compose exec backend python seed.py
```

---

## ЧЕКЛИСТ ДО ДЕПЛОЯ

- [ ] `docker exec shared-postgres-1 psql -U postgres -c "CREATE DATABASE NAME;"` (если новый проект)
- [ ] Backend код изменён → `docker-compose build backend && docker-compose up -d backend`
- [ ] Frontend код изменён → `docker-compose build frontend && docker-compose up -d frontend`
- [ ] Новые зависимости → rebuild обязателен (не restart!)
- [ ] Seed данные (выбрать паттерн): `docker-compose exec backend python -m app.seed` ИЛИ `python seed.py`
- [ ] Проверка API: `curl -s http://localhost:BE_PORT/health`
- [ ] Nginx vhost создан + `nginx -t && nginx -s reload`
- [ ] SSL: `certbot --nginx -d SUBDOMAIN.YOURDOMAIN.COM --non-interactive --agree-tos -m YOUR_EMAIL`
- [ ] Финальная проверка: `curl -s -o /dev/null -w "%{http_code}" https://SUBDOMAIN.YOURDOMAIN.COM`
- [ ] Nginx WebSocket (если нужен): добавить `Upgrade $http_upgrade` + `Connection "upgrade"` headers

---

## ДОМЕНЫ И ПОРТЫ (заполнить под свой сервер)

| # | Домен | FE порт | BE порт | DB | Статус |
|---|-------|---------|---------|-----|--------|
| 1 | project1.YOURDOMAIN.COM | 3001 | 8001 | db1 | 🔲 |
| 2 | project2.YOURDOMAIN.COM | 3002 | 8002 | db2 | 🔲 |

---

## TELEGRAM БОТ (если используется)

- Token: `YOUR_BOT_TOKEN`
- Chat ID: получить через `/start` в боте, затем `getUpdates`
