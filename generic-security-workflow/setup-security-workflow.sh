#!/bin/bash

# Generic Security Workflow Setup Script
# Automatically configures security scanning for any project
# Version: 1.0

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_VERSION="1.0"
GITHUB_WORKFLOW_URL="https://raw.githubusercontent.com/security-workflows/templates/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

log_config() {
    echo -e "${CYAN}[CONFIG]${NC} $1"
}

# Show banner
show_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🔒 Generic Security Workflow Setup                       ║
║                                                              ║
║    Automated security scanning for any project              ║
║    Supports: Java, Python, Node.js, Go, .NET, and more     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Setup automated security scanning workflow for your project.

OPTIONS:
    -p, --project-type TYPE     Project type (auto|java|python|nodejs|go|dotnet)
    -t, --tools TOOLS          Security tools to enable (comma-separated)
    -c, --config FILE          Custom configuration file
    -s, --snyk-org ORG         Snyk organization ID
    -n, --notifications TYPE   Notification type (slack|email|teams|all)
    -e, --environment ENV      Environment (dev|staging|prod)
    -f, --force                Force overwrite existing files
    -d, --dry-run              Show what would be done without making changes
    -v, --verbose              Verbose output
    -h, --help                 Show this help message

EXAMPLES:
    $0                                          # Auto-detect and setup with defaults
    $0 --project-type java --tools trivy,snyk  # Java project with specific tools
    $0 --notifications slack --snyk-org myorg  # Enable Slack notifications
    $0 --dry-run                               # Preview changes without applying

SUPPORTED PROJECT TYPES:
    auto      - Auto-detect project type (default)
    java      - Java/Maven/Gradle projects
    python    - Python projects
    nodejs    - Node.js/JavaScript projects
    go        - Go projects
    dotnet    - .NET projects
    ruby      - Ruby projects
    php       - PHP projects

SUPPORTED TOOLS:
    trivy, snyk, owasp, codeql, semgrep, bandit, eslint, gosec, brakeman

EOF
}

# Parse command line arguments
parse_args() {
    PROJECT_TYPE="auto"
    TOOLS=""
    CONFIG_FILE=""
    SNYK_ORG=""
    NOTIFICATIONS=""
    ENVIRONMENT="dev"
    FORCE=false
    DRY_RUN=false
    VERBOSE=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--project-type)
                PROJECT_TYPE="$2"
                shift 2
                ;;
            -t|--tools)
                TOOLS="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -s|--snyk-org)
                SNYK_ORG="$2"
                shift 2
                ;;
            -n|--notifications)
                NOTIFICATIONS="$2"
                shift 2
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Detect project type
detect_project_type() {
    if [[ "$PROJECT_TYPE" != "auto" ]]; then
        echo "$PROJECT_TYPE"
        return
    fi

    local detected_type="unknown"

    # Check for Java
    if [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        detected_type="java"
    # Check for Python
    elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]] || [[ -f "Pipfile" ]]; then
        detected_type="python"
    # Check for Node.js
    elif [[ -f "package.json" ]]; then
        detected_type="nodejs"
    # Check for Go
    elif [[ -f "go.mod" ]] || [[ -f "go.sum" ]]; then
        detected_type="go"
    # Check for .NET
    elif [[ -f "*.csproj" ]] || [[ -f "*.sln" ]] || [[ -f "project.json" ]]; then
        detected_type="dotnet"
    # Check for Ruby
    elif [[ -f "Gemfile" ]] || [[ -f "*.gemspec" ]]; then
        detected_type="ruby"
    # Check for PHP
    elif [[ -f "composer.json" ]]; then
        detected_type="php"
    fi

    echo "$detected_type"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository. Please run this script from the root of your git repository."
        exit 1
    fi

    # Check for GitHub CLI (optional but recommended)
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI (gh) not found. Some features may not work."
        log_info "Install from: https://cli.github.com/"
    fi

    # Check for required directories
    if [[ ! -d ".git" ]]; then
        log_error "No .git directory found. Please run from repository root."
        exit 1
    fi

    log_success "Prerequisites check completed"
}

# Create directory structure
create_directories() {
    log_step "Creating directory structure..."

    local dirs=(
        ".github/workflows"
        "scripts"
        ".security"
    )

    for dir in "${dirs[@]}"; do
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Would create directory: $dir"
        else
            mkdir -p "$dir"
            log_config "Created directory: $dir"
        fi
    done
}

# Generate GitHub Actions workflow
generate_github_workflow() {
    local project_type="$1"
    local workflow_file=".github/workflows/security-scan.yml"

    log_step "Generating GitHub Actions workflow for $project_type..."

    if [[ -f "$workflow_file" && "$FORCE" != "true" ]]; then
        log_warning "Workflow file already exists: $workflow_file"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping workflow generation"
            return
        fi
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create workflow file: $workflow_file"
        return
    fi

    cat > "$workflow_file" << EOF
name: Security Scanning and Remediation

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:

env:
  SECURITY_SCAN_VERSION: '$WORKFLOW_VERSION'

jobs:
  detect-changes:
    name: Detect Changes
    runs-on: ubuntu-latest
    outputs:
      has-code-changes: \${{ steps.changes.outputs.code }}
      has-deps-changes: \${{ steps.changes.outputs.deps }}
      project-type: \${{ steps.detect.outputs.project-type }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Detect project type
        id: detect
        run: |
          PROJECT_TYPE="$project_type"
          echo "project-type=\$PROJECT_TYPE" >> \$GITHUB_OUTPUT
          echo "Detected project type: \$PROJECT_TYPE"

      - name: Detect changes
        id: changes
        uses: dorny/paths-filter@v2
        with:
          filters: |
            code:
              - 'src/**'
              - 'lib/**'
              - '**/*.py'
              - '**/*.js'
              - '**/*.java'
              - '**/*.go'
              - '**/*.cs'
            deps:
              - 'pom.xml'
              - 'package.json'
              - 'requirements.txt'
              - 'go.mod'
              - '*.csproj'
              - 'Gemfile'
              - 'composer.json'

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: detect-changes
    permissions:
      contents: read
      security-events: write
      pull-requests: write
    
    strategy:
      matrix:
        scanner: [trivy, snyk$(if [[ "$project_type" == "java" ]]; then echo ", owasp"; fi)$(if [[ "$project_type" == "python" ]]; then echo ", bandit"; fi)]
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Project Environment
        uses: ./.github/actions/setup-\${{ needs.detect-changes.outputs.project-type }}
        if: hashFiles('.github/actions/setup-\${{ needs.detect-changes.outputs.project-type }}/action.yml') != ''

$(generate_scanner_steps "$project_type")

      - name: Upload Security Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-results-\${{ matrix.scanner }}
          path: |
            security-results.json
            security-results.sarif
          retention-days: 30

  generate-report:
    name: Generate Security Report
    runs-on: ubuntu-latest
    needs: [detect-changes, security-scan]
    if: always()
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Download All Results
        uses: actions/download-artifact@v4
        with:
          path: security-results

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Generate Report
        run: |
          python scripts/generate-security-report.py \\
            --results-dir security-results \\
            --output security-dashboard.html \\
            --format html \\
            --theme dark

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: security-dashboard
          path: |
            security-dashboard.html
            security-summary.json

      - name: Deploy to GitHub Pages
        if: github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
          destination_dir: security-reports

  create-security-prs:
    name: Create Security PRs
    runs-on: ubuntu-latest
    needs: [detect-changes, security-scan]
    if: github.event_name != 'pull_request'
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          token: \${{ secrets.GITHUB_TOKEN }}

      - name: Download Security Results
        uses: actions/download-artifact@v4
        with:
          path: security-results

      - name: Create Security PRs
        run: |
          chmod +x scripts/create-security-pr.sh
          ./scripts/create-security-pr.sh --type all --scan-dir security-results
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}

  notify:
    name: Send Notifications
    runs-on: ubuntu-latest
    needs: [security-scan, generate-report]
    if: always()
    
    steps:
      - name: Send Slack Notification
        if: \${{ secrets.SLACK_WEBHOOK_URL }}
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              "text": "Security Scan Completed",
              "attachments": [
                {
                  "color": "\${{ needs.security-scan.result == 'success' && 'good' || 'danger' }}",
                  "fields": [
                    {
                      "title": "Repository",
                      "value": "\${{ github.repository }}",
                      "short": true
                    },
                    {
                      "title": "Status",
                      "value": "\${{ needs.security-scan.result }}",
                      "short": true
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: \${{ secrets.SLACK_WEBHOOK_URL }}
EOF

    log_success "Generated GitHub Actions workflow: $workflow_file"
}

# Generate scanner-specific steps
generate_scanner_steps() {
    local project_type="$1"
    
    cat << 'EOF'
      - name: Run Trivy Scanner
        if: matrix.scanner == 'trivy'
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'security-results.sarif'

      - name: Run Snyk Scanner
        if: matrix.scanner == 'snyk'
        uses: snyk/actions/setup@master

      - name: Snyk Scan
        if: matrix.scanner == 'snyk'
        run: |
          snyk test --json-file-output=security-results.json || true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
EOF

    if [[ "$project_type" == "java" ]]; then
        cat << 'EOF'

      - name: Setup Java
        if: matrix.scanner == 'owasp'
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Run OWASP Dependency Check
        if: matrix.scanner == 'owasp'
        run: |
          mvn org.owasp:dependency-check-maven:check \
            -DfailBuildOnCVSS=7 \
            -Dformat=JSON \
            -DprettyPrint=true
EOF
    fi

    if [[ "$project_type" == "python" ]]; then
        cat << 'EOF'

      - name: Setup Python
        if: matrix.scanner == 'bandit'
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Run Bandit
        if: matrix.scanner == 'bandit'
        run: |
          pip install bandit
          bandit -r . -f json -o security-results.json || true
EOF
    fi
}

# Generate tool configuration files
generate_tool_configs() {
    local project_type="$1"

    log_step "Generating tool configuration files..."

    # Trivy ignore file
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create .trivyignore"
    else
        cat > .trivyignore << 'EOF'
# Trivy ignore file for security scanning
# Add CVE IDs or file patterns to ignore

# Ignore test files
**/test/**
**/tests/**
**/*test*
**/*Test*

# Ignore documentation
**/docs/**
**/*.md
**/*.txt

# Ignore build artifacts
**/target/**
**/build/**
**/dist/**
**/node_modules/**

# Ignore configuration files
**/.github/**
**/scripts/**
**/*.yml
**/*.yaml
EOF
        log_config "Created .trivyignore"
    fi

    # Snyk configuration
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create .snyk"
    else
        cat > .snyk << EOF
# Snyk configuration file
version: v1.0.0

# Language settings
language-settings:
$(if [[ "$project_type" == "java" ]]; then
cat << 'EOF'
  java:
    excludeTestDependencies: true
EOF
elif [[ "$project_type" == "python" ]]; then
cat << 'EOF'
  python:
    excludeTestDependencies: true
EOF
elif [[ "$project_type" == "nodejs" ]]; then
cat << 'EOF'
  javascript:
    excludeDevDependencies: true
EOF
fi)

# Exclude paths
exclude:
  - 'test/**'
  - 'tests/**'
  - 'docs/**'
  - '**/*.md'
  - 'scripts/**'
EOF
        log_config "Created .snyk"
    fi

    # Project-specific configurations
    case "$project_type" in
        "java")
            generate_java_configs
            ;;
        "python")
            generate_python_configs
            ;;
        "nodejs")
            generate_nodejs_configs
            ;;
        "go")
            generate_go_configs
            ;;
        "dotnet")
            generate_dotnet_configs
            ;;
    esac
}

# Generate Java-specific configurations
generate_java_configs() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create owasp-suppressions.xml"
        return
    fi

    cat > owasp-suppressions.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    
    <!-- Suppress test dependencies -->
    <suppress>
        <notes><![CDATA[
        Test dependencies are not deployed to production
        ]]></notes>
        <gav regex="true">.*:.*:.*:test</gav>
        <cve>CVE-.*</cve>
    </suppress>
    
    <!-- Suppress development tools -->
    <suppress>
        <notes><![CDATA[
        Development tools are not part of runtime
        ]]></notes>
        <gav regex="true">org\.springframework\.boot:spring-boot-maven-plugin:.*</gav>
        <cve>CVE-.*</cve>
    </suppress>
    
</suppressions>
EOF
    log_config "Created owasp-suppressions.xml"
}

# Generate Python-specific configurations
generate_python_configs() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create .bandit"
        return
    fi

    cat > .bandit << 'EOF'
[bandit]
exclude_dirs = tests,test,docs
skips = B101,B601
EOF
    log_config "Created .bandit"
}

# Generate Node.js-specific configurations
generate_nodejs_configs() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create .eslintrc-security.js"
        return
    fi

    cat > .eslintrc-security.js << 'EOF'
module.exports = {
  plugins: ['security'],
  extends: ['plugin:security/recommended'],
  rules: {
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'error',
    'security/detect-unsafe-regex': 'error'
  }
};
EOF
    log_config "Created .eslintrc-security.js"
}

# Generate Go-specific configurations
generate_go_configs() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create .gosec.json"
        return
    fi

    cat > .gosec.json << 'EOF'
{
  "severity": "medium",
  "confidence": "medium",
  "exclude": ["G104", "G204"],
  "exclude-dir": ["test", "tests", "vendor"]
}
EOF
    log_config "Created .gosec.json"
}

# Generate .NET-specific configurations
generate_dotnet_configs() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create security-code-scan.config"
        return
    fi

    cat > security-code-scan.config << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <section name="SecurityCodeScanSettings" type="SecurityCodeScan.Config.ConfigurationSection, SecurityCodeScan" />
  </configSections>
  <SecurityCodeScanSettings>
    <AuditMode>true</AuditMode>
  </SecurityCodeScanSettings>
</configuration>
EOF
    log_config "Created security-code-scan.config"
}

# Generate scripts
generate_scripts() {
    log_step "Generating security scripts..."

    # Create scripts directory
    mkdir -p scripts

    # Generate report generator
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create scripts/generate-security-report.py"
    else
        cp "$SCRIPT_DIR/../task-mgmt/scripts/generate-security-report.py" scripts/ 2>/dev/null || {
            # Create a simplified version if source not available
            cat > scripts/generate-security-report.py << 'EOF'
#!/usr/bin/env python3
"""Generic Security Report Generator"""

import json
import argparse
import os
from pathlib import Path
from datetime import datetime

def main():
    parser = argparse.ArgumentParser(description='Generate security report')
    parser.add_argument('--results-dir', required=True, help='Directory with scan results')
    parser.add_argument('--output', default='security-report.html', help='Output file')
    parser.add_argument('--format', choices=['html', 'json'], default='html', help='Output format')
    parser.add_argument('--theme', choices=['light', 'dark'], default='dark', help='Report theme')
    
    args = parser.parse_args()
    
    # Simple implementation - extend as needed
    print(f"Generating {args.format} report from {args.results_dir}")
    print(f"Output: {args.output}")
    
    # Create basic HTML report
    if args.format == 'html':
        with open(args.output, 'w') as f:
            f.write(f"""
<!DOCTYPE html>
<html>
<head><title>Security Report</title></head>
<body>
<h1>Security Scan Report</h1>
<p>Generated: {datetime.now()}</p>
<p>Results directory: {args.results_dir}</p>
</body>
</html>
""")
    
    print(f"Report generated: {args.output}")

if __name__ == '__main__':
    main()
EOF
            chmod +x scripts/generate-security-report.py
        }
        log_config "Created scripts/generate-security-report.py"
    fi

    # Generate PR creation script
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create scripts/create-security-pr.sh"
    else
        cp "$SCRIPT_DIR/../task-mgmt/scripts/create-security-pr.sh" scripts/ 2>/dev/null || {
            # Create a simplified version if source not available
            cat > scripts/create-security-pr.sh << 'EOF'
#!/bin/bash
# Generic Security PR Creation Script

echo "Creating security PR..."
echo "Type: ${1:-all}"
echo "Scan directory: ${2:-security-results}"

# Add your PR creation logic here
# This is a placeholder - implement based on your needs

echo "Security PR creation completed"
EOF
            chmod +x scripts/create-security-pr.sh
        }
        log_config "Created scripts/create-security-pr.sh"
    fi
}

# Generate documentation
generate_documentation() {
    log_step "Generating documentation..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create SECURITY.md"
        return
    fi

    cat > SECURITY.md << EOF
# Security Policy

## Automated Security Scanning

This project uses automated security scanning with the following tools:

- **Trivy**: Vulnerability scanning for containers and filesystems
- **Snyk**: Comprehensive security analysis
$(if [[ "$PROJECT_TYPE" == "java" ]]; then echo "- **OWASP Dependency Check**: Java dependency vulnerability scanning"; fi)
$(if [[ "$PROJECT_TYPE" == "python" ]]; then echo "- **Bandit**: Python security linting"; fi)

## Workflow

The security workflow runs:
- On every push to main branches
- On pull requests
- Daily at 2 AM UTC
- Can be triggered manually

## Configuration

Security configuration is managed in:
- \`.trivyignore\` - Trivy exclusions
- \`.snyk\` - Snyk configuration
$(if [[ "$PROJECT_TYPE" == "java" ]]; then echo "- \`owasp-suppressions.xml\` - OWASP suppressions"; fi)

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
EOF

    log_config "Created SECURITY.md"
}

# Setup GitHub secrets
setup_github_secrets() {
    log_step "Setting up GitHub secrets..."

    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI not available. Please set up secrets manually:"
        echo ""
        echo "Required secrets:"
        echo "  SNYK_TOKEN - Your Snyk authentication token"
        if [[ "$NOTIFICATIONS" == *"slack"* ]]; then
            echo "  SLACK_WEBHOOK_URL - Slack webhook for notifications"
        fi
        if [[ -n "$SNYK_ORG" ]]; then
            echo "  SNYK_ORG - Your Snyk organization ID"
        fi
        echo ""
        echo "Set these in: GitHub Repository → Settings → Secrets and variables → Actions"
        return
    fi

    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        log_warning "GitHub CLI not authenticated. Please run: gh auth login"
        return
    fi

    log_info "GitHub CLI available. You can set secrets using:"
    echo ""
    echo "  gh secret set SNYK_TOKEN"
    if [[ "$NOTIFICATIONS" == *"slack"* ]]; then
        echo "  gh secret set SLACK_WEBHOOK_URL"
    fi
    if [[ -n "$SNYK_ORG" ]]; then
        echo "  gh secret set SNYK_ORG --body \"$SNYK_ORG\""
    fi
    echo ""
}

# Validate setup
validate_setup() {
    log_step "Validating setup..."

    local errors=0

    # Check required files
    local required_files=(
        ".github/workflows/security-scan.yml"
        ".trivyignore"
        ".snyk"
        "scripts/generate-security-report.py"
        "scripts/create-security-pr.sh"
        "SECURITY.md"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Missing required file: $file"
            ((errors++))
        fi
    done

    # Check script permissions
    if [[ -f "scripts/generate-security-report.py" && ! -x "scripts/generate-security-report.py" ]]; then
        log_error "Script not executable: scripts/generate-security-report.py"
        ((errors++))
    fi

    if [[ -f "scripts/create-security-pr.sh" && ! -x "scripts/create-security-pr.sh" ]]; then
        log_error "Script not executable: scripts/create-security-pr.sh"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        log_success "Setup validation passed"
        return 0
    else
        log_error "Setup validation failed with $errors errors"
        return 1
    fi
}

# Show summary
show_summary() {
    local project_type="$1"
    
    echo ""
    log_success "Security workflow setup completed!"
    echo ""
    echo "📋 Summary:"
    echo "  Project Type: $project_type"
    echo "  Tools Configured: trivy, snyk$(if [[ "$project_type" == "java" ]]; then echo ", owasp"; fi)$(if [[ "$project_type" == "python" ]]; then echo ", bandit"; fi)"
    echo "  Workflow File: .github/workflows/security-scan.yml"
    echo "  Configuration: .trivyignore, .snyk$(if [[ "$project_type" == "java" ]]; then echo ", owasp-suppressions.xml"; fi)"
    echo ""
    echo "🚀 Next Steps:"
    echo "  1. Set up required GitHub secrets (see output above)"
    echo "  2. Commit and push the changes"
    echo "  3. Trigger the workflow manually or wait for next push"
    echo "  4. Review generated security reports"
    echo ""
    echo "📚 Documentation:"
    echo "  - SECURITY.md - Security policy and procedures"
    echo "  - GitHub Actions workflow logs for detailed execution"
    echo ""
    echo "🔧 Customization:"
    echo "  - Edit .trivyignore to exclude false positives"
    echo "  - Modify .snyk for Snyk-specific configuration"
    echo "  - Update workflow file for additional tools or steps"
    echo ""
}

# Main function
main() {
    show_banner
    
    # Parse arguments
    parse_args "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Detect project type
    PROJECT_TYPE=$(detect_project_type)
    log_info "Detected project type: $PROJECT_TYPE"
    
    if [[ "$PROJECT_TYPE" == "unknown" ]]; then
        log_warning "Could not auto-detect project type. Using generic configuration."
        PROJECT_TYPE="generic"
    fi
    
    # Create directory structure
    create_directories
    
    # Generate workflow and configurations
    generate_github_workflow "$PROJECT_TYPE"
    generate_tool_configs "$PROJECT_TYPE"
    generate_scripts
    generate_documentation
    
    # Setup GitHub secrets
    setup_github_secrets
    
    # Validate setup
    if [[ "$DRY_RUN" != "true" ]]; then
        validate_setup
    fi
    
    # Show summary
    show_summary "$PROJECT_TYPE"
}

# Run main function with all arguments
main "$@"