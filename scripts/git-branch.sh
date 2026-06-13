#!/usr/bin/env bash
set -euo pipefail

path="${1:-}"
[ -n "$path" ] || exit 0

branch="$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$path" rev-parse --short HEAD 2>/dev/null || true)"
if [ -n "$branch" ]; then
  printf ' | %s' "$branch"
fi
