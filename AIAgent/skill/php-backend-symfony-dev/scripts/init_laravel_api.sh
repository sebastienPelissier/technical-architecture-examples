#!/bin/bash

# Laravel API Project Initialization Script
# Usage: bash init_laravel_api.sh <project-name> [port]

set -e

PROJECT_NAME=${1:-"laravel-api"}
PORT=${2:-8000}

echo "🚀 Initializing Laravel API project: $PROJECT_NAME"

# Create Laravel project
composer create-project laravel/laravel "$PROJECT_NAME" --prefer-dist

cd "$PROJECT_NAME"

# Install additional packages for API development
composer require laravel/sanctum
composer require --dev laravel/pint

# Configure for API-first development
php artisan install:api

# Create basic API structure
mkdir -p app/Http/Controllers/Api
mkdir -p app/Http/Requests
mkdir -p app/Http/Resources

# Create User API Controller
cat > app/Http/Controllers/Api/UserController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::paginate(15);
        return response()->json([
            'data' => UserResource::collection($users->items()),
            'meta' => [
                'current_page' => $users->currentPage(),
                'total' => $users->total(),
                'per_page' => $users->perPage()
            ]
        ]);
    }

    public function show(User $user): JsonResponse
    {
        return response()->json(new UserResource($user));
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());
        return response()->json(new UserResource($user), 201);
    }

    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $user->update($request->validated());
        return response()->json(new UserResource($user));
    }

    public function destroy(User $user): JsonResponse
    {
        $user->delete();
        return response()->json(null, 204);
    }
}
EOF

# Create User Request classes
cat > app/Http/Requests/StoreUserRequest.php << 'EOF'
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
}
EOF

cat > app/Http/Requests/UpdateUserRequest.php << 'EOF'
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'sometimes|string|max:255',
            'email' => [
                'sometimes',
                'email',
                Rule::unique('users')->ignore($this->user)
            ]
        ];
    }
}
EOF

# Create User Resource
cat > app/Http/Resources/UserResource.php << 'EOF'
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
            'updated_at' => $this->updated_at->toISOString()
        ];
    }
}
EOF

# Add API routes
cat > routes/api.php << 'EOF'
<?php

use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::apiResource('users', UserController::class);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [UserController::class, 'show']);
});
EOF

# Update .env for development
sed -i 's/APP_ENV=local/APP_ENV=development/' .env
sed -i "s/APP_URL=http:\/\/localhost/APP_URL=http:\/\/localhost:$PORT/" .env

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Create storage link
php artisan storage:link

echo "✅ Laravel API project '$PROJECT_NAME' created successfully!"
echo ""
echo "📁 Project structure:"
echo "   app/Http/Controllers/Api/ - API controllers"
echo "   app/Http/Requests/       - Form request validation"
echo "   app/Http/Resources/      - API resource transformers"
echo "   routes/api.php           - API routes"
echo ""
echo "🚀 To start development:"
echo "   cd $PROJECT_NAME"
echo "   php artisan serve --port=$PORT"
echo ""
echo "📖 API endpoints:"
echo "   GET    /api/users     - List users"
echo "   POST   /api/users     - Create user"
echo "   GET    /api/users/{id} - Show user"
echo "   PUT    /api/users/{id} - Update user"
echo "   DELETE /api/users/{id} - Delete user"