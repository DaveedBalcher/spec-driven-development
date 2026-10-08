#!/usr/bin/env bash
#
# Self-test for post-pr-comment.sh.
#
# Runs from any directory: every path is derived from this file's own location,
# and every send is redirected into a temporary directory, so a run leaves the
# shipped fixture and the log file untouched.
#
# Ends in one line, PASS or FAIL, and exits with a status that agrees with it.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="$HERE/post-pr-comment.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export FIXTURE_DIR="$TMP/fixtures"
export LOG_FILE="$TMP/post-pr-comment.log"
mkdir -p "$FIXTURE_DIR/local-repo/pulls/1"

checks=0
failures=0

pass() { checks=$((checks + 1)); }
fail() { checks=$((checks + 1)); failures=$((failures + 1)); echo "FAIL $1"; }

# 1. No arguments is a usage error, not a send.
out="$(bash "$WRAPPER" 2>&1)"; rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q '^usage:'; then pass
else fail "no arguments should exit 2 and print usage (exit $rc)"; fi

# 2. A dry run prints the endpoint it would post to.
out="$(bash "$WRAPPER" --dry-run --repo local-repo --pr 1 --body 'smoke test' 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && [ "$(printf '%s' "$out" | sed -n 1p)" = "DRY RUN: would POST repos/local-repo/pulls/1/comments" ]; then pass
else fail "dry run should print the endpoint on its first line (exit $rc, got: $out)"; fi

# 3. A dry run prints the body and writes nothing.
before="$(find "$FIXTURE_DIR" -type f | sort)"
out="$(bash "$WRAPPER" --dry-run --repo local-repo --pr 1 --body 'smoke test' 2>&1)"
after="$(find "$FIXTURE_DIR" -type f | sort)"
if [ "$(printf '%s' "$out" | sed -n 2p)" = "smoke test" ] && [ "$before" = "$after" ] && [ ! -f "$LOG_FILE" ]; then pass
else fail "dry run should print the body and write nothing"; fi

# 4. An action outside the action allowlist is refused by name.
out="$(bash "$WRAPPER" --action merge --repo local-repo --pr 1 --body x 2>&1)"; rc=$?
if [ "$rc" -eq 3 ] && printf '%s' "$out" | grep -q 'merge'; then pass
else fail "an action outside the allowlist should exit 3 and name it (exit $rc)"; fi

# 5. A confirmed send appends the comment to the fixture.
out="$(bash "$WRAPPER" --yes --repo local-repo --pr 1 --body 'the body that lands' 2>&1)"; rc=$?
target="$FIXTURE_DIR/local-repo/pulls/1/comments.md"
if [ "$rc" -eq 0 ] && [ -f "$target" ] && grep -q 'the body that lands' "$target"; then pass
else fail "a confirmed send should append to the fixture (exit $rc, got: $out)"; fi

# 6. The same send writes exactly one log line.
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE" | tr -d ' ')" = "1" ]; then pass
else fail "a send should write exactly one log line"; fi

# 7. Without --yes and without a terminal, the wrapper refuses rather than sends.
out="$(bash "$WRAPPER" --repo local-repo --pr 1 --body 'unconfirmed' < /dev/null 2>&1)"; rc=$?
if [ "$rc" -eq 4 ] && ! grep -q 'unconfirmed' "$target"; then pass
else fail "an unconfirmed send should exit 4 and write nothing (exit $rc)"; fi

# ---------------------------------------------------------------------------
# Exercise 4: add check 8 here.
#
# A repository that is not in allowlist.txt must be refused: a non-zero exit
# and a message naming the repository. Write this check first and watch it go
# red, then make the wrapper pass it. Do not change any check above.
# ---------------------------------------------------------------------------

if [ "$failures" -eq 0 ]; then
  echo "PASS $checks checks"
  exit 0
fi
echo "FAILED $failures of $checks checks"
exit 1
