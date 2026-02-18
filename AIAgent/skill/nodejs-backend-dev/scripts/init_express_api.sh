#!/bin/bash
# Initialize Express REST API project with Node.js 24+

set -e

PROJECT_NAME=${1:-"express-api"}
PORT=${2:-3000}

echo "🚀 Initializing Express API: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize package.json
cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "dev": "node --watch src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Create directory structure
mkdir -p src/{routes,middleware,controllers,models,utils}

# Create main entry point
cat > src/index.js << 'EOF'
import express from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Create .gitignore
cat > .gitignore << EOF
node_modules/
.env
*.log
EOF

echo "✅ Project initialized: $PROJECT_NAME"
echo "📦 Run: cd $PROJECT_NAME && npm install"
echo "🚀 Run: npm run dev"
