# Dockerfile Patterns

## Multi-Stage Build Pattern

```dockerfile
FROM <base-image> AS base
WORKDIR /app
COPY <dependency-files> ./

FROM base AS deps
RUN <install-production-deps>

FROM base AS build
RUN <install-all-deps>
COPY . .
RUN <build-command>

FROM <base-image> AS runtime
WORKDIR /app
COPY --from=deps /app/<deps-location> ./<deps-location>
COPY --from=build /app/<build-output> ./<build-output>
EXPOSE <port>
CMD ["<start-command>"]
```

## Node.js

```dockerfile
FROM node:24-alpine AS base
WORKDIR /app
COPY package*.json ./

FROM base AS deps
RUN npm ci --only=production

FROM base AS build
RUN npm ci
COPY . .

FROM node:24-alpine AS runtime
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/package.json ./
EXPOSE 3000
CMD ["node", "src/index.js"]
```

## Python

```dockerfile
FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements.txt .

FROM base AS deps
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim AS runtime
WORKDIR /app
COPY --from=deps /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY . .
EXPOSE 8000
CMD ["python", "main.py"]
```

## Go

```dockerfile
FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /app/server

FROM alpine:latest AS runtime
WORKDIR /app
COPY --from=build /app/server .
EXPOSE 8080
CMD ["./server"]
```

## .dockerignore

```
node_modules
.git
.env
*.log
dist
build
__pycache__
*.pyc
.pytest_cache
coverage
.vscode
.idea
```

## Best Practices

- Use alpine images for smaller size
- Multi-stage builds to reduce final image size
- Copy dependency files first for better caching
- Use specific versions, not `latest`
- Run as non-root user in production
- Use .dockerignore to exclude unnecessary files
