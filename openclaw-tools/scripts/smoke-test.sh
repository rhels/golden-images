#!/usr/bin/env bash
set -euo pipefail

failures=0
for cmd in openclaw acli oc kubectl vault helm argocd jq yq trivy; do
  if command -v "$cmd" &>/dev/null; then
    ver="$("$cmd" version --short 2>/dev/null || "$cmd" version 2>/dev/null || "$cmd" --version 2>/dev/null || echo 'ok')"
    printf "✅ %-12s %s\n" "$cmd" "$ver"
  else
    printf "❌ %-12s NOT FOUND\n" "$cmd"
    failures=$((failures + 1))
  fi
done

if [ "$failures" -gt 0 ]; then
  echo ""
  echo "FAIL: $failures tool(s) missing"
  exit 1
fi

echo ""
echo "All tools verified ✅"
