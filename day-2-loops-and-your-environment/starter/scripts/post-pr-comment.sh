#!/usr/bin/env bash
#
# post-pr-comment.sh - the vetted write path, in one file.
#
# The agent proposes the comment. This script decides whether it goes out. Five
# properties, each checkable in one reading:
#
#   1. The credential is read in exactly one function, read_token, and only on
#      the branch that talks to the network.
#   2. Only an allowlisted action runs. ALLOWED_ACTIONS is the list.
#   3. --dry-run prints the exact request and sends nothing.
#   4. A real send needs an explicit confirmation, or --yes on the command line.
#   5. Every send appends one log line.
#
# Out of the box there is no network path at all: FIXTURE_DIR defaults to the
# fixture directory shipped beside this script, and the send appends to a file
# there. The gh branch runs only if you deliberately set FIXTURE_DIR to the
# empty string, which nothing in this course does.
#
# Sources: enterprise-12 (gh pr comment <number> --body "<text>"),
# enterprise-13 (POST /repos/{owner}/{repo}/pulls/{pull_number}/comments),
# enterprise-14 (gh api reaches the same endpoint with the same fields).

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

# The repositories this wrapper is willing to write to. One per line in
# allowlist.txt, blank lines and # comments ignored.
ALLOWED_REPOS="$(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$HERE/allowlist.txt" 2>/dev/null || true)"

# The actions this wrapper is willing to perform. Anything else is refused,
# whatever the caller had in mind.
ALLOWED_ACTIONS="comment"

# Where a send lands. Empty means "talk to the network"; anything else means
# "append to a file under here". The default is the local fixture.
FIXTURE_DIR="${FIXTURE_DIR-$ROOT/fixtures}"
LOG_FILE="${LOG_FILE:-$ROOT/post-pr-comment.log}"

EX_USAGE=2
EX_REFUSED=3
EX_UNCONFIRMED=4

usage() {
  cat <<'USAGE'
usage: post-pr-comment.sh --repo <name> --pr <number> (--body <text> | --body-file <path>)
                          [--action comment] [--dry-run] [--yes]

  --repo       repository name, as it appears in allowlist.txt
  --pr         pull-request number
  --body       comment text
  --body-file  file holding the comment text, - for standard input
  --action     what to do; only an allowlisted action runs (default: comment)
  --dry-run    print the exact request and send nothing
  --yes        skip the confirmation prompt; required when there is no terminal
USAGE
}

die() { echo "post-pr-comment: $1" >&2; exit "${2:-$EX_USAGE}"; }

# The one place a credential is read. Nothing else in this file touches it. The
# agent sees it only if the shell that started the agent already exports it.
read_token() {
  if [ -n "${GH_TOKEN:-}" ]; then printf '%s' "$GH_TOKEN"; return 0; fi
  if [ -n "${GITHUB_TOKEN:-}" ]; then printf '%s' "$GITHUB_TOKEN"; return 0; fi
  return 1
}

REPO=""; PR=""; BODY=""; BODY_FILE=""; ACTION="comment"; DRY_RUN=0; ASSUME_YES=0

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)      REPO="${2:-}"; shift 2 || die "--repo needs a value" ;;
    --pr)        PR="${2:-}"; shift 2 || die "--pr needs a value" ;;
    --body)      BODY="${2:-}"; shift 2 || die "--body needs a value" ;;
    --body-file) BODY_FILE="${2:-}"; shift 2 || die "--body-file needs a value" ;;
    --action)    ACTION="${2:-}"; shift 2 || die "--action needs a value" ;;
    --dry-run)   DRY_RUN=1; shift ;;
    --yes)       ASSUME_YES=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *)           usage >&2; die "unknown argument: $1" ;;
  esac
done

[ -n "$REPO" ] || { usage >&2; die "--repo is required"; }
[ -n "$PR" ] || { usage >&2; die "--pr is required"; }
case "$PR" in ''|*[!0-9]*) die "--pr must be a number, got: $PR" ;; esac

if [ -n "$BODY_FILE" ]; then
  if [ "$BODY_FILE" = "-" ]; then
    BODY="$(cat)"
  else
    [ -f "$BODY_FILE" ] || die "no such body file: $BODY_FILE"
    BODY="$(cat "$BODY_FILE")"
  fi
fi
[ -n "$BODY" ] || { usage >&2; die "--body or --body-file is required"; }

# Guardrail: the action allowlist.
case " $ALLOWED_ACTIONS " in
  *" $ACTION "*) : ;;
  *) die "action not allowed: $ACTION (allowed: $ALLOWED_ACTIONS)" "$EX_REFUSED" ;;
esac

# Guardrail: the repository allowlist.
# ---------------------------------------------------------------------------
# Exercise 4 lives here. The repository allowlist is loaded at the top of this
# file and then never consulted: a wrapper that declares an allowlist and does
# not check it is a wrapper with a comment where a guardrail should be. Write
# the failing test first, then make it pass.
# ---------------------------------------------------------------------------

ENDPOINT="repos/$REPO/pulls/$PR/comments"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "DRY RUN: would POST $ENDPOINT"
  printf '%s\n' "$BODY"
  exit 0
fi

if [ "$ASSUME_YES" -ne 1 ]; then
  if [ ! -t 0 ]; then
    die "refusing to send without --yes when there is no terminal to confirm at" "$EX_UNCONFIRMED"
  fi
  echo "About to POST $ENDPOINT"
  printf '%s\n' "$BODY"
  printf 'Send it? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES) : ;;
    *) die "cancelled at the confirmation prompt" "$EX_UNCONFIRMED" ;;
  esac
fi

if [ -n "$FIXTURE_DIR" ]; then
  target="$FIXTURE_DIR/$REPO/pulls/$PR/comments.md"
  mkdir -p "$(dirname "$target")" || die "cannot write under $FIXTURE_DIR"
  {
    echo "---"
    printf '%s\n' "$BODY"
  } >> "$target"
  echo "POSTED $ENDPOINT -> $target"
else
  token="$(read_token)" || die "no credential in GH_TOKEN or GITHUB_TOKEN" "$EX_REFUSED"
  GH_TOKEN="$token" gh api "$ENDPOINT" -f body="$BODY" >/dev/null \
    || die "gh api refused the request" "$EX_REFUSED"
  echo "POSTED $ENDPOINT"
fi

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') action=$ACTION repo=$REPO pr=$PR bytes=${#BODY}" >> "$LOG_FILE"
