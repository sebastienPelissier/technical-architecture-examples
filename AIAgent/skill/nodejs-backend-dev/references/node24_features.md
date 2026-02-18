# Node.js 24+ Features

## ES Modules (Default)

```javascript
// Use "type": "module" in package.json
import express from 'express';
import { readFile } from 'node:fs/promises';

export const myFunction = () => {};
```

## Built-in Test Runner

```javascript
import { test, describe } from 'node:test';
import assert from 'node:assert';

describe('User API', () => {
  test('should create user', async () => {
    const result = await createUser({ name: 'John' });
    assert.strictEqual(result.name, 'John');
  });
});
```

Run: `node --test`

## Watch Mode

```bash
node --watch src/index.js
node --watch-path=./src --watch-path=./config src/index.js
```

## parseArgs (Built-in)

```javascript
import { parseArgs } from 'node:util';

const { values } = parseArgs({
  options: {
    port: { type: 'string', default: '3000' }
  }
});
```

## Fetch API (Built-in)

```javascript
const response = await fetch('https://api.example.com/data');
const data = await response.json();
```

## WebStreams

```javascript
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue('data');
    controller.close();
  }
});
```

## Performance Hooks

```javascript
import { performance } from 'node:perf_hooks';

const start = performance.now();
// ... operation
const duration = performance.now() - start;
```

## Async Context Tracking

```javascript
import { AsyncLocalStorage } from 'node:async_hooks';

const storage = new AsyncLocalStorage();

storage.run({ requestId: '123' }, () => {
  console.log(storage.getStore()); // { requestId: '123' }
});
```
