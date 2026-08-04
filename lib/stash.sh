_restore_stash() {
  local repo="$1" stashed="$2" stash_name="$3"
  if [[ "$stashed" == "true" ]]; then
    git -C "$repo" stash pop --quiet 2>/dev/null \
      || warn "Stash pop failed — stash preserved as '${stash_name}'"
  fi
}

# Stashes the working tree; on success sets the caller's STASHED=true.
_stash_now() {
  local repo="$1"
  info "Stashing local changes as '${STASH_NAME}'"
  if git -C "$repo" stash push -u --message "$STASH_NAME" --quiet; then
    success "Stashed"
    STASHED=true
    return 0
  fi
  error "Stash failed — skipping"
  return 1
}
