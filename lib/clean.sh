CLEAN_FOUND=0
CLEAN_DROPPED=0
CLEAN_HAD_ERROR=false

# Drops every stash in one repo whose message starts with "git-up-".
# `git stash list` lines look like:
#   stash@{0}: On develop: git-up-2026-08-04-14:23:07
# Splitting on the first ": " twice isolates the index, then the message
# (branch names can't contain ":", so this is unambiguous).
_clean_one_repo() {
  local repo="$1"
  _is_excluded "$repo" && return
  [[ -d "$repo/.git" ]] || return

  local matches=() line gd rest msg idx
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    gd="${line%%:*}"
    rest="${line#*: }"
    msg="${rest#*: }"
    [[ "$msg" == git-up-* ]] || continue
    idx="${gd#stash@\{}"; idx="${idx%\}}"
    matches+=("${idx}:::${rest}")
  done < <(git -C "$repo" stash list 2>/dev/null)

  [[ ${#matches[@]} -eq 0 ]] && return

  header "$repo" "(${#matches[@]} git-up stash(es))"
  (( CLEAN_FOUND += ${#matches[@]} ))

  # matches[] is in ascending index order (git lists newest/stash@{0} first).
  # Dropping highest-index (oldest) first means every drop targets an index
  # that hasn't been shifted yet by an earlier drop.
  local i
  for ((i = ${#matches[@]} - 1; i >= 0; i--)); do
    idx="${matches[$i]%%:::*}"
    local desc="${matches[$i]#*:::}"
    if git -C "$repo" stash drop "stash@{${idx}}" --quiet 2>/dev/null; then
      success "Dropped stash@{${idx}} — ${desc}"
      (( CLEAN_DROPPED++ )) || true
    else
      error "Failed to drop stash@{${idx}}"
      CLEAN_HAD_ERROR=true
    fi
  done
}

_run_clean() {
  _walk_repos _clean_one_repo

  printf "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
  if [[ "$CLEAN_FOUND" -eq 0 ]]; then
    printf "  ${DIM}No git-up stashes found${RESET}\n\n"
  else
    printf "  ${GREEN}%d dropped${RESET}\n\n" "$CLEAN_DROPPED"
  fi

  $CLEAN_HAD_ERROR && return 1
  return 0
}
