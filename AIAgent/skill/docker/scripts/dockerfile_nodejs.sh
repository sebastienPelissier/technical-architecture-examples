#!/bin/bash
# Generate Dockerfile for Node.js application

set -e

NODE_VERSION=${1:-24}

cat > Dockerfile << EOF
FROM node:${NODE_VERSION}-alpine AS base
WORKDIR /app
COPY package*.json ./

FROM base AS deps
RUN npm ci --only=production

FROM base AS build
RUN npm ci
COPY . .

FROM node:${NODE_VERSION}-alpine AS runtime
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/package.json ./

EXPOSE 3000
CMD ["node", "src/index.js"]
EOF

echo "✅ Dockerfile created for Node.js ${NODE_VERSION}"
