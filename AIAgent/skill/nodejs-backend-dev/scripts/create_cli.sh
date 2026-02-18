#!/bin/bash
# Create Node.js CLI application with Node.js 24+

set -e

CLI_NAME=${1:-"my-cli"}

echo "🚀 Creating CLI: $CLI_NAME"

mkdir -p "$CLI_NAME"
cd "$CLI_NAME"

# Initialize package.json
cat > package.json << EOF
{
  "name": "$CLI_NAME",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "$CLI_NAME": "./bin/cli.js"
  },
  "scripts": {
    "start": "node bin/cli.js"
  }
}
EOF

# Create bin directory
mkdir -p bin

# Create CLI entry point
cat > bin/cli.js << 'EOF'
#!/usr/bin/env node
import { parseArgs } from 'node:util';

const { values, positionals } = parseArgs({
  options: {
    help: { type: 'boolean', short: 'h' },
    version: { type: 'boolean', short: 'v' }
  },
  allowPositionals: true
});

if (values.help) {
  console.log('Usage: cli [options] [command]');
  process.exit(0);
}

if (values.version) {
  console.log('1.0.0');
  process.exit(0);
}

const command = positionals[0];

if (!command) {
  console.log('No command specified. Use --help for usage.');
  process.exit(1);
}

console.log(`Executing: ${command}`);
EOF

chmod +x bin/cli.js

echo "✅ CLI initialized: $CLI_NAME"
echo "🚀 Run: cd $CLI_NAME && node bin/cli.js --help"
echo "📦 Install globally: npm link"
