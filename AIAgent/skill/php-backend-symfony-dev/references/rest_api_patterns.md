# REST API Patterns for PHP

## Laravel API Controller Pattern

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::paginate(15);
        return response()->json($users);
    }

    public function show(User $user): JsonResponse
    {
        return response()->json($user->load('posts'));
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());
        return response()->json($user, 201);
    }

    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $user->update($request->validated());
        return response()->json($user);
    }

    public function destroy(User $user): JsonResponse
    {
        $user->delete();
        return response()->json(null, 204);
    }
}
```

## Request Validation

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed'
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'This email is already taken.',
            'password.confirmed' => 'Password confirmation does not match.'
        ];
    }
}
```

## Middleware Patterns

### API Authentication
```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ApiAuth
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->bearerToken()) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Token validation logic
        return $next($request);
    }
}
```

### Rate Limiting
```php
// In RouteServiceProvider
Route::middleware(['api', 'throttle:60,1'])->group(function () {
    Route::apiResource('users', UserController::class);
});
```

## Resource Transformers

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
            'posts_count' => $this->whenLoaded('posts', fn() => $this->posts->count())
        ];
    }
}
```

## Error Handling

### Global Exception Handler
```php
<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class Handler extends ExceptionHandler
{
    public function render($request, Throwable $exception)
    {
        if ($request->expectsJson()) {
            if ($exception instanceof ValidationException) {
                return response()->json([
                    'error' => 'Validation failed',
                    'details' => $exception->errors()
                ], 422);
            }

            if ($exception instanceof NotFoundHttpException) {
                return response()->json(['error' => 'Resource not found'], 404);
            }

            return response()->json(['error' => 'Server error'], 500);
        }

        return parent::render($request, $exception);
    }
}
```

## Slim Framework Pattern

```php
<?php

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

$app = AppFactory::create();

$app->get('/api/users', function (Request $request, Response $response) {
    $users = User::all();
    $response->getBody()->write(json_encode($users));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->post('/api/users', function (Request $request, Response $response) {
    $data = json_decode($request->getBody(), true);
    
    // Validation
    if (empty($data['name']) || empty($data['email'])) {
        $response->getBody()->write(json_encode(['error' => 'Missing required fields']));
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
    }
    
    $user = User::create($data);
    $response->getBody()->write(json_encode($user));
    return $response->withStatus(201)->withHeader('Content-Type', 'application/json');
});
```

## Response Patterns

### Success Responses
```php
// Single resource
return response()->json($user);

// Collection with pagination
return response()->json([
    'data' => $users->items(),
    'meta' => [
        'current_page' => $users->currentPage(),
        'total' => $users->total()
    ]
]);

// Created resource
return response()->json($user, 201);
```

### Error Responses
```php
// Validation error
return response()->json([
    'error' => 'Validation failed',
    'details' => $validator->errors()
], 422);

// Not found
return response()->json(['error' => 'User not found'], 404);

// Server error
return response()->json(['error' => 'Internal server error'], 500);
```