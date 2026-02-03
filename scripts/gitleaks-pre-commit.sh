#!/usr/bin/env sh
set -eu

if ! command -v gitleaks >/dev/null 2>&1; then
  cat <<'EOF'
gitleaks is required for this pre-commit hook but was not found on PATH.

Install gitleaks and try again:
  https://github.com/gitleaks/gitleaks

To bypass this hook for one commit:
  SKIP=gitleaks git commit
EOF
  exit 1
fi

# Scan staged changes only.
gitleaks git --staged
