#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_SRC="$SCRIPT_DIR/git-up"

if [[ ! -f "$SCRIPT_SRC" ]]; then
  printf "Error: git-up script not found at %s\n" "$SCRIPT_SRC" >&2
  exit 1
fi

if [[ -d "$HOME/.local/bin" ]] && echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  INSTALL_DIR="$HOME/.local/bin"
elif [[ -d "/usr/local/bin" ]]; then
  INSTALL_DIR="/usr/local/bin"
else
  printf "Error: no suitable install directory found. Add ~/.local/bin to PATH or install manually.\n" >&2
  exit 1
fi

DEST="$INSTALL_DIR/git-up"

if [[ "$INSTALL_DIR" == "/usr/local/bin" ]]; then
  printf "Installing to %s (requires sudo)...\n" "$DEST"
  sudo cp "$SCRIPT_SRC" "$DEST"
  sudo chmod +x "$DEST"
else
  printf "Installing to %s...\n" "$DEST"
  cp "$SCRIPT_SRC" "$DEST"
  chmod +x "$DEST"
fi

printf "Done. Run: git up [--back]\n"
