BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'

GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'

info()    { printf "  ${CYAN}→${RESET}  %s\n" "$*"; }
success() { printf "  ${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "  ${YELLOW}⚠${RESET}  %s\n" "$*"; }
error()   { printf "  ${RED}✗${RESET}  %s\n" "$*" >&2; }
header()  { printf "\n${BOLD}━━ %s ${DIM}%s${RESET}\n" "$1" "$2"; }
skip()    { printf "  ${DIM}–  %s${RESET}\n" "$*"; }
