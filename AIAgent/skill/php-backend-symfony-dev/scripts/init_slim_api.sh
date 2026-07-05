#!/bin/bash

# Slim Framework API Project Initialization Script
# Usage: bash init_slim_api.sh <project-name> [port]

set -e

PROJECT_NAME=${1:-"slim-api"}
PORT=${2:-8000}

echo "🚀 Initializing Slim API project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize composer
composer init --name="app/$PROJECT_NAME" --type=project --no-interaction

# Install Slim and dependencies
composer require slim/slim:"4.*"
composer require slim/psr7
composer require slim/http
composer require php-di/php-di
composer require monolog/monolog
composer require --dev phpunit/phpunit

# Create directory structure
mkdir -p public
mkdir -p src/{Controllers,Middleware,Models}
mkdir -p config
mkdir -p logs

# Create public/index.php
cat > public/index.php << 'EOF'
<?php

declare(strict_types=1);

use DI\Container;
use Slim\Factory\AppFactory;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

require __DIR__ . '/../vendor/autoload.php';

// Create Container
$container = new Container();
AppFactory::setContainer($container);

// Create App
$app = AppFactory::create();

// Add error middleware
$app->addErrorMiddleware(true, true, true);

// Add body parsing middleware
$app->addBodyParsingMiddleware();

// Routes
$app->get('/', function (Request $request, Response $response) {
    $data = ['message' => 'Hello, Slim API!', 'timestamp' => date('c')];
    $response->getBody()->write(json_encode($data));
    return $response->withHeader('Content-Type', 'application/json');
});

// API routes group
$app->group('/api', function ($group) {
    $group->get('/users', \App\Controllers\UserController::class . ':index');
    $group->get('/users/{id}', \App\Controllers\UserController::class . ':show');
    $group->post('/users', \App\Controllers\UserController::class . ':create');
    $group->put('/users/{id}', \App\Controllers\UserController::class . ':update');
    $group->delete('/users/{id}', \App\Controllers\UserController::class . ':delete');
});

$app->run();
EOF

# Create UserController
cat > src/Controllers/UserController.php << 'EOF'
<?php

declare(strict_types=1);

namespace App\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class UserController
{
    private array $users = [
        ['id' => 1, 'name' => 'John Doe', 'email' => 'john@example.com'],
        ['id' => 2, 'name' => 'Jane Smith', 'email' => 'jane@example.com']
    ];

    public function index(Request $request, Response $response): Response
    {
        $response->getBody()->write(json_encode([
            'data' => $this->users,
            'total' => count($this->users)
        ]));
        return $response->withHeader('Content-Type', 'application/json');
    }

    public function show(Request $request, Response $response, array $args): Response
    {
        $id = (int) $args['id'];
        $user = array_filter($this->users, fn($u) => $u['id'] === $id);
        
        if (empty($user)) {
            $response->getBody()->write(json_encode(['error' => 'User not found']));
            return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
        }

        $response->getBody()->write(json_encode(['data' => array_values($user)[0]]));
        return $response->withHeader('Content-Type', 'application/json');
    }

    public function create(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();
        
        // Basic validation
        if (empty($data['name']) || empty($data['email'])) {
            $response->getBody()->write(json_encode([
                'error' => 'Name and email are required'
            ]));
            return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
        }

        $newUser = [
            'id' => count($this->users) + 1,
            'name' => $data['name'],
            'email' => $data['email']
        ];

        $response->getBody()->write(json_encode(['data' => $newUser]));
        return $response->withStatus(201)->withHeader('Content-Type', 'application/json');
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        $id = (int) $args['id'];
        $data = $request->getParsedBody();
        
        $userIndex = array_search($id, array_column($this->users, 'id'));
        
        if ($userIndex === false) {
            $response->getBody()->write(json_encode(['error' => 'User not found']));
            return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
        }

        if (isset($data['name'])) {
            $this->users[$userIndex]['name'] = $data['name'];
        }
        if (isset($data['email'])) {
            $this->users[$userIndex]['email'] = $data['email'];
        }

        $response->getBody()->write(json_encode(['data' => $this->users[$userIndex]]));
        return $response->withHeader('Content-Type', 'application/json');
    }

    public function delete(Request $request, Response $response, array $args): Response
    {
        $id = (int) $args['id'];
        $userIndex = array_search($id, array_column($this->users, 'id'));
        
        if ($userIndex === false) {
            $response->getBody()->write(json_encode(['error' => 'User not found']));
            return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
        }

        unset($this->users[$userIndex]);
        return $response->withStatus(204);
    }
}
EOF

# Create basic middleware
cat > src/Middleware/JsonMiddleware.php << 'EOF'
<?php

declare(strict_types=1);

namespace App\Middleware;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

class JsonMiddleware
{
    public function __invoke(Request $request, RequestHandler $handler): Response
    {
        $response = $handler->handle($request);
        return $response->withHeader('Content-Type', 'application/json');
    }
}
EOF

# Update composer.json for autoloading
cat > composer.json << EOF
{
    "name": "app/$PROJECT_NAME",
    "type": "project",
    "require": {
        "slim/slim": "4.*",
        "slim/psr7": "^1.6",
        "slim/http": "^1.3",
        "php-di/php-di": "^7.0",
        "monolog/monolog": "^3.0"
    },
    "require-dev": {
        "phpunit/phpunit": "^10.0"
    },
    "autoload": {
        "psr-4": {
            "App\\\\": "src/"
        }
    },
    "config": {
        "process-timeout": 0,
        "sort-packages": true
    }
}
EOF

# Install dependencies
composer install

# Create .htaccess for Apache
cat > public/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.php [QSA,L]
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

A lightweight REST API built with Slim Framework 4.

## Installation

\`\`\`bash
composer install
\`\`\`

## Development Server

\`\`\`bash
php -S localhost:$PORT -t public
\`\`\`

## API Endpoints

- \`GET /\` - Welcome message
- \`GET /api/users\` - List all users
- \`GET /api/users/{id}\` - Get user by ID
- \`POST /api/users\` - Create new user
- \`PUT /api/users/{id}\` - Update user
- \`DELETE /api/users/{id}\` - Delete user

## Example Usage

\`\`\`bash
# Get all users
curl http://localhost:$PORT/api/users

# Create a user
curl -X POST http://localhost:$PORT/api/users \\
  -H "Content-Type: application/json" \\
  -d '{"name":"John Doe","email":"john@example.com"}'
\`\`\`
EOF

echo "✅ Slim API project '$PROJECT_NAME' created successfully!"
echo ""
echo "📁 Project structure:"
echo "   public/index.php         - Application entry point"
echo "   src/Controllers/         - API controllers"
echo "   src/Middleware/          - Custom middleware"
echo "   src/Models/              - Data models"
echo ""
echo "🚀 To start development:"
echo "   cd $PROJECT_NAME"
echo "   php -S localhost:$PORT -t public"
echo ""
echo "📖 API endpoints:"
echo "   GET    /api/users     - List users"
echo "   POST   /api/users     - Create user"
echo "   GET    /api/users/{id} - Show user"
echo "   PUT    /api/users/{id} - Update user"
echo "   DELETE /api/users/{id} - Delete user"