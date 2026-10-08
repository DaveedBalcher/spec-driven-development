#!/usr/bin/env bash
# Stable entry point for the wrapper's self-test, so the course's own checks and
# a person at a terminal run the same thing. The checks themselves live in
# post-pr-comment.test.sh, which is the file Exercise 4 edits.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$HERE/post-pr-comment.test.sh"
