---
name: nodejs-backend-dev
description: Specialized Node.js backend development agent for building REST APIs and CLI applications using Node.js 24+. Use when building Express REST APIs, creating CLI tools, implementing backend services, or working with modern Node.js features (ES modules, built-in test runner, watch mode, parseArgs). Focuses on minimal, production-ready code patterns for API routes, controllers, middleware, error handling, and command-line interfaces. For Docker containerization, use the docker-compose skill.
---

# Node.js Backend Developer

Specialized subagent for Node.js 24+ backend development with focus on REST APIs and CLI applications.

## Core Capabilities

### 1. REST API Development

Build Express-based REST APIs with standard patterns:

```javascript
// Standard CRUD endpoint structure
router.get('/', getAllItems);
router.get('/:id', getItemById);
router.post('/', createItem);
router.put('/:id', updateItem);
router.delete('/:id', deleteItem);
```

**Quick start:** Use `scripts/init_express_api.sh` to scaffold a new Express API project.

**Patterns:** See `references/rest_api_patterns.md` for controller patterns, middleware, error handling, and response structures.

### 2. CLI Application Development

Build command-line tools using Node.js 24+ built-in features:

```javascript
import { parseArgs } from 'node:util';

const { values, positionals } = parseArgs({
  options: {
    port: { type: 'string', short: 'p', default: '3000' }
  },
  allowPositionals: true
});
```

**Quick start:** Use `scripts/create_cli.sh` to scaffold a new CLI application.

**Patterns:** See `references/cli_patterns.md` for argument parsing, interactive prompts, file operations, and command patterns.

### 3. Modern Node.js 24+ Features

Leverage built-in capabilities:

- ES modules (default)
- Built-in test runner (`node --test`)
- Watch mode (`node --watch`)
- Native `parseArgs` for CLI
- Built-in `fetch` API
- Async context tracking

**Reference:** See `references/node24_features.md` for complete feature list and examples.

## Development Principles

**Minimal dependencies:** Prefer built-in Node.js features over external packages when possible.

**ES modules:** Always use `"type": "module"` in package.json and import/export syntax.

**Error handling:** Use try-catch in async functions, implement centralized error middleware.

**Structure:** Organize by feature (routes, controllers, middleware, models, utils).

**Testing:** Use built-in test runner for unit tests.

**Docker:** For containerization, use the `docker-compose` skill.

## Quick Reference

### Initialize Express API
```bash
bash scripts/init_express_api.sh my-api 3000
cd my-api && npm install && npm run dev
```

### Create CLI Tool
```bash
bash scripts/create_cli.sh my-cli
cd my-cli && node bin/cli.js --help
```

### Run with Watch Mode
```bash
node --watch src/index.js
```

### Run Tests
```bash
node --test
```

## Resources

### scripts/
- `init_express_api.sh` - Scaffold Express REST API project
- `create_cli.sh` - Scaffold CLI application

### references/
- `rest_api_patterns.md` - Express patterns for routes, controllers, middleware, error handling
- `cli_patterns.md` - CLI patterns for parseArgs, prompts, file operations
- `node24_features.md` - Node.js 24+ built-in features and APIs
