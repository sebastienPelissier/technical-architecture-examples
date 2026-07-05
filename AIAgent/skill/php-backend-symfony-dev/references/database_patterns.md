# Database Patterns for PHP

## Eloquent Model Patterns

### Basic Model with Relationships
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class User extends Model
{
    protected $fillable = ['name', 'email', 'password'];
    
    protected $hidden = ['password', 'remember_token'];
    
    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_active' => 'boolean'
    ];

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }
}

class Post extends Model
{
    protected $fillable = ['title', 'content', 'user_id'];
    
    protected $casts = [
        'published_at' => 'datetime'
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class);
    }
}
```

### Advanced Model Features
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = ['name', 'price', 'category_id'];
    
    protected $casts = [
        'price' => 'decimal:2',
        'metadata' => 'array',
        'is_featured' => 'boolean'
    ];

    // Accessors & Mutators
    public function getFormattedPriceAttribute(): string
    {
        return '$' . number_format($this->price, 2);
    }

    public function setNameAttribute(string $value): void
    {
        $this->attributes['name'] = ucfirst(strtolower($value));
    }

    // Scopes
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeInCategory($query, int $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }
}
```

## Migration Patterns

### Basic Migration
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();
            
            $table->index(['email', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

### Foreign Key Relationships
```php
<?php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('content');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            $table->index(['user_id', 'published_at']);
        });
    }
};
```

### Pivot Table Migration
```php
<?php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('post_tag', function (Blueprint $table) {
            $table->id();
            $table->foreignId('post_id')->constrained()->onDelete('cascade');
            $table->foreignId('tag_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            
            $table->unique(['post_id', 'tag_id']);
        });
    }
};
```

## Query Patterns

### Efficient Queries
```php
// Eager loading to prevent N+1
$users = User::with(['posts', 'profile'])->get();

// Conditional eager loading
$users = User::with(['posts' => function ($query) {
    $query->where('published_at', '>', now()->subDays(30));
}])->get();

// Chunking for large datasets
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});

// Lazy collections for memory efficiency
User::lazy()->each(function ($user) {
    // Process user
});
```

### Complex Queries
```php
// Subqueries
$users = User::whereHas('posts', function ($query) {
    $query->where('published_at', '>', now()->subDays(30));
})->get();

// Aggregates with relationships
$users = User::withCount(['posts', 'comments'])
    ->having('posts_count', '>', 5)
    ->get();

// Raw queries when needed
$results = DB::select('
    SELECT u.name, COUNT(p.id) as post_count 
    FROM users u 
    LEFT JOIN posts p ON u.id = p.user_id 
    GROUP BY u.id, u.name 
    HAVING post_count > ?
', [5]);
```

## Repository Pattern

```php
<?php

namespace App\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface UserRepositoryInterface
{
    public function findById(int $id): ?User;
    public function findByEmail(string $email): ?User;
    public function create(array $data): User;
    public function update(User $user, array $data): User;
    public function delete(User $user): bool;
}

class UserRepository implements UserRepositoryInterface
{
    public function findById(int $id): ?User
    {
        return User::find($id);
    }

    public function findByEmail(string $email): ?User
    {
        return User::where('email', $email)->first();
    }

    public function create(array $data): User
    {
        return User::create($data);
    }

    public function update(User $user, array $data): User
    {
        $user->update($data);
        return $user->fresh();
    }

    public function delete(User $user): bool
    {
        return $user->delete();
    }

    public function getActiveUsers(): Collection
    {
        return User::where('is_active', true)->get();
    }
}
```

## Database Transactions

```php
use Illuminate\Support\Facades\DB;

// Basic transaction
DB::transaction(function () {
    $user = User::create($userData);
    $profile = Profile::create(['user_id' => $user->id] + $profileData);
});

// Manual transaction control
DB::beginTransaction();
try {
    $user = User::create($userData);
    $profile = Profile::create(['user_id' => $user->id] + $profileData);
    DB::commit();
} catch (\Exception $e) {
    DB::rollback();
    throw $e;
}

// Transaction with return value
$user = DB::transaction(function () use ($userData, $profileData) {
    $user = User::create($userData);
    Profile::create(['user_id' => $user->id] + $profileData);
    return $user;
});
```

## Model Events and Observers

```php
<?php

namespace App\Observers;

use App\Models\User;

class UserObserver
{
    public function creating(User $user): void
    {
        $user->password = bcrypt($user->password);
    }

    public function created(User $user): void
    {
        // Send welcome email
        Mail::to($user)->send(new WelcomeEmail($user));
    }

    public function deleting(User $user): void
    {
        // Clean up related data
        $user->posts()->delete();
    }
}

// Register in AppServiceProvider
use App\Models\User;
use App\Observers\UserObserver;

public function boot(): void
{
    User::observe(UserObserver::class);
}
```