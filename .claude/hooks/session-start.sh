#!/bin/bash
# Install project dependencies at the start of Claude Code cloud sessions.
# Detects which manifests exist, so it keeps working as the project grows.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}"

if [ -f package.json ]; then
  if [ -f pnpm-lock.yaml ]; then
    corepack enable >/dev/null 2>&1 || true
    pnpm install
  elif [ -f yarn.lock ]; then
    corepack enable >/dev/null 2>&1 || true
    yarn install
  else
    npm install
  fi
fi

if [ -f pyproject.toml ]; then
  pip install -e ".[dev]" 2>/dev/null || pip install -e .
elif [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi
[ -f requirements-dev.txt ] && pip install -r requirements-dev.txt

[ -f go.mod ] && go mod download
[ -f Cargo.toml ] && cargo fetch
[ -f Gemfile ] && bundle install

exit 0
