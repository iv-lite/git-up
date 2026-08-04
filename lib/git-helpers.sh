_has_branch() {
  local repo="$1" branch="$2"
  git -C "$repo" rev-parse --verify "$branch" &>/dev/null \
    || git -C "$repo" rev-parse --verify "origin/$branch" &>/dev/null
}

_is_dirty() {
  local repo="$1"
  [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ]]
}

_is_excluded() {
  local repo="$1" pattern
  [[ ${#EXCLUDE_PATTERNS[@]} -eq 0 ]] && return 1
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    [[ "$repo" == $pattern ]] && return 0
  done
  return 1
}

# Prints the name of the in-progress marker found (MERGE_HEAD etc.) and
# returns 0, or returns 1 if the repo isn't mid-merge/rebase/etc.
_has_in_progress_op() {
  local repo="$1" marker
  for marker in MERGE_HEAD REBASE_HEAD CHERRY_PICK_HEAD REVERT_HEAD; do
    if [[ -f "$repo/.git/$marker" ]]; then
      printf '%s' "$marker"
      return 0
    fi
  done
  return 1
}

# Pure checkout attempt — no stashing, no printing.
# Returns: 0 = ok, 1 = checkout failed, 2 = tracking-branch creation failed.
_checkout_target() {
  local repo="$1" target="$2"

  if git -C "$repo" checkout "$target" --quiet 2>/dev/null; then
    return 0
  fi

  if git -C "$repo" rev-parse --verify "origin/$target" &>/dev/null \
      && ! git -C "$repo" rev-parse --verify "$target" &>/dev/null; then
    if git -C "$repo" checkout -b "$target" --track "origin/$target" --quiet 2>/dev/null; then
      return 0
    fi
    return 2
  fi

  return 1
}

_checkout_error_message() {
  local target="$1" rc="$2"
  if [[ "$rc" == "2" ]]; then
    printf 'Failed to create tracking branch for %s' "$target"
  else
    printf 'Failed to checkout %s' "$target"
  fi
}
