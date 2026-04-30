#!/usr/bin/env bash
set -euo pipefail

# Usage: ./mault-solo-merge.sh <PR_NUMBER>
# Temporarily lowers branch protection, merges the PR, then restores full protection.

PR_NUMBER="${1:?Usage: ./mault-solo-merge.sh <PR_NUMBER>}"

DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name' 2>/dev/null || echo "main")
REPO_OWNER=$(gh repo view --json owner -q '.owner.login')
REPO_NAME=$(gh repo view --json name -q '.name')

# Check for plan limitation
API_RESP=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}/branches/${DEFAULT_BRANCH}/protection" 2>&1) || true
if echo "$API_RESP" | grep -q "Upgrade to GitHub Pro\|403\|must be upgraded"; then
  echo "=== Branch protection not available on free plan — merging directly ==="
  gh pr merge "$PR_NUMBER" --merge --delete-branch
  echo "=== Done ==="
  exit 0
fi

# Capture current required checks
CURRENT_CHECKS=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}/branches/${DEFAULT_BRANCH}/protection/required_status_checks" \
  -q '[.contexts[]] | map("\"" + . + "\"") | join(",")' 2>/dev/null) || true

echo "=== Temporarily lowering protection for merge ==="
printf '{"required_status_checks":{"strict":true,"contexts":[%s]},"enforce_admins":false,"required_pull_request_reviews":null,"restrictions":null}' \
  "${CURRENT_CHECKS}" | \
  gh api "repos/${REPO_OWNER}/${REPO_NAME}/branches/${DEFAULT_BRANCH}/protection" \
    --method PUT --input - >/dev/null 2>&1

echo "=== Merging PR #${PR_NUMBER} ==="
gh pr merge "$PR_NUMBER" --merge --delete-branch

echo "=== Restoring full branch protection ==="
printf '{"required_status_checks":{"strict":true,"contexts":[%s]},"enforce_admins":true,"required_pull_request_reviews":{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_last_push_approval":true},"restrictions":null}' \
  "${CURRENT_CHECKS}" | \
  gh api "repos/${REPO_OWNER}/${REPO_NAME}/branches/${DEFAULT_BRANCH}/protection" \
    --method PUT --input - >/dev/null 2>&1

echo "=== Done. Protection restored. ==="
