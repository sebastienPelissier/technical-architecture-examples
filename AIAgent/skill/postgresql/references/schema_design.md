# PostgreSQL Schema Design

## Data Types

### Common Types
```sql
-- Text
VARCHAR(255)        -- Variable length with limit
TEXT                -- Unlimited length
CHAR(10)           -- Fixed length

-- Numbers
INTEGER            -- 4 bytes
BIGINT             -- 8 bytes
NUMERIC(10,2)      -- Exact decimal
REAL               -- 4 bytes float
DOUBLE PRECISION   -- 8 bytes float

-- Date/Time
DATE               -- Date only
TIME               -- Time only
TIMESTAMP          -- Date and time
TIMESTAMPTZ        -- Timestamp with timezone

-- Boolean
BOOLEAN            -- true/false

-- UUID
UUID               -- Universally unique identifier

-- JSON
JSON               -- JSON data
JSONB              -- Binary JSON (faster, indexable)

-- Arrays
INTEGER[]          -- Array of integers
TEXT[]             -- Array of text
```

## Table Design

### Basic Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Foreign Keys
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Composite Keys
```sql
CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id),
  role_id UUID REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);
```

## Constraints

```sql
-- NOT NULL
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- UNIQUE
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- CHECK
ALTER TABLE users ADD CONSTRAINT check_email 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- DEFAULT
ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active';
```

## Indexes

```sql
-- Single column
CREATE INDEX idx_users_email ON users(email);

-- Multi-column
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at);

-- Partial
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';

-- Unique
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);

-- GIN for JSONB
CREATE INDEX idx_users_metadata ON users USING GIN (metadata);

-- Full-text search
CREATE INDEX idx_posts_search ON posts USING GIN (to_tsvector('english', content));
```

## Triggers

### Auto-update timestamp
```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();
```

### Audit log
```sql
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  table_name TEXT,
  operation TEXT,
  old_data JSONB,
  new_data JSONB,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, operation, old_data, new_data)
  VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_audit
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION audit_trigger();
```

## Extensions

```sql
-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Fuzzy string matching
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

## Best Practices

- Use UUID for primary keys in distributed systems
- Use TIMESTAMPTZ for timestamps (includes timezone)
- Use JSONB over JSON for better performance
- Add indexes on foreign keys
- Use partial indexes for filtered queries
- Use CHECK constraints for data validation
- Use triggers for automatic timestamp updates
- Use CASCADE carefully with foreign keys
