# Node.js PostgreSQL Integration

## pg Library (Recommended)

### Installation
```bash
npm install pg
```

### Basic Connection
```javascript
import pg from 'pg';
const { Pool } = pg;

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  user: 'user',
  password: 'pass',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### Query Patterns

#### Simple Query
```javascript
const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
const user = result.rows[0];
```

#### Parameterized Query
```javascript
const { rows } = await pool.query(
  'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING *',
  [email, name]
);
```

#### Transaction
```javascript
const client = await pool.connect();
try {
  await client.query('BEGIN');
  await client.query('INSERT INTO orders (user_id, total) VALUES ($1, $2)', [userId, total]);
  await client.query('UPDATE users SET balance = balance - $1 WHERE id = $2', [total, userId]);
  await client.query('COMMIT');
} catch (e) {
  await client.query('ROLLBACK');
  throw e;
} finally {
  client.release();
}
```

### Repository Pattern

```javascript
// repositories/userRepository.js
export class UserRepository {
  constructor(pool) {
    this.pool = pool;
  }

  async findById(id) {
    const { rows } = await this.pool.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );
    return rows[0];
  }

  async findByEmail(email) {
    const { rows } = await this.pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    return rows[0];
  }

  async create(user) {
    const { rows } = await this.pool.query(
      'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING *',
      [user.email, user.name]
    );
    return rows[0];
  }

  async update(id, user) {
    const { rows } = await this.pool.query(
      'UPDATE users SET name = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [user.name, id]
    );
    return rows[0];
  }

  async delete(id) {
    await this.pool.query('DELETE FROM users WHERE id = $1', [id]);
  }
}
```

### Usage in Express

```javascript
// index.js
import express from 'express';
import pg from 'pg';
import { UserRepository } from './repositories/userRepository.js';

const { Pool } = pg;
const app = express();
const pool = new Pool({ /* config */ });
const userRepo = new UserRepository(pool);

app.use(express.json());

app.get('/users/:id', async (req, res) => {
  try {
    const user = await userRepo.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'Not found' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/users', async (req, res) => {
  try {
    const user = await userRepo.create(req.body);
    res.status(201).json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await pool.end();
  process.exit(0);
});
```

## Environment Variables

```bash
# .env
DATABASE_URL=postgres://user:pass@localhost:5432/mydb
# or
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=user
DB_PASS=pass
```

```javascript
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // or
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
});
```

## Error Handling

```javascript
try {
  await pool.query('...');
} catch (error) {
  if (error.code === '23505') {
    // Unique violation
    return res.status(409).json({ error: 'Already exists' });
  }
  if (error.code === '23503') {
    // Foreign key violation
    return res.status(400).json({ error: 'Invalid reference' });
  }
  throw error;
}
```

## Connection Pooling

```javascript
const pool = new Pool({
  max: 20,                      // Max clients in pool
  idleTimeoutMillis: 30000,     // Close idle clients after 30s
  connectionTimeoutMillis: 2000, // Timeout if no connection available
});
```
