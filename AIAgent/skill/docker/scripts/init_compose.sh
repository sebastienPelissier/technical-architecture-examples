#!/bin/bash
# Generate basic compose.yaml

set -e

SERVICE_NAME=${1:-app}
PORT=${2:-3000}

cat > compose.yaml << EOF
services:
  ${SERVICE_NAME}:
    build: .
    ports:
      - "${PORT}:${PORT}"
    environment:
      NODE_ENV: production
    restart: unless-stopped
EOF

cat > .dockerignore << 'EOF'
node_modules
.git
.env
*.log
dist
build
EOF

echo "✅ compose.yaml and .dockerignore created"
echo "🚀 Run: docker compose up -d"
