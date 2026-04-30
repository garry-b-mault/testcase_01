#!/usr/bin/env bash
set -uo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║  MAULT RALPH LOOP — Step 9 AI Coder Rules Verification      ║
# ║  Physics, not policy. This script checks REAL STATE.         ║
# ║  Exit 0 = all pass. Exit 1 = work remains.                  ║
# ╚══════════════════════════════════════════════════════════════╝

PASS_COUNT=0
FAIL_COUNT=0
PENDING_COUNT=0
CHECK_RESULTS=()
TOTAL_CHECKS=10

PROOF_DIR=".mault"
PROOF_FILE="$PROOF_DIR/verify-step9.proof"

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

echo "========================================"
echo "  MAULT Step 9 AI Coder Rules Verification"
echo "========================================"
echo ""

# --- Proof file ---
write_proof_file() {
  local sha epoch iso token
  sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  epoch=$(date +%s)
  iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  token="MAULT-STEP9-${sha}-${epoch}-${TOTAL_CHECKS}/${TOTAL_CHECKS}"

  mkdir -p "$PROOF_DIR"
  {
    echo "MAULT-STEP9-PROOF"
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

# --- CHECK 1: Step 8 prerequisite ---
check_1() {
  if [ ! -f ".mault/verify-step8.proof" ]; then
    print_fail 1 "Step 8 not complete. Run mault-verify-step8.sh first."
    return
  fi
  local token
  token=$(grep '^Token:' .mault/verify-step8.proof | awk '{print $2}' | head -1) || true
  # Also accept single-line old-format proof
  if [ -z "$token" ]; then
    token=$(cat .mault/verify-step8.proof | head -1) || true
  fi
  print_pass 1 "Step 8 proof exists (${token:-unknown})"
}

# --- CHECK 2: Claude Code hooks configured ---
check_2() {
  if [ ! -f ".claude/settings.json" ]; then
    print_pending 2 "Claude Code not configured (.claude/settings.json missing)"
    return
  fi
  if python3 -c "import json; d=json.load(open('.claude/settings.json')); exit(0 if d.get('hooks') else 1)" 2>/dev/null; then
    print_pass 2 "Claude Code: .claude/settings.json has hooks configured"
  else
    print_fail 2 "Claude Code: .claude/settings.json exists but has no hooks"
  fi
}

# --- CHECK 3: Cursor rules exist with TDD content ---
check_3() {
  if [ ! -f ".cursorrules" ]; then
    print_pending 3 ".cursorrules not found (create if Cursor is used)"
    return
  fi
  if grep -qi "TDD\|test.*first\|red.*green\|mock tax" .cursorrules 2>/dev/null; then
    print_pass 3 ".cursorrules present with TDD enforcement content"
  else
    print_fail 3 ".cursorrules exists but missing TDD/Mock Tax content"
  fi
}

# --- CHECK 4: GitHub Copilot instructions exist with TDD content ---
check_4() {
  if [ ! -f ".github/copilot-instructions.md" ]; then
    print_pending 4 ".github/copilot-instructions.md not found (create if Copilot is used)"
    return
  fi
  if grep -qi "TDD\|test.*first\|red.*green\|mock tax" .github/copilot-instructions.md 2>/dev/null; then
    print_pass 4 ".github/copilot-instructions.md present with TDD enforcement content"
  else
    print_fail 4 ".github/copilot-instructions.md exists but missing TDD content"
  fi
}

# --- CHECK 5: Windsurf rules exist with TDD content ---
check_5() {
  if [ ! -f ".windsurfrules" ]; then
    print_pending 5 ".windsurfrules not found (create if Windsurf is used)"
    return
  fi
  if grep -qi "TDD\|test.*first\|red.*green\|mock tax" .windsurfrules 2>/dev/null; then
    print_pass 5 ".windsurfrules present with TDD enforcement content"
  else
    print_fail 5 ".windsurfrules exists but missing TDD content"
  fi
}

# --- CHECK 6: Augment guidelines exist with TDD content ---
check_6() {
  if [ ! -f ".augment-guidelines" ]; then
    print_pending 6 ".augment-guidelines not found (create if Augment is used)"
    return
  fi
  if grep -qi "TDD\|test.*first\|red.*green\|mock tax" .augment-guidelines 2>/dev/null; then
    print_pass 6 ".augment-guidelines present with TDD enforcement content"
  else
    print_fail 6 ".augment-guidelines exists but missing TDD content"
  fi
}

# --- CHECK 7: At least one AI tool rules file exists ---
check_7() {
  local count=0
  local found=""
  [ -f ".claude/settings.json" ] && count=$((count + 1)) && found="${found}claude "
  [ -f ".cursorrules" ] && count=$((count + 1)) && found="${found}cursor "
  [ -f ".github/copilot-instructions.md" ] && count=$((count + 1)) && found="${found}copilot "
  [ -f ".windsurfrules" ] && count=$((count + 1)) && found="${found}windsurf "
  [ -f ".augment-guidelines" ] && count=$((count + 1)) && found="${found}augment "

  if [ "$count" -ge 1 ]; then
    print_pass 7 "${count} AI tool(s) configured: ${found}"
  else
    print_fail 7 "No AI tool rules files found — create at least one"
  fi
}

# --- CHECK 8: Rules reference project-specific test paths ---
check_8() {
  local rules_file=""
  [ -f ".cursorrules" ] && rules_file=".cursorrules"
  [ -f ".github/copilot-instructions.md" ] && rules_file=".github/copilot-instructions.md"

  if [ -z "$rules_file" ]; then
    print_pending 8 "No rules file to check for project-specific paths"
    return
  fi

  local has_test_path has_runner
  has_test_path=$(grep -qi "tests/unit\|tests/integration\|test_\*\.py\|\.test\.ts" "$rules_file" && echo "true" || echo "false")
  has_runner=$(grep -qi "jest\|pytest\|npm test\|go test\|cargo test" "$rules_file" && echo "true" || echo "false")

  if [ "$has_test_path" = "true" ] && [ "$has_runner" = "true" ]; then
    print_pass 8 "Rules include project-specific test paths and runner (${rules_file})"
  else
    print_fail 8 "Rules missing project test paths or runner command (${rules_file})"
  fi
}

# --- CHECK 9: Handshake commit [mault-step9] ---
check_9() {
  local commit
  commit=$(git log --oneline --all 2>/dev/null | grep '\[mault-step9\]' | head -1) || true

  if [ -n "$commit" ]; then
    print_pass 9 "Handshake commit found: ${commit:0:72}"
  else
    print_fail 9 "No commit with [mault-step9] in message — make the handshake commit"
  fi
}

# --- CHECK 10: Handshake issue ---
check_10() {
  if ! command -v gh >/dev/null 2>&1; then
    print_pending 10 "gh CLI not available"
    return
  fi

  local issue_url
  issue_url=$(gh issue list --search "[MAULT] Production Readiness: Step 9" --json url -q '.[0].url' 2>/dev/null) || true
  if [ -z "$issue_url" ]; then
    issue_url=$(gh issue list --state closed --search "[MAULT] Production Readiness: Step 9" --json url -q '.[0].url' 2>/dev/null) || true
  fi

  if [ -n "$issue_url" ]; then
    print_pass 10 "Handshake issue: ${issue_url}"
  else
    print_pending 10 "No handshake issue found — create it after all other checks pass"
  fi
}

# --- Run all checks ---
check_1; check_2; check_3; check_4; check_5; check_6
check_7; check_8; check_9; check_10

# --- Summary ---
echo ""
echo "========================================"
echo "  PASS: ${PASS_COUNT}/${TOTAL_CHECKS}  FAIL: ${FAIL_COUNT}/${TOTAL_CHECKS}  PENDING: ${PENDING_COUNT}/${TOTAL_CHECKS}"
echo "========================================"

if [ "$FAIL_COUNT" -eq 0 ] && [ "$PENDING_COUNT" -eq 0 ]; then
  write_proof_file
  echo "ALL CHECKS PASSED. Step 9 AI Coder Rules is complete."
  exit 0
elif [ "$FAIL_COUNT" -gt 0 ]; then
  rm -f "$PROOF_FILE"
  echo "${FAIL_COUNT} check(s) FAILED. Fix and re-run: ./mault-verify-step9.sh"
  exit 1
else
  rm -f "$PROOF_FILE"
  echo "${PENDING_COUNT} check(s) PENDING. Complete work and re-run: ./mault-verify-step9.sh"
  exit 1
fi
