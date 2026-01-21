# Security

## AWS
IAM:least privilege,no hardcode creds,use roles,MFA,rotate keys<90d|Secrets:Secrets Manager/Parameter Store,env vars,auto rotate|S3:encrypt(SSE-S3/KMS),block public,versioning,least privilege,logging|CFN:NoEcho params,ref secrets,termination protection,drift detection|Network:VPC private subnets,min SG ports,NACLs,Flow Logs,WAF|Lambda:env vars,KMS encrypt,VPC when needed,timeout/memory limits,X-Ray|Bedrock:IAM restrict,CloudWatch logs,input filter,guardrails,audit logs,HTTPS only,no PII logs,rate limit,VPC endpoints,monitor costs,validate I/O

## App
Input:validate/sanitize,parameterized queries,rate limit,validate uploads|Auth:strong passwords,JWT short expiry,refresh tokens,validate all requests,RBAC|Deps:update regularly,audit,pin versions,review advisories|Logging:log security events,no sensitive data,CloudWatch+retention,alarms,CloudTrail

## Docker
Images:official base,scan vulns,minimal(alpine/distroless),non-root,multi-stage|Runtime:limit resources,read-only fs,drop capabilities,secrets,update base

## Checklist
No hardcoded creds|Input validation|No info leak in errors|Auth/authz OK|Deps updated|No PII logs|HTTPS only|CORS OK
