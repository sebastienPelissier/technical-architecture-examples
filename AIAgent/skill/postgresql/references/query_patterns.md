# PostgreSQL Query Patterns

## Basic CRUD

### SELECT
```sql
-- Simple select
SELECT * FROM users WHERE email = 'user@example.com';

-- With joins
SELECT u.*, o.total 
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > NOW() - INTERVAL '30 days';

-- Aggregation
SELECT 
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as count
FROM users
GROUP BY day
ORDER BY day DESC;
```

### INSERT
```sql
-- Single insert
INSERT INTO users (email, name) 
VALUES ('user@example.com', 'John Doe')
RETURNING id;

-- Multiple inserts
INSERT INTO users (email, name) VALUES
  ('user1@example.com', 'User 1'),
  ('user2@example.com', 'User 2')
RETURNING id;

-- Insert from select
INSERT INTO archive_users
SELECT * FROM users WHERE created_at < NOW() - INTERVAL '1 year';
```

### UPDATE
```sql
-- Simple update
UPDATE users 
SET name = 'Jane Doe' 
WHERE id = 'uuid-here';

-- Conditional update
UPDATE users 
SET status = 'active'
WHERE last_login > NOW() - INTERVAL '30 days'
RETURNING id, status;
```

### DELETE
```sql
-- Simple delete
DELETE FROM users WHERE id = 'uuid-here';

-- Conditional delete
DELETE FROM users 
WHERE created_at < NOW() - INTERVAL '2 years'
AND status = 'inactive';
```

## Advanced Patterns

### CTEs (Common Table Expressions)
```sql
WITH recent_users AS (
  SELECT * FROM users 
  WHERE created_at > NOW() - INTERVAL '7 days'
)
SELECT COUNT(*) FROM recent_users;
```

### Window Functions
```sql
SELECT 
  name,
  email,
  ROW_NUMBER() OVER (ORDER BY created_at DESC) as row_num,
  RANK() OVER (PARTITION BY status ORDER BY created_at) as rank
FROM users;
```

### JSON Operations
```sql
-- Query JSON column
SELECT * FROM users 
WHERE metadata->>'role' = 'admin';

-- Update JSON field
UPDATE users 
SET metadata = jsonb_set(metadata, '{role}', '"admin"')
WHERE id = 'uuid-here';
```

### Full-Text Search
```sql
-- Create tsvector column
ALTER TABLE posts ADD COLUMN search_vector tsvector;

UPDATE posts 
SET search_vector = to_tsvector('english', title || ' ' || content);

-- Search
SELECT * FROM posts 
WHERE search_vector @@ to_tsquery('english', 'postgresql & query');
```

### Transactions
```sql
BEGIN;

INSERT INTO orders (user_id, total) VALUES ('uuid', 100.00);
UPDATE users SET balance = balance - 100.00 WHERE id = 'uuid';

COMMIT;
-- or ROLLBACK;
```

## Performance

### Indexes
```sql
-- B-tree (default)
CREATE INDEX idx_users_email ON users(email);

-- Partial index
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';

-- Multi-column
CREATE INDEX idx_users_status_created ON users(status, created_at);

-- GIN for JSON
CREATE INDEX idx_users_metadata ON users USING GIN (metadata);
```

### EXPLAIN
```sql
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user@example.com';
```
