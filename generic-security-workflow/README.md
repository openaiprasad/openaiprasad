# 🔒 Generic Security Workflow

**Automated security scanning and remediation for any project**

[![Security Scan](https://github.com/your-org/your-repo/actions/workflows/security-scan.yml/badge.svg)](https://github.com/your-org/your-repo/actions/workflows/security-scan.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Quick Start

Get automated security scanning running in your project in under 5 minutes:

```bash
# 1. Download and run the setup script
curl -sSL https://raw.githubusercontent.com/security-workflows/generic/main/setup-security-workflow.sh | bash

# 2. Set up GitHub secrets (see below)

# 3. Commit and push
git add .
git commit -m "Add automated security scanning"
git push
```

That's it! Your security workflow is now active. 🎉

## 📋 What This Provides

### ✅ **Multi-Language Support**
- **Java** (Maven/Gradle)
- **Python** (pip/conda)
- **Node.js** (npm/yarn)
- **Go** (modules)
- **.NET** (NuGet)
- **Ruby** (Bundler)
- **PHP** (Composer)
- **Auto-detection** of project type

### ✅ **Comprehensive Security Scanning**
- **Trivy** - Universal vulnerability scanner
- **Snyk** - Commercial security analysis
- **OWASP Dependency Check** - Java dependencies
- **Bandit** - Python security linting
- **ESLint Security** - JavaScript security rules
- **Gosec** - Go security analyzer
- **And more...**

### ✅ **Automated Remediation**
- **Smart PR Creation** - Separate PRs for different fix types
- **Dependency Updates** - Automatic security patches
- **Code Fixes** - Safe automated code improvements
- **Test Integration** - Only apply fixes that pass tests

### ✅ **Rich Reporting**
- **HTML Dashboards** - Beautiful security reports
- **GitHub Security Tab** - SARIF integration
- **JSON Summaries** - Machine-readable results
- **Trend Analysis** - Track security improvements

### ✅ **Team Collaboration**
- **Slack/Teams Notifications** - Real-time alerts
- **Email Reports** - Weekly summaries
- **GitHub Issues** - Automatic ticket creation
- **Review Workflows** - Security team approval

## 🛠️ Installation Methods

### Method 1: Automated Setup (Recommended)

```bash
# Basic setup with auto-detection
curl -sSL https://raw.githubusercontent.com/security-workflows/generic/main/setup-security-workflow.sh | bash

# Advanced setup with options
curl -sSL https://raw.githubusercontent.com/security-workflows/generic/main/setup-security-workflow.sh | bash -s -- \
  --project-type java \
  --tools trivy,snyk,owasp \
  --notifications slack \
  --snyk-org your-org-id
```

### Method 2: Manual Setup

1. **Download the files:**
   ```bash
   wget https://github.com/security-workflows/generic/archive/main.zip
   unzip main.zip
   cd generic-security-workflow-main
   ```

2. **Run the setup script:**
   ```bash
   ./setup-security-workflow.sh --project-type auto
   ```

3. **Customize as needed** (see Configuration section)

### Method 3: Copy and Customize

1. **Copy the workflow file:**
   ```bash
   mkdir -p .github/workflows
   curl -o .github/workflows/security-scan.yml \
     https://raw.githubusercontent.com/security-workflows/generic/main/templates/security-scan.yml
   ```

2. **Copy configuration files:**
   ```bash
   curl -o .trivyignore https://raw.githubusercontent.com/security-workflows/generic/main/templates/.trivyignore
   curl -o .snyk https://raw.githubusercontent.com/security-workflows/generic/main/templates/.snyk
   ```

3. **Customize for your project** (see examples below)

## ⚙️ Configuration

### Required GitHub Secrets

Set these in your repository: **Settings → Secrets and variables → Actions**

| Secret | Required | Description |
|--------|----------|-------------|
| `SNYK_TOKEN` | Yes | Your Snyk authentication token |
| `SLACK_WEBHOOK_URL` | No | Slack webhook for notifications |
| `SNYK_ORG` | No | Your Snyk organization ID |

### Optional Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SECURITY_SCAN_VERSION` | `1.0` | Workflow version |
| `SCAN_SEVERITY_THRESHOLD` | `medium` | Minimum severity to report |
| `AUTO_FIX_ENABLED` | `true` | Enable automated fixes |
| `NOTIFICATION_LEVEL` | `standard` | Notification verbosity |

### Project-Specific Configuration

#### Java Projects
```yaml
# pom.xml - Add OWASP plugin
<plugin>
  <groupId>org.owasp</groupId>
  <artifactId>dependency-check-maven</artifactId>
  <version>8.4.0</version>
</plugin>
```

#### Python Projects
```bash
# requirements-security.txt
bandit[toml]
safety
pip-audit
```

#### Node.js Projects
```json
// package.json
{
  "devDependencies": {
    "eslint-plugin-security": "^1.7.1",
    "retire": "^4.0.0"
  }
}
```

## 🎯 Usage Examples

### Basic Usage

Once set up, the workflow runs automatically on:
- **Push** to main branches
- **Pull requests**
- **Daily schedule** (2 AM UTC)
- **Manual trigger**

### Manual Execution

```bash
# Trigger via GitHub CLI
gh workflow run security-scan.yml

# Trigger with parameters
gh workflow run security-scan.yml \
  -f scan_type=full \
  -f severity_threshold=high
```

### Local Testing

```bash
# Run security validation locally
./scripts/security-validation.sh

# Generate reports locally
python scripts/generate-security-report.py \
  --results-dir ./security-results \
  --output security-report.html \
  --theme dark
```

## 📊 Understanding Results

### Security Dashboard

The workflow generates a comprehensive HTML dashboard with:

- **Executive Summary** - High-level security metrics
- **Vulnerability Breakdown** - By severity and tool
- **Trend Analysis** - Security improvements over time
- **Detailed Findings** - Complete vulnerability listings

### GitHub Security Tab

Results are automatically uploaded to GitHub's Security tab in SARIF format, providing:

- **Code Scanning Alerts** - Inline code annotations
- **Dependency Alerts** - Vulnerable dependency notifications
- **Secret Scanning** - Exposed credentials detection

### Automated Pull Requests

The workflow creates intelligent PRs for:

- **Dependency Updates** - Security patches for libraries
- **Code Fixes** - Safe automated code improvements
- **Configuration Updates** - Security hardening changes

## 🔧 Customization

### Adding Custom Scanners

1. **Update the workflow:**
   ```yaml
   - name: Run Custom Scanner
     run: |
       custom-scanner --output results.json
   ```

2. **Update the report generator:**
   ```python
   def parse_custom_results(file_path):
       # Add parsing logic
       pass
   ```

### Modifying Scan Scope

Edit configuration files to customize what gets scanned:

```bash
# .trivyignore - Exclude files/directories from Trivy
**/test/**
**/docs/**

# .snyk - Snyk-specific exclusions
exclude:
  - 'test/**'
  - 'docs/**'
```

### Custom Notification Channels

```yaml
# Add to workflow
- name: Custom Notification
  run: |
    curl -X POST $CUSTOM_WEBHOOK \
      -H "Content-Type: application/json" \
      -d '{"message": "Security scan completed"}'
```

### Environment-Specific Configuration

```yaml
# Different settings per environment
environments:
  development:
    scan_frequency: on_push
    auto_fix: true
    
  production:
    scan_frequency: continuous
    auto_fix: false
    fail_on_high: true
```

## 🏗️ Project Templates

### Java Spring Boot

```bash
./setup-security-workflow.sh \
  --project-type java \
  --tools trivy,snyk,owasp \
  --notifications slack
```

**Includes:**
- Maven OWASP plugin configuration
- Spring Security scanning rules
- JPA security checks
- Container scanning for Docker images

### Python Django/Flask

```bash
./setup-security-workflow.sh \
  --project-type python \
  --tools trivy,snyk,bandit \
  --notifications email
```

**Includes:**
- Bandit security linting
- pip-audit dependency scanning
- Django-specific security rules
- Virtual environment handling

### Node.js Express

```bash
./setup-security-workflow.sh \
  --project-type nodejs \
  --tools trivy,snyk,eslint \
  --notifications teams
```

**Includes:**
- ESLint security plugin
- npm audit integration
- Retire.js for outdated libraries
- Package-lock.json scanning

### Go Applications

```bash
./setup-security-workflow.sh \
  --project-type go \
  --tools trivy,snyk,gosec \
  --notifications slack
```

**Includes:**
- Gosec static analysis
- Go vulnerability database
- Module dependency scanning
- Binary analysis

### .NET Applications

```bash
./setup-security-workflow.sh \
  --project-type dotnet \
  --tools trivy,snyk,security-code-scan \
  --notifications email
```

**Includes:**
- Security Code Scan analyzer
- NuGet package scanning
- .NET security rules
- Assembly analysis

## 📈 Monitoring and Metrics

### Key Performance Indicators

Track these metrics to measure security improvement:

- **Mean Time to Detection (MTTD)** - How quickly vulnerabilities are found
- **Mean Time to Resolution (MTTR)** - How quickly fixes are applied
- **Vulnerability Density** - Vulnerabilities per lines of code
- **Security Debt** - Accumulated unfixed vulnerabilities

### Dashboard Metrics

The security dashboard automatically tracks:

- **Vulnerability Trends** - Historical vulnerability counts
- **Fix Rates** - Percentage of vulnerabilities fixed
- **Tool Effectiveness** - Which tools find the most issues
- **Team Performance** - Response times and fix rates

### Alerting Thresholds

Configure alerts for:

```yaml
policies:
  vulnerability_thresholds:
    critical: 0      # Immediate alert
    high: 5          # Daily alert
    medium: 20       # Weekly alert
    low: 100         # Monthly alert
```

## 🛡️ Security Best Practices

### Secrets Management

- ✅ **Use GitHub Secrets** for sensitive tokens
- ✅ **Rotate tokens regularly** (quarterly)
- ✅ **Limit token permissions** to minimum required
- ❌ **Never commit secrets** to version control

### Workflow Security

- ✅ **Pin action versions** to specific commits
- ✅ **Review third-party actions** before use
- ✅ **Limit workflow permissions** to minimum required
- ✅ **Use branch protection rules** for security workflows

### Vulnerability Management

- ✅ **Prioritize critical vulnerabilities** (fix within 24 hours)
- ✅ **Review all automated fixes** before merging
- ✅ **Maintain security documentation** up to date
- ✅ **Regular security training** for development team

## 🔍 Troubleshooting

### Common Issues

#### Workflow Fails to Run

**Problem:** Workflow doesn't trigger or fails immediately

**Solutions:**
```bash
# Check workflow syntax
yamllint .github/workflows/security-scan.yml

# Verify secrets are set
gh secret list

# Check repository permissions
gh api repos/:owner/:repo --jq .permissions
```

#### Snyk Authentication Fails

**Problem:** `Snyk token is invalid` error

**Solutions:**
```bash
# Verify token is correct
snyk auth

# Check token permissions
snyk test --dry-run

# Update secret in GitHub
gh secret set SNYK_TOKEN
```

#### Too Many False Positives

**Problem:** Scan reports irrelevant vulnerabilities

**Solutions:**
```bash
# Update .trivyignore
echo "CVE-2023-12345" >> .trivyignore

# Update .snyk
snyk ignore --id=SNYK-JS-LODASH-567746

# Adjust severity thresholds
# Edit security-config.yml
```

#### Reports Not Generated

**Problem:** Security dashboard is empty or missing

**Solutions:**
```bash
# Check Python dependencies
pip install -r requirements.txt

# Verify scan results exist
ls -la security-results/

# Run report generator manually
python scripts/generate-security-report.py --help
```

### Debug Mode

Enable verbose logging:

```bash
# Set debug environment variable
export DEBUG=true

# Run with verbose output
./setup-security-workflow.sh --verbose

# Check workflow logs
gh run list --workflow=security-scan.yml
gh run view <run-id> --log
```

### Getting Help

1. **Check Documentation** - Review this README and linked guides
2. **Search Issues** - Look for similar problems in GitHub issues
3. **Run Validation** - Use built-in validation tools
4. **Contact Support** - Reach out to the security team

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup

```bash
# Clone the repository
git clone https://github.com/security-workflows/generic.git
cd generic

# Install development dependencies
pip install -r requirements-dev.txt

# Run tests
pytest tests/

# Run linting
flake8 scripts/
shellcheck *.sh
```

### Adding New Language Support

1. **Create language detector:**
   ```bash
   # Add to detect_project_type() function
   elif [[ -f "Cargo.toml" ]]; then
       detected_type="rust"
   ```

2. **Add workflow steps:**
   ```yaml
   - name: Setup Rust
     if: matrix.project-type == 'rust'
     uses: actions-rs/toolchain@v1
   ```

3. **Create configuration template:**
   ```bash
   # Add generate_rust_configs() function
   ```

4. **Update documentation:**
   ```markdown
   ### Rust Projects
   - Cargo audit for dependency scanning
   - Clippy for security linting
   ```

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/new-language`
3. **Make your changes** and add tests
4. **Run the test suite:** `pytest`
5. **Submit a pull request** with a clear description

## 📚 Additional Resources

### Documentation
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Snyk Documentation](https://docs.snyk.io/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)

### Security Frameworks
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Controls](https://www.cisecurity.org/controls/)

### Community
- [DevSecOps Community](https://github.com/devsecops)
- [Security Champions](https://github.com/security-champions)
- [OWASP Community](https://owasp.org/membership/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Aqua Security** for Trivy
- **Snyk** for comprehensive security analysis
- **OWASP** for dependency check tools
- **GitHub** for Actions platform
- **Security community** for best practices and feedback

---

## 📞 Support

- **Documentation**: Check this README and linked guides
- **Issues**: [GitHub Issues](https://github.com/security-workflows/generic/issues)
- **Discussions**: [GitHub Discussions](https://github.com/security-workflows/generic/discussions)
- **Security**: security@security-workflows.org

---

**Made with ❤️ by the Security Workflows team**

*Helping developers build secure software, one commit at a time.*