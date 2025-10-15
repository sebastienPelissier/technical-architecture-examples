# Security Guidelines

## AWS Security Best Practices

### IAM
- Use least privilege principle for all IAM policies
- Never hardcode AWS credentials in code
- Use IAM roles for EC2, Lambda, and ECS instead of access keys
- Enable MFA for root and privileged accounts
- Rotate access keys regularly (max 90 days)

### Secrets Management
- Store secrets in AWS Secrets Manager or Parameter Store (SecureString)
- Never commit secrets to Git repositories
- Use environment variables for configuration
- Rotate database credentials automatically

### S3
- Enable bucket encryption by default (SSE-S3 or SSE-KMS)
- Block public access unless explicitly required
- Enable versioning for critical data
- Use bucket policies with least privilege
- Enable access logging

### CloudFormation
- Use `NoEcho: true` for sensitive parameters
- Reference secrets from Secrets Manager/Parameter Store
- Enable stack termination protection for production
- Use CloudFormation drift detection

### Network Security
- Use VPC with private subnets for backend resources
- Implement security groups with minimal required ports
- Use NACLs as additional layer
- Enable VPC Flow Logs
- Use AWS WAF for public-facing applications

### Lambda
- Use environment variables for configuration
- Encrypt environment variables with KMS
- Run in VPC when accessing private resources
- Set appropriate timeout and memory limits
- Enable X-Ray tracing for debugging

### Bedrock
- Use IAM policies to restrict model access per use case
- Enable CloudWatch Logs for model invocations
- Implement input filtering to prevent prompt injection
- Set guardrails to block harmful content
- Use model invocation logging for audit trails
- Encrypt data in transit (HTTPS only)
- Never log full prompts containing PII
- Implement rate limiting to prevent abuse
- Use VPC endpoints for private connectivity
- Monitor costs with CloudWatch metrics and budgets
- Validate and sanitize user inputs before sending to models
- Implement output validation to filter sensitive data

## Application Security

### Input Validation
- Validate and sanitize all user inputs
- Use parameterized queries to prevent SQL injection
- Implement rate limiting on APIs
- Validate file uploads (type, size, content)

### Authentication & Authorization
- Use strong password policies
- Implement JWT with short expiration times
- Use refresh tokens for long-lived sessions
- Validate tokens on every request
- Implement RBAC (Role-Based Access Control)

### Dependencies
- Regularly update dependencies
- Use `npm audit` / `composer audit` / `cargo audit`
- Pin dependency versions in production
- Review security advisories

### Logging & Monitoring
- Log security events (failed auth, access denied)
- Never log sensitive data (passwords, tokens, PII)
- Use CloudWatch Logs with retention policies
- Set up CloudWatch Alarms for suspicious activities
- Enable AWS CloudTrail for audit logs

## Docker Security

### Images
- Use official base images
- Scan images for vulnerabilities
- Use minimal base images (alpine, distroless)
- Don't run containers as root
- Use multi-stage builds to reduce attack surface

### Runtime
- Limit container resources (CPU, memory)
- Use read-only filesystems when possible
- Drop unnecessary capabilities
- Use Docker secrets for sensitive data
- Regularly update base images

## Code Review Checklist

- [ ] No hardcoded credentials or secrets
- [ ] Input validation implemented
- [ ] Error messages don't leak sensitive info
- [ ] Authentication/authorization properly implemented
- [ ] Dependencies are up to date
- [ ] Logging doesn't include PII
- [ ] HTTPS enforced for all communications
- [ ] CORS properly configured
