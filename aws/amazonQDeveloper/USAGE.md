# Amazon Q CLI - Usage Guide

## Setup

1. Install Amazon Q CLI
2. Configure your agent:
   ```bash
   cp cli-agent/default.json ~/.config/amazonq/agents/my-agent.json
   ```
3. Replace placeholders in the JSON file

## Starting a Session

```bash
q chat --agent my-agent
```

## Effective Prompts

### Code Generation
```
Generate a CloudFormation template for an S3 bucket following our security guidelines
```

### Code Review
```
Review this Lambda function for security issues based on our guidelines
```

### Infrastructure
```
Create a Docker Compose setup for a Node.js app with Redis following our conventions
```

## Best Practices

- Be specific about which guidelines to follow
- Reference examples when you want similar code
- Ask for explanations when learning new concepts
- Request code reviews before committing

## File Structure

```
.
├── cli-agent/
│   └── default.json          # Agent configuration
├── rules/
│   ├── coding-project.md     # Development principles
│   ├── security-guidelines.md # Security best practices
│   └── stack-convention.md   # Tech stack versions
└── examples/
    ├── cloudformation/       # CF templates
    └── docker/              # Docker Compose files
```

## Common Tasks

### Generate secure S3 bucket
```
Create a CloudFormation template for S3 with encryption and versioning
```

### Setup local environment
```
Generate a Docker Compose file for PHP 8.4 with Symfony 7.3 and PostgreSQL
```

### Review security
```
Check this code against our security guidelines, focus on AWS best practices
```

### Write documentation
```
Create a README for this Lambda function that uses Bedrock
```

## Tips

- Amazon Q has access to your rules and examples automatically
- It follows your coding principles (DRY, KISS, SOLID, CQRS)
- It uses your preferred versions (Node 24, PHP 8.4, etc.)
- All generated code respects security guidelines
