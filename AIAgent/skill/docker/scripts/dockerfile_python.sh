#!/bin/bash
# Generate Dockerfile for Python application

set -e

PYTHON_VERSION=${1:-3.12}

cat > Dockerfile << EOF
FROM python:${PYTHON_VERSION}-slim AS base
WORKDIR /app
COPY requirements.txt .

FROM base AS deps
RUN pip install --no-cache-dir -r requirements.txt

FROM python:${PYTHON_VERSION}-slim AS runtime
WORKDIR /app
COPY --from=deps /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages
COPY . .

EXPOSE 8000
CMD ["python", "main.py"]
EOF

echo "✅ Dockerfile created for Python ${PYTHON_VERSION}"
