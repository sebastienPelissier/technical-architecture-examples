# Git Commit Conventions

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Commit Types

- `feat`: New feature or article
- `fix`: Bug fix or content correction
- `docs`: Documentation updates
- `style`: Formatting, missing semicolons, etc (no code change)
- `refactor`: Code restructuring without behavior change
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, tooling
- `ci`: CI/CD configuration changes

## Scopes

- `blog`: Blog articles
- `infra`: Infrastructure code (CloudFormation, Docker)
- `lambda`: Lambda functions
- `api`: API implementations
- `config`: Configuration files
- `deps`: Dependencies updates

## Rules

- Always write in English
- Use imperative mood ("add" not "added")
- No period at the end of description
- Keep description under 72 characters
- Use body for detailed explanations
- Reference issues in footer: `Fixes #123`

## Examples

### Blog Articles
```bash
git commit -m "feat(blog): add Bedrock integration guide with Lambda"
git commit -m "fix(blog): correct CloudFormation syntax in S3 article"
git commit -m "docs(blog): update Docker Compose best practices"
```

### Infrastructure
```bash
git commit -m "feat(infra): add CloudFormation template for secure S3"
git commit -m "refactor(infra): simplify Lambda IAM role configuration"
git commit -m "chore(deps): update Node.js to version 24"
```

### Code
```bash
git commit -m "feat(lambda): implement Bedrock streaming response"
git commit -m "fix(api): handle rate limiting errors properly"
git commit -m "perf(lambda): reduce cold start time by 40%"
```

### With Body
```bash
git commit -m "feat(blog): add comprehensive AWS security guide

- Cover IAM best practices
- Include S3 encryption examples
- Add Lambda security checklist
- Document Bedrock guardrails

Fixes #42"
```

## Anti-patterns

❌ `git commit -m "update"`
❌ `git commit -m "fixed bug"`
❌ `git commit -m "WIP"`
❌ `git commit -m "feat(blog) added new article."`

✅ `git commit -m "feat(blog): add Docker security best practices"`
✅ `git commit -m "fix(lambda): resolve timeout in Bedrock invocation"`

