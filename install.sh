#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }

# idempotent symlink helper: backs up anything already at $dest that isn't
# already a symlink to $src, then links $src -> $dest.
link_file() {
  local src="$1" dest="$2"
  local canonical_src
  canonical_src="$(readlink -f "$src")"

  if [ -L "$dest" ]; then
    local current_target
    current_target="$(readlink -f "$dest" 2>/dev/null || true)"
    if [ "$current_target" = "$canonical_src" ]; then
      info "Already linked: $dest -> $src (skipping)"
      return
    fi
    warn "$dest is a symlink pointing elsewhere ($current_target); backing up"
    mv "$dest" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
  elif [ -e "$dest" ]; then
    warn "$dest exists and is a regular file/dir; backing up"
    mv "$dest" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
  fi

  ln -s "$canonical_src" "$dest"
  info "Linked $dest -> $canonical_src"
}

# 0. preflight
command -v curl >/dev/null 2>&1 || { warn "curl is required but not installed. Run: sudo apt install curl"; exit 1; }

# 1. ensure target dirs exist
mkdir -p "$HOME/.config" "$HOME/.local/bin"

# 2. install starship if not already present at our managed location
STARSHIP_BIN="$HOME/.local/bin/starship"
if [ -x "$STARSHIP_BIN" ]; then
  info "starship already installed at $STARSHIP_BIN ($("$STARSHIP_BIN" --version | head -1)); skipping install"
else
  if command -v starship >/dev/null 2>&1; then
    warn "starship found elsewhere on PATH ($(command -v starship)) — likely installed via apt or another method."
    warn "Installing our own copy into $HOME/.local/bin anyway; since bash_aliases puts \$HOME/.local/bin first on PATH, ours will take precedence."
  fi
  info "Installing starship into $HOME/.local/bin ..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi

# 3. symlink configs
link_file "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"
link_file "$SCRIPT_DIR/inputrc"        "$HOME/.inputrc"
link_file "$SCRIPT_DIR/bash_aliases"   "$HOME/.bash_aliases"

# 4. ensure ~/.bashrc sources ~/.bash_aliases (fallback safety net)
BASHRC="$HOME/.bashrc"
MARKER_BEGIN="# >>> my-bash-setup bash_aliases hook >>>"
MARKER_END="# <<< my-bash-setup bash_aliases hook <<<"

if [ -f "$BASHRC" ] && grep -Eq '(^|[^.])\.[[:space:]]+.*\.bash_aliases|source[[:space:]]+.*\.bash_aliases' "$BASHRC"; then
  info "~/.bashrc already sources ~/.bash_aliases; nothing to do"
elif [ -f "$BASHRC" ] && grep -qF "$MARKER_BEGIN" "$BASHRC"; then
  info "Fallback bash_aliases hook already present in ~/.bashrc; skipping"
else
  info "~/.bashrc has no bash_aliases hook; appending a guarded fallback block"
  {
    echo ""
    echo "$MARKER_BEGIN"
    echo "if [ -f ~/.bash_aliases ]; then"
    echo "    . ~/.bash_aliases"
    echo "fi"
    echo "$MARKER_END"
  } >> "$BASHRC"
fi

# 5. ensure ~/.bashrc has kubectl env/completion setup (matches current live setup)
KUBE_MARKER_BEGIN="# >>> my-bash-setup kubectl >>>"
KUBE_MARKER_END="# <<< my-bash-setup kubectl <<<"

if [ -f "$BASHRC" ] && grep -qF "$KUBE_MARKER_BEGIN" "$BASHRC"; then
  info "kubectl setup already present in ~/.bashrc; skipping"
else
  info "Adding kubectl env/completion setup to ~/.bashrc"
  {
    echo ""
    echo "$KUBE_MARKER_BEGIN"
    echo "export KUBECONFIG=~/.kube/config"
    echo ""
    echo "if command -v kubectl >/dev/null 2>&1; then"
    echo "    source <(kubectl completion bash)"
    echo "    complete -o default -F __start_kubectl k"
    echo "fi"
    echo ""
    echo "alias k='kubectl'"
    echo "$KUBE_MARKER_END"
  } >> "$BASHRC"
fi

info "Done. Open a new shell or run 'source ~/.bashrc' to pick up changes."
