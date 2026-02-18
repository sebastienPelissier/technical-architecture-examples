#!/bin/bash
# Generate migration file

set -e

MIGRATION_NAME=${1:-create_table}
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FILENAME="${TIMESTAMP}_${MIGRATION_NAME}.sql"

mkdir -p migrations

cat > "migrations/${FILENAME}" << 'EOF'
-- Migration: MIGRATION_NAME
-- Created: TIMESTAMP

-- Up
BEGIN;

-- Add your schema changes here

COMMIT;

-- Down (for rollback)
-- BEGIN;
-- DROP TABLE IF EXISTS table_name;
-- COMMIT;
EOF

sed -i "s/MIGRATION_NAME/${MIGRATION_NAME}/g" "migrations/${FILENAME}"
sed -i "s/TIMESTAMP/$(date)/g" "migrations/${FILENAME}"

echo "✅ Migration created: migrations/${FILENAME}"
