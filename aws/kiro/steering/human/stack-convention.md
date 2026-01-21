# Stack Convention

## Languages & Frameworks

Minimum required versions (uncomment as needed):

<!-- - Node.js: 24.0 -->
<!-- - TypeScript: 5.6 -->
<!-- - PHP: 8.4 -->
<!-- - Symfony: 7.3 -->
<!-- - Rust: 1.90.0 -->

## AWS

- Prefer AWS CLI for all operations
- Use CloudFormation/CDK for infrastructure as code

## Docker Compose

- Version: Docker Compose v2 (2.40+)
- Syntax: use `docker compose` (no dash)
- Common commands:
  ```bash
  docker compose up -d
  docker compose down
  docker compose logs -f
  ```

### Documentation
- https://docs.docker.com/compose/releases/release-notes