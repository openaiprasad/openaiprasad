# 🚀 Quick Start Guide

Get automated security scanning running in your project in **under 5 minutes**!

## 📦 One-Line Installation

```bash
curl -sSL https://raw.githubusercontent.com/security-workflows/generic/main/setup-security-workflow.sh | bash
```

## 🔧 Manual Installation

### Step 1: Download
```bash
git clone https://github.com/security-workflows/generic.git
cd generic
```

### Step 2: Setup
```bash
./setup-security-workflow.sh --project-type auto
```

### Step 3: Configure Secrets
Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:
- `SNYK_TOKEN` - Your Snyk authentication token (required)
- `SLACK_WEBHOOK_URL` - Slack webhook for notifications (optional)

### Step 4: Commit and Push
```bash
git add .
git commit -m "Add automated security scanning"
git push
```

## ✅ Verification

Run the validation script to ensure everything is set up correctly:

```bash
./validate-security-setup.sh
```

Expected output:
```
✅ Security setup validation PASSED
🚀 Your security workflow is properly configured!
```

## 🎯 What You Get

- **Automated vulnerability scanning** on every push and PR
- **Daily security scans** at 2 AM UTC
- **Beautiful HTML reports** with charts and trends
- **Automated PRs** for security fixes
- **Slack/Teams notifications** for critical issues
- **GitHub Security tab integration** with SARIF reports

## 📊 Supported Projects

| Language | Tools | Auto-Detection |
|----------|-------|----------------|
| Java | Trivy, Snyk, OWASP, SpotBugs | ✅ |
| Python | Trivy, Snyk, Bandit, Safety | ✅ |
| Node.js | Trivy, Snyk, ESLint, npm audit | ✅ |
| Go | Trivy, Snyk, Gosec | ✅ |
| .NET | Trivy, Snyk, Security Code Scan | ✅ |
| Ruby | Trivy, Snyk, Brakeman | ✅ |
| PHP | Trivy, Snyk, Psalm | ✅ |

## 🔍 Next Steps

1. **Review the first scan results** in GitHub Actions
2. **Check the security dashboard** (deployed to GitHub Pages)
3. **Customize the configuration** files as needed
4. **Set up team notifications** in Slack/Teams
5. **Review and merge** the automated security PRs

## 📚 Need Help?

- **Full Documentation**: [README.md](README.md)
- **Troubleshooting**: Run `./validate-security-setup.sh --verbose`
- **Issues**: [GitHub Issues](https://github.com/security-workflows/generic/issues)
- **Examples**: Check the `templates/` directory

---

**That's it! Your project now has enterprise-grade security automation.** 🎉