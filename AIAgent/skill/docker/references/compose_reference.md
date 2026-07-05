# Docker Compose v2 Reference

## Syntax

Docker Compose v2 uses `compose.yaml` (no `version:` field).

## Basic Service

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

## Multi-Service with Database

```yaml
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgres://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db_data:
```

## Development vs Production

### Development
```yaml
services:
  app:
    build:
      context: .
      target: base
    volumes:
      - ./src:/app/src
    environment:
      NODE_ENV: development
    command: npm run dev
```

### Production
```yaml
services:
  app:
    build:
      context: .
      target: runtime
    environment:
      NODE_ENV: production
    restart: unless-stopped
```

## Common Databases

### PostgreSQL
```yaml
db:
  image: postgres:16-alpine
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: pass
    POSTGRES_DB: mydb
  volumes:
    - db_data:/var/lib/postgresql/data
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U user"]
    interval: 5s
```

### Redis
```yaml
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
```

### MongoDB
```yaml
mongo:
  image: mongo:7
  environment:
    MONGO_INITDB_ROOT_USERNAME: root
    MONGO_INITDB_ROOT_PASSWORD: pass
  volumes:
    - mongo_data:/data/db
```

## Networks

```yaml
services:
  api:
    networks:
      - frontend
      - backend
  
  db:
    networks:
      - backend

networks:
  frontend:
  backend:
```

## Commands

```bash
# Start
docker compose up -d

# Logs
docker compose logs -f [service]

# Rebuild
docker compose up -d --build

# Stop
docker compose down

# Stop and remove volumes
docker compose down -v

# Scale service
docker compose up -d --scale api=3
```
