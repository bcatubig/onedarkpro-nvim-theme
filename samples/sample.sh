#!/usr/bin/env bash
# Exercises the token classes the Mapping colours for shell: keywords,
# command names, variables and expansions, $( ) and $, strings with escapes,
# numbers, operators, brackets and comments.

set -euo pipefail

readonly MAX_RETRIES=3
QUEUE_NAME="${QUEUE_NAME:-jobs}"
declare -a packages=(redis-server python3-redis)
export QUEUE_DIR="/var/lib/${QUEUE_NAME}"

usage() {
  cat <<EOF
Usage: $0 [-n name] [-v]
  -n  queue name (default: ${QUEUE_NAME})
  -v  verbose
EOF
}

function log {
  local level=$1
  shift
  printf '%s [%s] %s\n' "$(date +%T)" "$level" "$*" >&2
}

while getopts ':n:v' opt; do
  case "$opt" in
    n) QUEUE_NAME="$OPTARG" ;;
    v) VERBOSE=1 ;;
    \?) usage; exit 64 ;;
  esac
done
shift $((OPTIND - 1))

if [[ ! -d "$QUEUE_DIR" && -z "${DRY_RUN:-}" ]]; then
  mkdir -p "$QUEUE_DIR" || { log error "cannot create $QUEUE_DIR"; exit 1; }
fi

attempt=0
until [[ "$attempt" -ge "$MAX_RETRIES" ]]; do
  attempt=$((attempt + 1))
  if ping -c 1 -W 1 queue.internal >/dev/null 2>&1; then
    break
  fi
  log warn "retry ${attempt}/${MAX_RETRIES}"
  sleep 1
done

for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    log info "$pkg already installed"
  elif [[ "$pkg" =~ ^python3- ]]; then
    apt-get install -y "$pkg"
  fi
done

count=$(find "$QUEUE_DIR" -type f -name '*.job' | wc -l)
echo -e "${count} jobs\tin ${QUEUE_DIR}"
echo $'ANSI-C string with a tab\there'
printf '%d%%\n' $((count * 100 / MAX_RETRIES))
[[ $# -gt 0 ]] && echo "extra args: $*"
exit $?
