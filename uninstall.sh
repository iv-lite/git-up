#!/usr/bin/env bash
set -euo pipefail

CANDIDATES=("$HOME/.local/bin/git-up" "/usr/local/bin/git-up")

REMOVED=false
for target in "${CANDIDATES[@]}"; do
  if [[ -f "$target" ]]; then
    if [[ "$target" == /usr/local/bin/* ]]; then
      printf "Removing %s (requires sudo)...\n" "$target"
      sudo rm "$target"
    else
      printf "Removing %s...\n" "$target"
      rm "$target"
    fi
    REMOVED=true
  fi
done

if $REMOVED; then
  printf "git-up uninstalled.\n"
else
  printf "git-up not found in any standard location.\n"
fi
