---
name: postgresql
description: PostgreSQL database development and management. Use when designing database schemas, writing SQL queries, integrating PostgreSQL with Node.js applications, creating migrations, or working with PostgreSQL features (JSONB, full-text search, triggers, indexes). Covers schema design, query patterns, Node.js pg library integration, and best practices.
keywords: ["database", "postgres", "storage", "backend","sql"]
license: Apache-2.0
metadata:
  author: "sebastien pelissier"
  version: "1.0"
---

# PostgreSQL

Database development and management with PostgreSQL.

## Core Capabilities

### 1. Schema Design

Design tables, constraints, indexes, and triggers:

```sql
CREATE TABLE users (
                       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       email VARCHAR(255) UNIQUE NOT NULL,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Quick start:** Use `scripts/init_db.sh` to generate initial schema.

**Patterns:** See `references/schema_design.md` for data types, constraints, indexes, triggers, and best practices.

### 2. SQL Queries

Write efficient queries with PostgreSQL features:

```sql
-- CTE with window functions
WITH recent_users AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY created_at DESC) as rn
    FROM users WHERE created_at > NOW() - INTERVAL '7 days'
    )
SELECT * FROM recent_users WHERE rn <= 10;
```

**Patterns:** See `references/query_patterns.md` for CRUD, CTEs, window functions, JSON operations, full-text search, and performance optimization.

### 3. Node.js Integration

Integrate PostgreSQL with Node.js using pg library:

```javascript
import pg from 'pg';
const { Pool } = pg;

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const { rows } = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
```

**Patterns:** See `references/nodejs_integration.md` for connection pooling, repository pattern, transactions, error handling, and Express integration.

### 4. Migrations

Create and manage database migrations:

```bash
bash scripts/create_migration.sh create_users_table
```

**Pattern:** Timestamp-based migration files with up/down sections.

## PostgreSQL Features

**JSONB:** Store and query JSON data efficiently
**Full-text search:** Built-in text search with tsvector
**UUID:** Native UUID support with uuid-ossp extension
**Triggers:** Automatic actions on data changes
**CTEs:** Common table expressions for complex queries
**Window functions:** Advanced analytics queries

## Docker Integration

Use with docker-compose skill:

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db_data:/var/lib/postgresql/data
```

## Quick Reference

### Initialize Database
```bash
bash scripts/init_db.sh mydb user pass
psql -U postgres -f init.sql
```

### Create Migration
```bash
bash scripts/create_migration.sh add_users_table
```

### Connect from Node.js
```javascript
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const result = await pool.query('SELECT * FROM users');
```

## Resources

### scripts/
- `init_db.sh` - Generate initial database schema with extensions
- `create_migration.sh` - Create timestamped migration file

### references/
- `schema_design.md` - Data types, tables, constraints, indexes, triggers
- `query_patterns.md` - SQL patterns for CRUD, CTEs, JSON, full-text search
- `nodejs_integration.md` - pg library, connection pooling, repository pattern
