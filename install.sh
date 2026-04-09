#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${TMUX_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/tmux}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux"
OH_MY_TMUX_DIR="${OH_MY_TMUX_DIR:-$DATA_DIR/oh-my-tmux}"
OH_MY_TMUX_REPO="${OH_MY_TMUX_REPO:-https://github.com/gpakosz/.tmux.git}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

link_path() {
  local source="$1"
  local target="$2"
  local backup
  local current

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      printf 'ok: %s already points to %s\n' "$target" "$source"
      return
    fi
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    backup="${target}.bak.${TIMESTAMP}"
    mv "$target" "$backup"
    printf 'backup: %s -> %s\n' "$target" "$backup"
  fi

  ln -s "$source" "$target"
  printf 'link: %s -> %s\n' "$target" "$source"
}

ensure_oh_my_tmux() {
  mkdir -p "$(dirname "$OH_MY_TMUX_DIR")"

  if [ -d "$OH_MY_TMUX_DIR/.git" ]; then
    printf 'ok: oh-my-tmux already present at %s\n' "$OH_MY_TMUX_DIR"
    return
  fi

  if [ -e "$OH_MY_TMUX_DIR" ]; then
    fail "$OH_MY_TMUX_DIR exists but is not an oh-my-tmux git checkout"
  fi

  printf 'clone: %s -> %s\n' "$OH_MY_TMUX_REPO" "$OH_MY_TMUX_DIR"
  git clone --depth 1 "$OH_MY_TMUX_REPO" "$OH_MY_TMUX_DIR"
}

main() {
  require_cmd git

  ensure_oh_my_tmux

  mkdir -p "$CONFIG_DIR"

  link_path "$OH_MY_TMUX_DIR/.tmux.conf" "$CONFIG_DIR/tmux.conf"
  link_path "$REPO_DIR/tmux.conf.local" "$CONFIG_DIR/tmux.conf.local"
  link_path "$REPO_DIR/scripts" "$CONFIG_DIR/scripts"

  printf '\nInstall complete.\n'
  printf 'Start tmux or reload it with: tmux source-file %s/tmux.conf\n' "$CONFIG_DIR"
  printf 'TPM plugins will be installed by oh-my-tmux on launch.\n'
}

main "$@"
