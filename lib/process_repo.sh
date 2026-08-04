# Pulls the target branch (develop/master) for a single repo: skip-checks,
# checkout (stashing only if that's what's blocking it), pull (same), and
# an optional return to the original branch. Updates COUNT_OK/SKIP/ERR.
_process_repo() {
  local repo="$1"

  if _is_excluded "$repo"; then
    skip "${repo} — excluded"
    (( COUNT_SKIP++ )) || true
    return
  fi

  if [[ ! -d "$repo/.git" ]]; then
    header "$repo" "(not a git repo)"
    skip "No .git directory — skipping"
    (( COUNT_SKIP++ )) || true
    return
  fi

  local target=""
  if _has_branch "$repo" develop; then
    target="develop"
  elif _has_branch "$repo" master; then
    target="master"
  fi

  if [[ -z "$target" ]]; then
    header "$repo" "(no develop or master)"
    skip "No develop or master branch — skipping"
    (( COUNT_SKIP++ )) || true
    return
  fi

  local orig_branch="" is_detached=false
  if orig_branch=$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null); then
    is_detached=false
  else
    orig_branch=$(git -C "$repo" rev-parse HEAD 2>/dev/null || echo "unknown")
    is_detached=true
  fi

  header "$repo" "(on ${orig_branch} → pulling ${target})"

  local marker
  if marker=$(_has_in_progress_op "$repo"); then
    error "In-progress $marker — skipping"
    (( COUNT_ERR++ )) || true
    return
  fi

  STASH_NAME="git-up-${TIMESTAMP}"
  # _stash_now (lib/stash.sh) sets this function's local STASHED via bash's
  # dynamic scoping — keep the variable named exactly STASHED for that to work.
  local STASHED=false

  if [[ "$orig_branch" != "$target" ]] || $is_detached; then
    info "Checking out ${target}"
    _checkout_target "$repo" "$target"; local co_rc=$?

    if [[ $co_rc -ne 0 ]] && _is_dirty "$repo"; then
      warn "Checkout blocked by local changes"
      if ! _stash_now "$repo"; then
        (( COUNT_ERR++ )) || true
        return
      fi
      _checkout_target "$repo" "$target"; co_rc=$?
    fi

    if [[ $co_rc -ne 0 ]]; then
      error "$(_checkout_error_message "$target" "$co_rc")"
      _restore_stash "$repo" "$STASHED" "$STASH_NAME"
      (( COUNT_ERR++ )) || true
      return
    fi
    success "Checked out ${target}"
  else
    info "Already on ${target}"
  fi

  info "Pulling origin/${target}"
  local pull_out pull_exit
  pull_out=$(git -C "$repo" pull origin "$target" 2>&1)
  pull_exit=$?

  if [[ $pull_exit -ne 0 ]] && _is_dirty "$repo"; then
    warn "Pull blocked by local changes"
    if ! _stash_now "$repo"; then
      (( COUNT_ERR++ )) || true
      return
    fi
    pull_out=$(git -C "$repo" pull origin "$target" 2>&1)
    pull_exit=$?
  fi

  if [[ $pull_exit -ne 0 ]]; then
    error "Pull failed"
    printf "%s\n" "$pull_out" | sed 's/^/       /' >&2
    _restore_stash "$repo" "$STASHED" "$STASH_NAME"
    (( COUNT_ERR++ )) || true
    return
  fi

  if echo "$pull_out" | grep -q "Already up to date"; then
    success "Already up to date"
  else
    success "Pulled latest ${target}"
    echo "$pull_out" | grep -E "file(s)? changed|insertion|deletion" | sed 's/^/       /' || true
  fi

  if $BACK; then
    if $is_detached; then
      warn "Was in detached HEAD — cannot auto-return"
      warn "To return: git -C $repo checkout $orig_branch"
    elif [[ "$orig_branch" != "$target" ]]; then
      info "Returning to ${orig_branch}"
      if git -C "$repo" checkout "$orig_branch" --quiet; then
        success "Back on ${orig_branch}"
      else
        error "Failed to return to ${orig_branch}"
        _restore_stash "$repo" "$STASHED" "$STASH_NAME"
        (( COUNT_ERR++ )) || true
        return
      fi
    fi
  fi

  if $STASHED; then
    info "Restoring stash"
    if git -C "$repo" stash pop --quiet; then
      success "Stash restored"
    else
      warn "Stash pop had conflicts — stash preserved as '${STASH_NAME}'"
    fi
  fi

  (( COUNT_OK++ )) || true
}
