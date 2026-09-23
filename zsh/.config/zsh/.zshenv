# ~/.config/zsh/.zshenv
# Read by EVERY zsh, including non-interactive scripts. Keep it small: environment only.
# Interactive-only things (aliases, prompt, plugins, GPG_TTY) live in .zshrc / conf.d/.
#
# ZDOTDIR itself is set system-wide in /etc/zsh/zshenv (Arch; see INSTALL.md).
#   Ubuntu/Fedora: /etc/zsh/zshenv has no such logic. Either add the same snippet
#   there as root, or create ~/.zshenv containing:
#     export ZDOTDIR="$HOME/.config/zsh"; [[ -f "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"

# ---------- XDG base directories ----------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# ---------- Editor ----------
# Arch ships the Helix binary as `helix`.
#   Ubuntu/Fedora: the binary is `hx` (snap, COPR, cargo or the official release tarball).
export EDITOR="helix"
export VISUAL="$EDITOR"

# ---------- Pager ----------
# Arch/Fedora: package `bat`, binary `bat`.
#   Ubuntu: the apt package installs the binary as `batcat`; either replace `bat`
#   below or `mkdir -p ~/.local/bin && ln -s /usr/bin/batcat ~/.local/bin/bat`.
export MANPAGER="bat -l man -p"

# ---------- Prompt ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

# ---------- PATH ----------
# Personal binaries/scripts. Machine-specific PATH entries go in hosts/<hostname>.zsh.
typeset -U path PATH            # keep PATH free of duplicates
path=("$HOME/.local/bin" $path)
export PATH
