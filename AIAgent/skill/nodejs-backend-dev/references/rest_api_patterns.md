# REST API Patterns for Express

## Standard Route Structure

```javascript
// routes/users.js
import express from 'express';
const router = express.Router();

router.get('/', getAllUsers);
router.get('/:id', getUserById);
router.post('/', createUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);

export default router;
```

## Controller Pattern

```javascript
// controllers/userController.js
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'Not found' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

## Middleware Patterns

### Error Handler
```javascript
// middleware/errorHandler.js
export const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error'
  });
};
```

### Validation
```javascript
// middleware/validate.js
export const validateUser = (req, res, next) => {
  const { email, name } = req.body;
  if (!email || !name) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  next();
};
```

### Auth
```javascript
// middleware/auth.js
export const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  // Verify token logic
  next();
};
```

## Response Patterns

### Success
```javascript
res.status(200).json({ data: result });
res.status(201).json({ data: created, message: 'Created' });
```

### Error
```javascript
res.status(400).json({ error: 'Bad request' });
res.status(404).json({ error: 'Not found' });
res.status(500).json({ error: 'Server error' });
```

## Async Handler Wrapper

```javascript
// utils/asyncHandler.js
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Usage
router.get('/', asyncHandler(async (req, res) => {
  const data = await fetchData();
  res.json(data);
}));
```
