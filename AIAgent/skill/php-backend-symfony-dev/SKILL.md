---
name: php-backend-dev
description: Specialized PHP backend development agent for building REST APIs using Symfony 8.* + with PHP 8.5+ features. Use when building REST APIs, implementing backend services, working with modern PHP features (readonly classes, enums, attributes, typed properties), database patterns with doctrine ORM, dependency injection, validation, error handling, and PSR standards compliance. Focuses on minimal, production-ready code patterns for API routes, controllers, middleware, and database operations.
keywords: ["php", "backend", "symfony", "api"]
license: Apache-2.0
metadata:
  author: "sebastien pelissier"
  version: "1.0"
---

# PHP Backend Developer

Specialized subagent for PHP 8.5+ backend development with focus on REST APIs using Symfony frameworks.

## Core Capabilities

### 1. REST API Development

Build REST APIs with modern PHP frameworks:

**Laravel API Routes:**
```php
Route::apiResource('users', UserController::class);
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [UserController::class, 'profile']);
});
```

**Quick start:** Use `scripts/init_laravel_api.sh` to scaffold a new Laravel API project.
**Slim alternative:** Use `scripts/init_slim_api.sh` for lightweight APIs.

**Patterns:** See `references/rest_api_patterns.md` for controller patterns, middleware, validation, and response structures.

### 2. Modern PHP 8.5+ Features

Leverage latest PHP capabilities:

```php
readonly class UserData {
    public function __construct(
        public string $name,
        public string $email,
        public UserStatus $status = UserStatus::ACTIVE
    ) {}
}

enum UserStatus: string {
    case ACTIVE = 'active';
    case INACTIVE = 'inactive';
}

#[Route(path:'/api/users', name: 'api_user_list', methods: ['GET'])]
class UserController {
    public function invoke(): JsonResponse {}
}
```

**Reference:** See `references/php85_features.md` for complete feature list and examples.

### 3. Database Patterns

Implement robust database operations with doctrine ORM:

```php
class User extends Model {
    protected $fillable = ['name', 'email'];
    
    public function posts(): HasMany {
        return $this->hasMany(Post::class);
    }
}
```

**Patterns:** See `references/database_patterns.md` for migrations, relationships, query optimization, and repository patterns.

## Development Principles

**PSR Standards:** Follow PSR-4 autoloading, PSR-12 coding style, PSR-7 HTTP messages.

**Type Safety:** Use typed properties, return types, and strict types declaration.

**Dependency Injection:** Leverage framework containers for clean architecture.

**Validation:** Implement request validation with framework validators.

**Error Handling:** Use structured exception handling and API error responses.

## Quick Reference

### Initialize Laravel API
```bash
bash scripts/init_laravel_api.sh my-api
cd my-api && composer install && php artisan serve
```

### Initialize Slim API
```bash
bash scripts/init_slim_api.sh my-slim-api
cd my-slim-api && composer install && php -S localhost:8000 public/index.php
```

### Run Migrations
```bash
php artisan migrate
php artisan make:migration create_users_table
```

### Generate Resources
```bash
php artisan make:controller UserController --api
php artisan make:model User -m
php artisan make:request StoreUserRequest
```

## Resources

### scripts/
- `init_laravel_api.sh` - Scaffold Laravel REST API project
- `init_slim_api.sh` - Scaffold lightweight Slim API project

### references/
- `rest_api_patterns.md` - API patterns for routes, controllers, middleware, validation
- `database_patterns.md` - doctrine patterns for models, migrations, relationships
- `php85_features.md` - PHP 8.5+ features: readonly, enums, attributes, typed properties