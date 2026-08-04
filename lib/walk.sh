# Calls the given function once per immediate subdirectory of cwd,
# passing the directory name (no trailing slash) as its only argument.
_walk_repos() {
  local fn="$1" repo_path repo
  for repo_path in */; do
    repo="${repo_path%/}"
    [[ -d "$repo" ]] || continue
    "$fn" "$repo"
  done
}
