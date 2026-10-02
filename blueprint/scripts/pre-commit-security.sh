#!/bin/bash
# pre-commit-security.sh — Git pre-commit hook
# Blocks commits containing secrets, credentials, or sensitive patterns.
# Works in BOTH interactive and autonomous mode.
#
# INSTALL (per repository, run inside the repo):
#   cp ~/ailoopwise-blueprint/blueprint/scripts/pre-commit-security.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Install it per repository. Setting core.hooksPath globally would switch off
# every other repository's own git hooks.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

BLOCKED=0
WARNINGS=0

# Get list of staged files (only check what's being committed)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo "🔒 Security pre-commit scan..."

# ── PATTERN 1: Hardcoded secrets ──
SECRET_PATTERNS=(
    'AKIA[0-9A-Z]{16}'                          # AWS Access Key
    'sk-[a-zA-Z0-9]{20,}'                       # OpenAI/Anthropic API key
    'sk-ant-[a-zA-Z0-9-]{20,}'                  # Anthropic API key
    'ghp_[a-zA-Z0-9]{36}'                       # GitHub PAT
    'gho_[a-zA-Z0-9]{36}'                       # GitHub OAuth
    'glpat-[a-zA-Z0-9\-]{20,}'                  # GitLab PAT
    'xox[bpors]-[a-zA-Z0-9-]+'                  # Slack token
    'sk_live_[a-zA-Z0-9]{24,}'                  # Stripe live key
    'rk_live_[a-zA-Z0-9]{24,}'                  # Stripe restricted key
    'SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}' # SendGrid
    '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY'     # Private keys
    'password\s*[:=]\s*["\x27][^"\x27]{8,}'     # password = "something"
    'secret\s*[:=]\s*["\x27][^"\x27]{8,}'       # secret = "something"
    'api_key\s*[:=]\s*["\x27][^"\x27]{8,}'      # api_key = "something"
    'token\s*[:=]\s*["\x27][^"\x27]{8,}'        # token = "something"
    'DATABASE_URL\s*=\s*postgres://'             # Database connection strings
    'mongodb(\+srv)?://[^/\s]+'                  # MongoDB connection strings
    'redis://[^/\s]+'                            # Redis connection strings
)

for file in $STAGED_FILES; do
    # Skip binary files, lock files, and this script itself
    [[ "$file" == *.lock ]] && continue
    [[ "$file" == *.png ]] && continue
    [[ "$file" == *.jpg ]] && continue
    [[ "$file" == *.gif ]] && continue
    [[ "$file" == *.woff* ]] && continue
    [[ "$file" == *"pre-commit"* ]] && continue
    
    # Only check text content that's being added (not removed)
    CONTENT=$(git diff --cached --diff-filter=ACM -U0 "$file" 2>/dev/null | grep "^+" | grep -v "^+++" || true)
    
    if [ -z "$CONTENT" ]; then
        continue
    fi
    
    for pattern in "${SECRET_PATTERNS[@]}"; do
        MATCHES=$(echo "$CONTENT" | grep -iE "$pattern" 2>/dev/null || true)
        if [ -n "$MATCHES" ]; then
            echo -e "${RED}BLOCKED${NC} Secret pattern in $file:"
            echo "$MATCHES" | head -3 | sed 's/^/  /'
            BLOCKED=$((BLOCKED + 1))
        fi
    done
done

# ── PATTERN 2: Sensitive files that should never be committed ──
SENSITIVE_FILES=(
    '.env'
    '.env.local'
    '.env.production'
    '.env.staging'
    'id_rsa'
    'id_ed25519'
    '*.pem'
    '*.key'
    'credentials.json'
    'service-account.json'
    'secrets.yml'
    'secrets.yaml'
    '.htpasswd'
)

for file in $STAGED_FILES; do
    basename=$(basename "$file")
    for sensitive in "${SENSITIVE_FILES[@]}"; do
        if [[ "$basename" == $sensitive ]]; then
            echo -e "${RED}BLOCKED${NC} Sensitive file: $file"
            BLOCKED=$((BLOCKED + 1))
        fi
    done
done

# ── PATTERN 3: Warnings (don't block, but flag) ──
for file in $STAGED_FILES; do
    [[ "$file" == *.lock ]] && continue
    [[ "$file" != *.ts ]] && [[ "$file" != *.js ]] && [[ "$file" != *.tsx ]] && [[ "$file" != *.jsx ]] && [[ "$file" != *.py ]] && continue
    
    CONTENT=$(git diff --cached -U0 "$file" 2>/dev/null | grep "^+" | grep -v "^+++" || true)
    
    # Check for console.log with sensitive-looking data
    CONSOLE_SECRETS=$(echo "$CONTENT" | grep -iE 'console\.log.*\b(password|token|secret|key|credential)\b' 2>/dev/null || true)
    if [ -n "$CONSOLE_SECRETS" ]; then
        echo -e "${RED}BLOCKED${NC} Console logging sensitive data in $file"
        BLOCKED=$((BLOCKED + 1))
    fi
    
    # Check for TODO security markers
    SECURITY_TODOS=$(echo "$CONTENT" | grep -iE 'TODO.*secur|FIXME.*auth|HACK.*password' 2>/dev/null || true)
    if [ -n "$SECURITY_TODOS" ]; then
        echo -e "⚠ WARNING: Security TODO in $file — review before shipping"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# ── RESULT ──
echo ""
if [ $BLOCKED -gt 0 ]; then
    echo -e "${RED}✗ COMMIT BLOCKED — $BLOCKED security issue(s) found${NC}"
    echo ""
    echo "To fix: remove the flagged content, then stage and commit again."
    echo "To bypass (DANGEROUS): git commit --no-verify"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${GREEN}✓ Commit allowed${NC} with $WARNINGS warning(s)"
    exit 0
else
    echo -e "${GREEN}✓ Security scan passed${NC}"
    exit 0
fi
