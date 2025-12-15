#!/bin/bash

# Generic Security Setup Validation Script
# Validates security workflow configuration across different project types
# Version: 1.0

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATION_VERSION="1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNING_CHECKS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_CHECKS++))
}

log_check() {
    echo -e "${CYAN}[CHECK]${NC} $1"
    ((TOTAL_CHECKS++))
}

# Show banner
show_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🔍 Security Setup Validation                             ║
║                                                              ║
║    Validates security workflow configuration                 ║
║    Supports: Java, Python, Node.js, Go, .NET, and more     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Validate security workflow setup for your project.

OPTIONS:
    -p, --project-type TYPE     Project type to validate (auto|java|python|nodejs|go|dotnet)
    -v, --verbose               Verbose output
    -f, --fix                   Attempt to fix issues automatically
    -r, --report FILE           Generate validation report
    -h, --help                  Show this help message

EXAMPLES:
    $0                          # Auto-detect and validate
    $0 --project-type java      # Validate Java project
    $0 --verbose --fix          # Verbose mode with auto-fix
    $0 --report validation.json # Generate JSON report

EOF
}

# Parse command line arguments
parse_args() {
    PROJECT_TYPE="auto"
    VERBOSE=false
    AUTO_FIX=false
    REPORT_FILE=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--project-type)
                PROJECT_TYPE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--fix)
                AUTO_FIX=true
                shift
                ;;
            -r|--report)
                REPORT_FILE="$2"
                shift 2
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

# Check if we're in a git repository
check_git_repository() {
    log_check "Checking git repository"
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        return 1
    fi
    
    log_success "Git repository detected"
    return 0
}

# Check GitHub Actions workflow
check_github_workflow() {
    log_check "Checking GitHub Actions workflow"
    
    local workflow_files=(
        ".github/workflows/security-scan.yml"
        ".github/workflows/security.yml"
        ".github/workflows/security-scanning.yml"
    )
    
    local found=false
    for file in "${workflow_files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "Found workflow file: $file"
            found=true
            
            # Validate workflow syntax
            if command -v yamllint &> /dev/null; then
                if yamllint "$file" &> /dev/null; then
                    log_success "Workflow YAML syntax is valid"
                else
                    log_error "Workflow YAML syntax errors found"
                    if [[ "$VERBOSE" == "true" ]]; then
                        yamllint "$file"
                    fi
                fi
            else
                log_warning "yamllint not available, skipping YAML validation"
            fi
            break
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        log_error "No GitHub Actions security workflow found"
        if [[ "$AUTO_FIX" == "true" ]]; then
            log_info "Auto-fix: Creating basic security workflow"
            mkdir -p .github/workflows
            cp "$SCRIPT_DIR/templates/security-scan.yml" .github/workflows/security-scan.yml 2>/dev/null || {
                log_warning "Template not found, creating basic workflow"
                create_basic_workflow
            }
        fi
        return 1
    fi
    
    return 0
}

# Create basic workflow if template not available
create_basic_workflow() {
    cat > .github/workflows/security-scan.yml << 'EOF'
name: Security Scan

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  schedule:
    - cron: '0 2 * * *'

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
EOF
    log_success "Created basic security workflow"
}

# Check security tool configurations
check_security_configs() {
    log_check "Checking security tool configurations"
    
    local configs_found=0
    
    # Check Trivy ignore file
    if [[ -f ".trivyignore" ]]; then
        log_success "Found .trivyignore configuration"
        ((configs_found++))
    else
        log_warning "Missing .trivyignore file"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_trivyignore
        fi
    fi
    
    # Check Snyk configuration
    if [[ -f ".snyk" ]]; then
        log_success "Found .snyk configuration"
        ((configs_found++))
    else
        log_warning "Missing .snyk file"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_snyk_config
        fi
    fi
    
    # Project-specific configurations
    case "$PROJECT_TYPE" in
        "java")
            check_java_configs
            ;;
        "python")
            check_python_configs
            ;;
        "nodejs")
            check_nodejs_configs
            ;;
        "go")
            check_go_configs
            ;;
        "dotnet")
            check_dotnet_configs
            ;;
    esac
    
    if [[ $configs_found -eq 0 ]]; then
        log_error "No security tool configurations found"
        return 1
    fi
    
    return 0
}

# Check Java-specific configurations
check_java_configs() {
    if [[ -f "owasp-suppressions.xml" ]]; then
        log_success "Found OWASP suppressions file"
    else
        log_warning "Missing owasp-suppressions.xml"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_owasp_suppressions
        fi
    fi
    
    # Check for SpotBugs configuration
    if [[ -f "spotbugs-security.xml" ]]; then
        log_success "Found SpotBugs security configuration"
    else
        log_warning "Missing spotbugs-security.xml"
    fi
}

# Check Python-specific configurations
check_python_configs() {
    if [[ -f ".bandit" ]]; then
        log_success "Found Bandit configuration"
    else
        log_warning "Missing .bandit configuration"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_bandit_config
        fi
    fi
}

# Check Node.js-specific configurations
check_nodejs_configs() {
    if [[ -f ".eslintrc-security.js" ]]; then
        log_success "Found ESLint security configuration"
    else
        log_warning "Missing .eslintrc-security.js"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_eslint_security_config
        fi
    fi
}

# Check Go-specific configurations
check_go_configs() {
    if [[ -f ".gosec.json" ]]; then
        log_success "Found Gosec configuration"
    else
        log_warning "Missing .gosec.json"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_gosec_config
        fi
    fi
}

# Check .NET-specific configurations
check_dotnet_configs() {
    if [[ -f "security-code-scan.config" ]]; then
        log_success "Found Security Code Scan configuration"
    else
        log_warning "Missing security-code-scan.config"
    fi
}

# Check GitHub secrets
check_github_secrets() {
    log_check "Checking GitHub secrets"
    
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI not available, cannot check secrets"
        return 0
    fi
    
    if ! gh auth status &> /dev/null; then
        log_warning "GitHub CLI not authenticated, cannot check secrets"
        return 0
    fi
    
    local secrets_output
    if secrets_output=$(gh secret list 2>/dev/null); then
        if echo "$secrets_output" | grep -q "SNYK_TOKEN"; then
            log_success "SNYK_TOKEN secret is configured"
        else
            log_error "SNYK_TOKEN secret is missing"
        fi
        
        if echo "$secrets_output" | grep -q "SLACK_WEBHOOK_URL"; then
            log_success "SLACK_WEBHOOK_URL secret is configured"
        else
            log_warning "SLACK_WEBHOOK_URL secret is missing (optional)"
        fi
    else
        log_warning "Cannot access repository secrets"
    fi
}

# Check scripts directory
check_scripts() {
    log_check "Checking security scripts"
    
    local scripts_found=0
    
    if [[ -f "scripts/generate-security-report.py" ]]; then
        log_success "Found security report generator"
        ((scripts_found++))
        
        # Check if executable
        if [[ -x "scripts/generate-security-report.py" ]]; then
            log_success "Report generator is executable"
        else
            log_warning "Report generator is not executable"
            if [[ "$AUTO_FIX" == "true" ]]; then
                chmod +x scripts/generate-security-report.py
                log_success "Made report generator executable"
            fi
        fi
    else
        log_warning "Missing security report generator"
    fi
    
    if [[ -f "scripts/create-security-pr.sh" ]]; then
        log_success "Found security PR creation script"
        ((scripts_found++))
        
        # Check if executable
        if [[ -x "scripts/create-security-pr.sh" ]]; then
            log_success "PR creation script is executable"
        else
            log_warning "PR creation script is not executable"
            if [[ "$AUTO_FIX" == "true" ]]; then
                chmod +x scripts/create-security-pr.sh
                log_success "Made PR creation script executable"
            fi
        fi
    else
        log_warning "Missing security PR creation script"
    fi
    
    if [[ $scripts_found -eq 0 ]]; then
        log_error "No security scripts found"
        return 1
    fi
    
    return 0
}

# Check documentation
check_documentation() {
    log_check "Checking security documentation"
    
    local docs_found=0
    
    if [[ -f "SECURITY.md" ]]; then
        log_success "Found SECURITY.md"
        ((docs_found++))
    else
        log_warning "Missing SECURITY.md"
        if [[ "$AUTO_FIX" == "true" ]]; then
            create_security_md
        fi
    fi
    
    if [[ -f "README.md" ]]; then
        if grep -q -i "security" README.md; then
            log_success "README.md mentions security"
        else
            log_warning "README.md doesn't mention security"
        fi
    fi
    
    return 0
}

# Check dependencies and tools
check_dependencies() {
    log_check "Checking security tool dependencies"
    
    # Check for common security tools
    local tools=(
        "trivy:Trivy vulnerability scanner"
        "snyk:Snyk security platform"
        "yamllint:YAML linter"
        "jq:JSON processor"
    )
    
    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info##*:}"
        
        if command -v "$tool" &> /dev/null; then
            log_success "$description is available"
        else
            log_warning "$description is not available"
        fi
    done
    
    # Check Python dependencies for report generation
    if command -v python3 &> /dev/null; then
        log_success "Python 3 is available"
        
        local python_packages=("matplotlib" "plotly" "pandas" "jinja2")
        for package in "${python_packages[@]}"; do
            if python3 -c "import $package" &> /dev/null; then
                log_success "Python package $package is available"
            else
                log_warning "Python package $package is missing"
            fi
        done
    else
        log_warning "Python 3 is not available"
    fi
}

# Create configuration files
create_trivyignore() {
    cat > .trivyignore << 'EOF'
# Trivy ignore file
**/test/**
**/tests/**
**/docs/**
**/*.md
EOF
    log_success "Created .trivyignore file"
}

create_snyk_config() {
    cat > .snyk << 'EOF'
version: v1.0.0
exclude:
  - 'test/**'
  - 'tests/**'
  - 'docs/**'
EOF
    log_success "Created .snyk file"
}

create_owasp_suppressions() {
    cat > owasp-suppressions.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!-- Add suppressions here -->
</suppressions>
EOF
    log_success "Created owasp-suppressions.xml file"
}

create_bandit_config() {
    cat > .bandit << 'EOF'
[bandit]
exclude_dirs = tests,test,docs
EOF
    log_success "Created .bandit file"
}

create_eslint_security_config() {
    cat > .eslintrc-security.js << 'EOF'
module.exports = {
  plugins: ['security'],
  extends: ['plugin:security/recommended']
};
EOF
    log_success "Created .eslintrc-security.js file"
}

create_gosec_config() {
    cat > .gosec.json << 'EOF'
{
  "severity": "medium",
  "confidence": "medium",
  "exclude-dir": ["test", "tests", "vendor"]
}
EOF
    log_success "Created .gosec.json file"
}

create_security_md() {
    cat > SECURITY.md << 'EOF'
# Security Policy

## Automated Security Scanning

This project uses automated security scanning with multiple tools.

## Reporting Security Issues

Please report security vulnerabilities to: security@company.com

## Security Workflow

- Automated scans run on every push and pull request
- Daily scheduled scans at 2 AM UTC
- Security reports are generated automatically
- Critical vulnerabilities trigger immediate notifications
EOF
    log_success "Created SECURITY.md file"
}

# Generate validation report
generate_report() {
    local report_file="$1"
    
    if [[ -z "$report_file" ]]; then
        return 0
    fi
    
    log_info "Generating validation report: $report_file"
    
    local timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    
    cat > "$report_file" << EOF
{
  "validation_report": {
    "timestamp": "$timestamp",
    "version": "$VALIDATION_VERSION",
    "project_type": "$PROJECT_TYPE",
    "summary": {
      "total_checks": $TOTAL_CHECKS,
      "passed": $PASSED_CHECKS,
      "failed": $FAILED_CHECKS,
      "warnings": $WARNING_CHECKS,
      "success_rate": $(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    },
    "status": "$(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)"
  }
}
EOF
    
    log_success "Validation report generated: $report_file"
}

# Show summary
show_summary() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Validation Summary                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Project Type: $PROJECT_TYPE"
    echo "Total Checks: $TOTAL_CHECKS"
    echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
    echo -e "Warnings: ${YELLOW}$WARNING_CHECKS${NC}"
    echo ""
    
    local success_rate=$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    echo "Success Rate: $success_rate%"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}✅ Security setup validation PASSED${NC}"
        echo ""
        echo "🚀 Your security workflow is properly configured!"
        echo "   Next steps:"
        echo "   1. Commit and push your changes"
        echo "   2. Trigger the security workflow"
        echo "   3. Review generated reports"
    else
        echo -e "${RED}❌ Security setup validation FAILED${NC}"
        echo ""
        echo "🔧 Issues found that need attention:"
        echo "   - Review the failed checks above"
        echo "   - Use --fix option to auto-fix some issues"
        echo "   - Manually address remaining problems"
        echo ""
        echo "💡 Run with --verbose for more details"
        echo "💡 Run with --fix to attempt automatic fixes"
    fi
    
    echo ""
}

# Main function
main() {
    show_banner
    
    # Parse arguments
    parse_args "$@"
    
    # Detect project type
    PROJECT_TYPE=$(detect_project_type)
    log_info "Detected project type: $PROJECT_TYPE"
    
    if [[ "$PROJECT_TYPE" == "unknown" ]]; then
        log_warning "Could not auto-detect project type. Using generic validation."
        PROJECT_TYPE="generic"
    fi
    
    echo ""
    log_info "Starting security setup validation..."
    echo ""
    
    # Run validation checks
    check_git_repository
    check_github_workflow
    check_security_configs
    check_github_secrets
    check_scripts
    check_documentation
    check_dependencies
    
    # Generate report if requested
    if [[ -n "$REPORT_FILE" ]]; then
        generate_report "$REPORT_FILE"
    fi
    
    # Show summary
    show_summary
    
    # Exit with appropriate code
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function with all arguments
main "$@"