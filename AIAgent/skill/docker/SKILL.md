---
name: docker
description: Docker and Docker Compose v2 containerization for any application. Use when containerizing applications, creating multi-service setups, configuring databases with Docker, or working with Docker Compose. Supports Node.js, Python, Go, and other languages with multi-stage Dockerfile patterns, compose configurations, volume management, networking, and healthchecks.
---

# Docker Compose

Containerization with Docker and Docker Compose v2 for multi-language applications.

## Core Capabilities

### 1. Dockerfile Generation

Multi-stage Dockerfiles for optimized images:

**Node.js:**
```bash
bash scripts/dockerfile_nodejs.sh 24
```

**Python:**
```bash
bash scripts/dockerfile_python.sh 3.12
```

**Patterns:** See `references/dockerfile_patterns.md` for Node.js, Python, Go patterns and best practices.

### 2. Docker Compose v2 Configuration

Create compose.yaml for single or multi-service setups:

```bash
bash scripts/init_compose.sh app 3000
```

**Patterns:** See `references/compose_reference.md` for:
- Multi-service configurations
- Database integration (PostgreSQL, Redis, MongoDB)
- Development vs production setups
- Networks and volumes
- Healthchecks and dependencies

## Docker Compose v2 Syntax

No `version:` field. Use `compose.yaml`:

```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
    restart: unless-stopped
```

## Common Commands

```bash
docker compose up -d              # Start services
docker compose logs -f [service]  # View logs
docker compose up -d --build      # Rebuild and start
docker compose down               # Stop services
docker compose down -v            # Stop and remove volumes
```

## Multi-Service Pattern

```yaml
services:
  api:
    build: .
    depends_on:
      db:
        condition: service_healthy
  
  db:
    image: postgres:18-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 5s
```

## Resources

### scripts/
- `dockerfile_nodejs.sh` - Generate Node.js multi-stage Dockerfile
- `dockerfile_python.sh` - Generate Python multi-stage Dockerfile
- `init_compose.sh` - Generate compose.yaml and .dockerignore

### references/
- `dockerfile_patterns.md` - Multi-stage patterns for Node.js, Python, Go, PHP, Rust
- `compose_reference.md` - Docker Compose v2 configurations, databases, networking
