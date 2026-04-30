#!/usr/bin/env bash
set -uo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║  MAULT RALPH LOOP — Step 7 Enforcement Verification         ║
# ║  Physics, not policy. This script checks REAL STATE.         ║
# ║  Exit 0 = all pass. Exit 1 = work remains.                  ║
# ╚══════════════════════════════════════════════════════════════╝

PASS_COUNT=0
FAIL_COUNT=0
PENDING_COUNT=0
CHECK_RESULTS=()
TOTAL_CHECKS=12

PROOF_DIR=".mault"
PROOF_FILE="$PROOF_DIR/verify-step7.proof"

record_result() { CHECK_RESULTS+=("CHECK $1: $2 - $3"); }
print_pass()    { echo "[PASS]    CHECK $1: $2"; PASS_COUNT=$((PASS_COUNT + 1)); record_result "$1" "PASS" "$2"; }
print_fail()    { echo "[FAIL]    CHECK $1: $2"; FAIL_COUNT=$((FAIL_COUNT + 1)); record_result "$1" "FAIL" "$2"; }
print_pending() { echo "[PENDING] CHECK $1: $2"; PENDING_COUNT=$((PENDING_COUNT + 1)); record_result "$1" "PENDING" "$2"; }

# --- Staleness check ---
if [ -f "$PROOF_FILE" ]; then
  PROOF_SHA=$(grep '^GitSHA:' "$PROOF_FILE" | awk '{print $2}')
  CURRENT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  if [ "$PROOF_SHA" != "$CURRENT_SHA" ]; then
    echo "WARNING: Proof file is STALE (proof: $PROOF_SHA, HEAD: $CURRENT_SHA). Deleting."
    rm -f "$PROOF_FILE"
  fi
fi

# --- Default branch detection ---
detect_default_branch() {
  local branch
  branch=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name' 2>/dev/null) || true
  if [ -n "$branch" ]; then echo "$branch"; return; fi
  if git show-ref --verify --quiet refs/heads/master 2>/dev/null; then echo "master"
  else echo "main"; fi
}
DEFAULT_BRANCH=$(detect_default_branch)

echo "========================================"
echo "  MAULT Step 7 Enforcement Verification"
echo "  Branch: $DEFAULT_BRANCH"
echo "========================================"
echo ""

# --- Proof file ---
write_proof_file() {
  local sha epoch iso token
  sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  epoch=$(date +%s)
  iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  token="MAULT-STEP7-${sha}-${epoch}-${TOTAL_CHECKS}/${TOTAL_CHECKS}"

  mkdir -p "$PROOF_DIR"
  {
    echo "MAULT-STEP7-PROOF"
    echo "=================="
    echo "Timestamp: $epoch"
    echo "DateTime: $iso"
    echo "GitSHA: $sha"
    echo "Checks: ${TOTAL_CHECKS}/${TOTAL_CHECKS} PASS"
    for r in "${CHECK_RESULTS[@]}"; do echo "  $r"; done
    echo "=================="
    echo "Token: $token"
  } > "$PROOF_FILE"

  echo ""
  echo "Proof file written: $PROOF_FILE"
  echo "Token: $token"
}

# --- CHECK 1: Step 6 prerequisite ---
check_1() {
  if [ ! -f ".mault/verify-step6.proof" ]; then
    print_fail 1 "Step 6 not complete. Run mault-verify-step6.sh first."
    return
  fi
  local token
  token=$(grep '^Token:' .mault/verify-step6.proof | awk '{print $2}') || true
  print_pass 1 "Step 6 proof exists (${token:-unknown})"
}

# --- CHECK 2: mault.yaml exists with version: 1 ---
check_2() {
  local yaml_file=""
  [ -f "docs/mault.yaml" ] && yaml_file="docs/mault.yaml"
  [ -f "mault.yaml" ] && yaml_file="mault.yaml"

  if [ -z "$yaml_file" ]; then
    print_fail 2 "mault.yaml not found (checked docs/mault.yaml and mault.yaml)"
    return
  fi

  local version_ok="false"
  if command -v python3 >/dev/null 2>&1; then
    version_ok=$(python3 -c "
import yaml
try:
    d = yaml.safe_load(open('$yaml_file'))
    print('true' if d and d.get('version') == 1 else 'false')
except:
    print('false')
" 2>/dev/null || echo "false")
  fi

  if [ "$version_ok" = "true" ]; then
    print_pass 2 "mault.yaml valid (version: 1) at ${yaml_file}"
  else
    print_fail 2 "mault.yaml missing or invalid version at ${yaml_file}"
  fi
}

# --- CHECK 3: Core detector sections present ---
check_3() {
  local yaml_file=""
  [ -f "docs/mault.yaml" ] && yaml_file="docs/mault.yaml"
  [ -f "mault.yaml" ] && yaml_file="mault.yaml"

  if [ -z "$yaml_file" ]; then
    print_fail 3 "mault.yaml not found"
    return
  fi

  local missing=""
  grep -q "directoryReinforcement:" "$yaml_file" || missing="${missing}UC01 "
  grep -q "deprecatedPatterns:" "$yaml_file"     || missing="${missing}UC02 "
  grep -q "namingConvention:" "$yaml_file"        || missing="${missing}UC03 "
  grep -q "environmentReinforcement:" "$yaml_file" || missing="${missing}UC04 "
  grep -q "tempFiles:" "$yaml_file"               || missing="${missing}UC06 "
  grep -q "flatArchitecture:" "$yaml_file"        || missing="${missing}UC07 "
  grep -q "configChaos:" "$yaml_file"             || missing="${missing}UC08 "
  grep -q "fileProliferation:" "$yaml_file"       || missing="${missing}UC09 "
  grep -q "overcrowdedFolders:" "$yaml_file"      || missing="${missing}UC11 "

  if [ -z "$missing" ]; then
    print_pass 3 "All core detector sections present (UC01-UC11)"
  else
    print_fail 3 "Missing detector sections: ${missing}"
  fi
}

# --- CHECK 4: deprecatedPatterns has ≥10 entries ---
check_4() {
  local yaml_file=""
  [ -f "docs/mault.yaml" ] && yaml_file="docs/mault.yaml"
  [ -f "mault.yaml" ] && yaml_file="mault.yaml"

  if [ -z "$yaml_file" ]; then
    print_fail 4 "mault.yaml not found"
    return
  fi

  local count
  count=$(grep -c "^  - id:" "$yaml_file" 2>/dev/null || echo "0")
  if [ "$count" -ge 10 ]; then
    print_pass 4 "deprecatedPatterns has ${count} entries (≥10 required)"
  else
    print_fail 4 "deprecatedPatterns only has ${count} entries — need ≥10"
  fi
}

# --- CHECK 5: directoryReinforcement has ≥5 rules ---
check_5() {
  local yaml_file=""
  [ -f "docs/mault.yaml" ] && yaml_file="docs/mault.yaml"
  [ -f "mault.yaml" ] && yaml_file="mault.yaml"

  if [ -z "$yaml_file" ]; then
    print_fail 5 "mault.yaml not found"
    return
  fi

  local count
  count=$(grep -c "expectedDir:" "$yaml_file" 2>/dev/null || echo "0")
  if [ "$count" -ge 5 ]; then
    print_pass 5 "directoryReinforcement has ${count} rules (≥5 required)"
  else
    print_fail 5 "directoryReinforcement only has ${count} rules — need ≥5"
  fi
}

# --- CHECK 6: governance.rules section present (UC18) with ≥1 rule ---
check_6() {
  local yaml_file=""
  [ -f "docs/mault.yaml" ] && yaml_file="docs/mault.yaml"
  [ -f "mault.yaml" ] && yaml_file="mault.yaml"

  if [ -z "$yaml_file" ]; then
    print_fail 6 "mault.yaml not found"
    return
  fi

  if ! grep -q "governance:" "$yaml_file"; then
    print_fail 6 "governance: section missing from mault.yaml — add UC18 rules"
    return
  fi

  local rule_count
  rule_count=$(python3 -c "
import yaml
try:
    d = yaml.safe_load(open('$yaml_file'))
    rules = d.get('governance', {}).get('rules', [])
    print(len(rules))
except:
    print(0)
" 2>/dev/null || echo "0")

  if [ "${rule_count:-0}" -ge 1 ]; then
    print_pass 6 "governance.rules (UC18) present with ${rule_count} rule(s)"
  else
    print_fail 6 "governance.rules section empty — add at least 1 UC18 rule"
  fi
}

# --- CHECK 7: UC16 TypeScript dependency health in pre-commit ---
check_7() {
  if [ ! -f ".pre-commit-config-ts.yaml" ]; then
    print_pending 7 "No TypeScript pre-commit config found — skipped"
    return
  fi

  if grep -q "npm.audit\|npm-audit\|dependency.health\|dependency-health" .pre-commit-config-ts.yaml 2>/dev/null; then
    print_pass 7 "UC16 TypeScript dependency health hook present in .pre-commit-config-ts.yaml"
  else
    print_fail 7 "UC16 missing: add npm-audit hook to .pre-commit-config-ts.yaml"
  fi
}

# --- CHECK 8: UC16 Python dependency health in pre-commit ---
check_8() {
  if [ ! -f ".pre-commit-config.yaml" ]; then
    print_pending 8 "No Python pre-commit config found — skipped"
    return
  fi

  if grep -q "pip.audit\|pip-audit\|dependency.health.python\|dependency-health-python" .pre-commit-config.yaml 2>/dev/null; then
    print_pass 8 "UC16 Python dependency health hook present in .pre-commit-config.yaml"
  else
    print_fail 8 "UC16 missing: add pip-audit hook to .pre-commit-config.yaml"
  fi
}

# --- CHECK 9: CI has package-audit job ---
check_9() {
  local ci_file
  ci_file=$(ls .github/workflows/ci.yml .github/workflows/ci.yaml 2>/dev/null | head -1) || true

  if [ -z "$ci_file" ]; then
    print_fail 9 "No CI workflow found"
    return
  fi

  if grep -qE 'package.?audit|pip.?audit|dependency.?audit|audit.*level' "$ci_file" 2>/dev/null; then
    print_pass 9 "CI workflow has dependency audit job"
  else
    print_fail 9 "CI workflow missing dependency audit job"
  fi
}

# --- CHECK 10: mault.yaml committed ---
check_10() {
  local yaml_file=""
  [ -f "docs/mault.yaml" ] && yaml_file="docs/mault.yaml"
  [ -f "mault.yaml" ] && yaml_file="mault.yaml"

  if [ -z "$yaml_file" ]; then
    print_fail 10 "mault.yaml not found"
    return
  fi

  if git ls-files --error-unmatch "$yaml_file" >/dev/null 2>&1; then
    local modified
    modified=$(git diff --name-only "$yaml_file" 2>/dev/null) || true
    if [ -n "$modified" ]; then
      print_fail 10 "${yaml_file} has uncommitted changes — commit them"
    else
      print_pass 10 "${yaml_file} is committed and clean"
    fi
  else
    print_fail 10 "${yaml_file} is not committed — run git add and commit"
  fi
}

# --- CHECK 11: Handshake commit [mault-step7] ---
check_11() {
  local commit
  commit=$(git log --oneline --all 2>/dev/null | grep '\[mault-step7\]' | head -1) || true

  if [ -n "$commit" ]; then
    print_pass 11 "Handshake commit found: ${commit:0:72}"
  else
    print_fail 11 "No commit with [mault-step7] in message — make the handshake commit"
  fi
}

# --- CHECK 12: Handshake issue ---
check_12() {
  if ! command -v gh >/dev/null 2>&1; then
    print_pending 12 "gh CLI not available"
    return
  fi

  local issue_url
  issue_url=$(gh issue list --search "[MAULT] Production Readiness: Step 7" --json url -q '.[0].url' 2>/dev/null) || true
  if [ -z "$issue_url" ]; then
    issue_url=$(gh issue list --state closed --search "[MAULT] Production Readiness: Step 7" --json url -q '.[0].url' 2>/dev/null) || true
  fi

  if [ -n "$issue_url" ]; then
    print_pass 12 "Handshake issue: ${issue_url}"
  else
    print_pending 12 "No handshake issue found — create it after all other checks pass"
  fi
}

# --- Run all checks ---
check_1; check_2; check_3; check_4; check_5; check_6
check_7; check_8; check_9; check_10; check_11; check_12

# --- Summary ---
echo ""
echo "========================================"
echo "  PASS: ${PASS_COUNT}/${TOTAL_CHECKS}  FAIL: ${FAIL_COUNT}/${TOTAL_CHECKS}  PENDING: ${PENDING_COUNT}/${TOTAL_CHECKS}"
echo "========================================"

if [ "$FAIL_COUNT" -eq 0 ] && [ "$PENDING_COUNT" -eq 0 ]; then
  write_proof_file
  echo "ALL CHECKS PASSED. Step 7 Enforcement is complete."
  exit 0
elif [ "$FAIL_COUNT" -gt 0 ]; then
  rm -f "$PROOF_FILE"
  echo "${FAIL_COUNT} check(s) FAILED. Fix and re-run: ./mault-verify-step7.sh"
  exit 1
else
  rm -f "$PROOF_FILE"
  echo "${PENDING_COUNT} check(s) PENDING. Complete work and re-run: ./mault-verify-step7.sh"
  exit 1
fi
