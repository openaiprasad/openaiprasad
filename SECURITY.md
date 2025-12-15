# Security Policy

## Automated Security Scanning

This project uses automated security scanning with the following tools:

- **Trivy**: Vulnerability scanning for containers and filesystems
- **Snyk**: Comprehensive security analysis
- **OWASP Dependency Check**: Java dependency vulnerability scanning


## Workflow

The security workflow runs:
- On every push to main branches
- On pull requests
- Daily at 2 AM UTC
- Can be triggered manually

## Configuration

Security configuration is managed in:
- `.trivyignore` - Trivy exclusions
- `.snyk` - Snyk configuration
- `owasp-suppressions.xml` - OWASP suppressions

## Reporting

Security reports are automatically generated and available:
- As GitHub Actions artifacts
- Deployed to GitHub Pages (if enabled)
- In SARIF format for GitHub Security tab

## Vulnerability Response

1. Critical vulnerabilities trigger immediate notifications
2. Automated PRs are created for fixable issues
3. Security team reviews and approves fixes
4. Regular security metrics are tracked

## Contact

For security issues, contact: security@company.com
