#!/usr/bin/env bash
set -euo pipefail

BIN_CANDIDATES=("$HOME/.local/bin/git-up" "/usr/local/bin/git-up")
LIB_CANDIDATES=("$HOME/.local/lib/git-up" "/usr/local/lib/git-up")

REMOVED=false

for target in "${BIN_CANDIDATES[@]}"; do
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

for target in "${LIB_CANDIDATES[@]}"; do
  if [[ -d "$target" ]]; then
    if [[ "$target" == /usr/local/lib/* ]]; then
      printf "Removing %s (requires sudo)...\n" "$target"
      sudo rm -rf "$target"
    else
      printf "Removing %s...\n" "$target"
      rm -rf "$target"
    fi
    REMOVED=true
  fi
done

if $REMOVED; then
  printf "git-up uninstalled.\n"
else
  printf "git-up not found in any standard location.\n"
fi
