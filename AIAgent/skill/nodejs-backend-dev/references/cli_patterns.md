# CLI Patterns for Node.js 24+

## Built-in parseArgs (Node 24+)

```javascript
import { parseArgs } from 'node:util';

const { values, positionals } = parseArgs({
  options: {
    verbose: { type: 'boolean', short: 'v' },
    output: { type: 'string', short: 'o' },
    port: { type: 'string', default: '3000' }
  },
  allowPositionals: true
});

console.log('Options:', values);
console.log('Commands:', positionals);
```

## Command Pattern

```javascript
// commands/index.js
const commands = {
  start: async (args) => {
    console.log('Starting server...');
  },
  build: async (args) => {
    console.log('Building project...');
  }
};

export const executeCommand = async (name, args) => {
  const command = commands[name];
  if (!command) {
    console.error(`Unknown command: ${name}`);
    process.exit(1);
  }
  await command(args);
};
```

## Interactive Prompts (readline)

```javascript
import * as readline from 'node:readline/promises';
import { stdin, stdout } from 'node:process';

const rl = readline.createInterface({ input: stdin, output: stdout });

const name = await rl.question('What is your name? ');
console.log(`Hello ${name}!`);
rl.close();
```

## Progress Indicator

```javascript
const spinner = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
let i = 0;

const interval = setInterval(() => {
  process.stdout.write(`\r${spinner[i]} Loading...`);
  i = (i + 1) % spinner.length;
}, 80);

// Stop spinner
clearInterval(interval);
process.stdout.write('\r✓ Done!\n');
```

## File Operations

```javascript
import { readFile, writeFile } from 'node:fs/promises';

// Read
const data = await readFile('config.json', 'utf8');
const config = JSON.parse(data);

// Write
await writeFile('output.json', JSON.stringify(result, null, 2));
```

## Environment Variables

```javascript
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';
```

## Exit Codes

```javascript
process.exit(0);  // Success
process.exit(1);  // Error
```
