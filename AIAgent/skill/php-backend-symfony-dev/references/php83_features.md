# PHP 8.3+ Modern Features

## Readonly Classes and Properties

### Readonly Classes
```php
<?php

readonly class UserData
{
    public function __construct(
        public string $name,
        public string $email,
        public int $age
    ) {}
}

// Usage
$user = new UserData('John Doe', 'john@example.com', 30);
// $user->name = 'Jane'; // Error: Cannot modify readonly property
```

### Readonly Properties
```php
<?php

class User
{
    public readonly string $id;
    public string $name;
    
    public function __construct(string $name)
    {
        $this->id = uniqid(); // Can set once in constructor
        $this->name = $name;
    }
}
```

## Enums

### String Backed Enums
```php
<?php

enum UserStatus: string
{
    case ACTIVE = 'active';
    case INACTIVE = 'inactive';
    case SUSPENDED = 'suspended';
    case PENDING = 'pending';
    
    public function label(): string
    {
        return match($this) {
            self::ACTIVE => 'Active User',
            self::INACTIVE => 'Inactive User',
            self::SUSPENDED => 'Suspended User',
            self::PENDING => 'Pending Approval'
        };
    }
    
    public function canLogin(): bool
    {
        return $this === self::ACTIVE;
    }
}

// Usage
$status = UserStatus::ACTIVE;
echo $status->value; // 'active'
echo $status->label(); // 'Active User'
```

### Integer Backed Enums
```php
<?php

enum Priority: int
{
    case LOW = 1;
    case MEDIUM = 2;
    case HIGH = 3;
    case CRITICAL = 4;
    
    public static function fromString(string $priority): self
    {
        return match(strtolower($priority)) {
            'low' => self::LOW,
            'medium' => self::MEDIUM,
            'high' => self::HIGH,
            'critical' => self::CRITICAL,
            default => throw new InvalidArgumentException("Invalid priority: $priority")
        };
    }
}
```

## Attributes

### Custom Attributes
```php
<?php

#[Attribute(Attribute::TARGET_METHOD)]
class Route
{
    public function __construct(
        public string $path,
        public array $methods = ['GET']
    ) {}
}

#[Attribute(Attribute::TARGET_PROPERTY)]
class Validate
{
    public function __construct(
        public array $rules
    ) {}
}

class UserController
{
    #[Route('/api/users', ['GET'])]
    public function index(): JsonResponse
    {
        return response()->json(User::all());
    }
    
    #[Route('/api/users', ['POST'])]
    public function store(Request $request): JsonResponse
    {
        // Implementation
    }
}

class User
{
    #[Validate(['required', 'string', 'max:255'])]
    public string $name;
    
    #[Validate(['required', 'email', 'unique:users'])]
    public string $email;
}
```

### Using Reflection with Attributes
```php
<?php

function getRoutes(string $controllerClass): array
{
    $reflection = new ReflectionClass($controllerClass);
    $routes = [];
    
    foreach ($reflection->getMethods() as $method) {
        $attributes = $method->getAttributes(Route::class);
        
        foreach ($attributes as $attribute) {
            $route = $attribute->newInstance();
            $routes[] = [
                'path' => $route->path,
                'methods' => $route->methods,
                'handler' => [$controllerClass, $method->getName()]
            ];
        }
    }
    
    return $routes;
}
```

## Typed Properties

### Strict Typing
```php
<?php

declare(strict_types=1);

class Product
{
    public function __construct(
        public string $name,
        public float $price,
        public int $quantity,
        public bool $isActive,
        public array $tags,
        public ?string $description = null,
        public DateTime $createdAt = new DateTime()
    ) {}
}
```

### Union Types
```php
<?php

class ApiResponse
{
    public function __construct(
        public string|int $id,
        public array|object $data,
        public string|null $error = null
    ) {}
}

function processId(string|int $id): string
{
    return match(gettype($id)) {
        'string' => $id,
        'integer' => (string) $id,
        default => throw new InvalidArgumentException('Invalid ID type')
    };
}
```

### Intersection Types
```php
<?php

interface Cacheable
{
    public function getCacheKey(): string;
}

interface Serializable
{
    public function serialize(): string;
}

function processData(Cacheable&Serializable $data): void
{
    $key = $data->getCacheKey();
    $serialized = $data->serialize();
    // Process data that is both cacheable and serializable
}
```

## Constructor Property Promotion

```php
<?php

// Old way
class User
{
    private string $name;
    private string $email;
    private int $age;
    
    public function __construct(string $name, string $email, int $age)
    {
        $this->name = $name;
        $this->email = $email;
        $this->age = $age;
    }
}

// New way with promotion
class User
{
    public function __construct(
        private string $name,
        private string $email,
        private int $age
    ) {}
    
    public function getName(): string
    {
        return $this->name;
    }
}
```

## Match Expression

```php
<?php

function getStatusMessage(UserStatus $status): string
{
    return match($status) {
        UserStatus::ACTIVE => 'User is active and can login',
        UserStatus::INACTIVE => 'User account is inactive',
        UserStatus::SUSPENDED => 'User account has been suspended',
        UserStatus::PENDING => 'User account is pending approval'
    };
}

function calculateDiscount(int $quantity): float
{
    return match(true) {
        $quantity >= 100 => 0.20,
        $quantity >= 50 => 0.15,
        $quantity >= 20 => 0.10,
        $quantity >= 10 => 0.05,
        default => 0.0
    };
}
```

## Named Arguments

```php
<?php

function createUser(
    string $name,
    string $email,
    int $age = 18,
    bool $isActive = true,
    array $roles = []
): User {
    return new User($name, $email, $age, $isActive, $roles);
}

// Usage with named arguments
$user = createUser(
    name: 'John Doe',
    email: 'john@example.com',
    roles: ['user', 'editor'],
    age: 25
);
```

## Nullsafe Operator

```php
<?php

class User
{
    public function __construct(
        public string $name,
        public ?Profile $profile = null
    ) {}
}

class Profile
{
    public function __construct(
        public ?Address $address = null
    ) {}
}

class Address
{
    public function __construct(
        public string $city
    ) {}
}

// Safe navigation
$city = $user?->profile?->address?->city ?? 'Unknown';

// Method chaining with nullsafe
$result = $user?->getProfile()?->getAddress()?->getCity();
```

## Fibers (Async Programming)

```php
<?php

function fetchData(string $url): string
{
    $fiber = new Fiber(function() use ($url) {
        // Simulate async operation
        Fiber::suspend();
        return file_get_contents($url);
    });
    
    $fiber->start();
    
    // Do other work while waiting
    sleep(1);
    
    return $fiber->resume();
}
```