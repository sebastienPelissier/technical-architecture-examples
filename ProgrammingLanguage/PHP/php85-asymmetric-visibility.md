# Asymmetric Visibility en PHP 8.4/8.5

Permet de déclarer une visibilité différente pour la **lecture** et l'**écriture** d'une propriété.

```php
public private(set) string $name;
// ↑ lecture  ↑ écriture
```

> **Règle** : la visibilité en lecture doit toujours être **supérieure ou égale** à celle en écriture.  
> `public private(set)` ✅ — `private public(set)` ❌

---

## Combinaisons disponibles

| Syntaxe | Lecture | Écriture |
|---|---|---|
| `public private(set)` | partout | classe uniquement |
| `public protected(set)` | partout | classe + classes filles |
| `protected private(set)` | classe + classes filles | classe uniquement |

---

## Propriétés d'instance (PHP 8.4)

### Entité Doctrine

Les entités ont besoin d'être modifiées par Doctrine (hydratation) et par les setters métier,
mais leurs propriétés ne doivent pas être écrasées de l'extérieur.

```php
#[ORM\Entity]
class Game
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    public private(set) int $id;

    #[ORM\Column(length: 255)]
    public private(set) string $entitled;

    #[ORM\Column(length: 50)]
    public private(set) string $productId;

    #[ORM\Column]
    public private(set) \DateTimeImmutable $createdAt;

    // Doctrine peut hydrater via la réflexion (ignore la visibilité set)
    // Les setters métier restent internes à l'entité

    public function rename(string $entitled): void
    {
        $this->entitled = $entitled; // OK : écriture interne
    }
}

// Utilisation
$game = $repository->find(1);
echo $game->entitled;       // OK : lecture publique
$game->entitled = 'Halo';  // Erreur fatale
$game->rename('Halo');      // OK : via méthode interne
```

---

### Modèle (Value Object)

Les modèles sont souvent immuables. L'asymmetric visibility permet des méthodes `with*`
sans exposer l'écriture directe.

```php
final class NewGameContentInformationModel
{
    public function __construct(
        public private(set) string $entitled,
        public private(set) string $productId,
        public private(set) string $releaseDate,
        public private(set) int    $totalAchievement,
        public private(set) int    $totalGamescore,
    ) {}

    // Modification via wither — retourne un nouvel objet
    public function withEntitled(string $entitled): static
    {
        $clone = clone $this;
        $clone->entitled = $entitled; // OK : écriture interne
        return $clone;
    }

    public function withReleaseDate(string $releaseDate): static
    {
        $clone = clone $this;
        $clone->releaseDate = $releaseDate;
        return $clone;
    }
}

// Utilisation
$model = new NewGameContentInformationModel('Halo', 'ABC123', '01/01/2025', 50, 1000);
echo $model->entitled;          // OK : lecture publique

$updated = $model->withEntitled('Halo Infinite');
echo $updated->entitled;        // "Halo Infinite"
echo $model->entitled;          // "Halo" — original inchangé

$model->entitled = 'Forbidden'; // Erreur fatale
```

> **`readonly` vs `public private(set)`**
>
> | | `readonly` | `public private(set)` |
> |---|---|---|
> | Modification après construction | ❌ impossible | ✅ en interne |
> | Pattern `with*` (clone + modify) | ❌ | ✅ |
> | Objet totalement immuable | ✅ idéal | possible mais over-engineering |
>
> → Utilise `readonly` si l'objet ne change jamais après construction.  
> → Utilise `public private(set)` si tu as besoin de méthodes `with*` ou de logique interne.

---

### DTO

Les DTOs servent souvent à transporter des données mutables (form, API input).
L'asymmetric visibility permet de contrôler qui peut modifier quoi.

```php
final class NewGameDTO
{
    // Écrit une seule fois à la construction, jamais modifiable ensuite
    public private(set) string $productId;

    // Modifiable par le service qui enrichit le DTO
    public protected(set) string $entitled;
    public protected(set) string $releaseDate;

    // Calculé en interne uniquement
    public private(set) int $totalGamescore = 0;
    public private(set) int $totalAchievement = 0;

    public function __construct(string $productId)
    {
        $this->productId = $productId;
    }

    public function addAchievement(int $gamescore): void
    {
        $this->totalGamescore += $gamescore;   // OK : interne
        $this->totalAchievement++;             // OK : interne
    }
}

// Utilisation
$dto = new NewGameDTO('ABC123');
$dto->addAchievement(50);

echo $dto->productId;          // OK
echo $dto->totalGamescore;     // 50

$dto->productId = 'XYZ';      // Erreur fatale : private(set)
$dto->totalGamescore = 999;    // Erreur fatale : private(set)
```

---

## Propriétés statiques (PHP 8.5)

### Modèle avec registre interne

```php
final class GameTypeRegistry
{
    // Lecture publique, écriture réservée à la classe
    public private(set) static array $types = [];

    public static function register(string $type): void
    {
        self::$types[] = $type; // OK : interne
    }
}

GameTypeRegistry::register('Game');
GameTypeRegistry::register('DLC');

print_r(GameTypeRegistry::$types); // ['Game', 'DLC']

GameTypeRegistry::$types = [];    // Erreur fatale
```

---

### Entité avec compteur de version (optimistic locking)

```php
#[ORM\Entity]
class Game
{
    #[ORM\Column]
    #[ORM\Version]
    public private(set) static int $schemaVersion = 2;

    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    public private(set) int $id;

    #[ORM\Column(length: 255)]
    public private(set) string $entitled;
}

echo Game::$schemaVersion;      // 2
Game::$schemaVersion = 3;       // Erreur fatale
```

---

### Singleton (cas classique)

```php
final class Config
{
    // Avant PHP 8.5 : private static → inaccessible de l'extérieur
    // Maintenant    : lisible partout, modifiable uniquement en interne
    public private(set) static ?self $instance = null;

    private function __construct(
        public private(set) string $env,
    ) {}

    public static function getInstance(): static
    {
        return self::$instance ??= new self($_ENV['APP_ENV'] ?? 'prod');
    }

    public static function reset(): void
    {
        self::$instance = null; // OK : interne (tests, etc.)
    }
}

$config = Config::getInstance();
echo $config->env;               // "prod"
echo Config::$instance?->env;   // "prod" — lecture publique possible

Config::$instance = null;        // Erreur fatale
```

---

## Résumé

| Contexte | Recommandation |
|---|---|
| Entité Doctrine — ID, timestamps | `public private(set)` — Doctrine hydrate via réflexion |
| Entité Doctrine — champs métier | `public private(set)` + méthodes métier internes |
| Modèle immuable (value object) | `readonly` en premier choix |
| Modèle avec `with*` | `public private(set)` |
| DTO mutable avec enrichissement | `public protected(set)` pour les classes filles, `public private(set)` pour le reste |
| Singleton / registre statique | `public private(set) static` (PHP 8.5) |
| Compteur / version statique | `public private(set) static` (PHP 8.5) |
