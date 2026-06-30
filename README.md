# git-up

Pulls `develop` (or `master`) across every git repo in the current directory — stashing dirty trees, switching branches, pulling, and restoring automatically.

```
$ git up
━━ api-service (on feature/auth → pulling develop)
  ✓  Already up to date

━━ web-app (on main → pulling develop)
  →  Working tree dirty — stashing as 'git-up-2026-06-30-09:15:42'
  ✓  Stashed
  ✓  Checked out develop
  ✓  Pulled latest develop
     3 files changed, 47 insertions(+), 12 deletions(-)
  →  Restoring stash
  ✓  Stash restored

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  2 updated  0 skipped  0 errors
```

## Usage

```
git up [--back]
```

| Flag | Description |
|------|-------------|
| `--back` | Return to the original branch after pulling |

Run from any directory that contains git repos as immediate subdirectories.

## What it does

For each subdirectory that is a git repo:

1. Determines the target branch (`develop` preferred, `master` as fallback)
2. Detects and skips repos mid-merge or mid-rebase
3. Stashes any uncommitted changes
4. Checks out the target branch (creates a local tracking branch if needed)
5. Runs `git pull origin <target>`
6. Switches back to the original branch if `--back` was passed
7. Restores the stash

## Install

```bash
./install.sh
```

Installs `git-up` to `~/.local/bin` (if on `$PATH`) or `/usr/local/bin`. Once installed, `git up` works as a git subcommand.

To uninstall:

```bash
./uninstall.sh
```

## Manual install

Copy the script anywhere on your `$PATH` and make it executable:

```bash
cp git-up ~/.local/bin/git-up
chmod +x ~/.local/bin/git-up
```
