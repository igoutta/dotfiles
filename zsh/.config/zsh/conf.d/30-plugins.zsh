# Plugin manager (zinit) and the plugins that must load BEFORE compinit.
# Plugins that need compinit first are at the end of 40-completion.zsh.
#
# Only real zsh plugins go through zinit. Binaries (starship, atuin, zoxide, direnv,
# pay-respects, fzf, navi, eza) come from pacman and are wired up in 60-tools.zsh.
#   Ubuntu/Fedora: install those binaries from apt/dnf, cargo or their GitHub
#   releases; nothing in this file changes.

ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    print -P "%F{33}Installing zinit…%f"
    command mkdir -p "${ZINIT_HOME:h}" && command chmod g-rwX "${ZINIT_HOME:h}"
    command git clone --depth 1 https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" \
        && print -P "%F{34}zinit installed.%f" \
        || print -P "%F{160}zinit clone failed.%f"
fi
source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ---------- Oh-My-Zsh libraries (dependencies of the OMZ plugins below) ----------
zi snippet OMZL::git.zsh           # git_current_branch etc., used by OMZP::git
zi snippet OMZL::directories.zsh   # .., ..., d, 1-9 directory-stack aliases

# ---------- Oh-My-Zsh plugins ----------
zi snippet OMZP::git               # g, ga, gc, gp… aliases
zi snippet OMZP::sudo              # Esc Esc prepends sudo (rebound below, see 50-keybinds.zsh)
zi snippet OMZP::systemd           # sc-status, sc-restart…
zi snippet OMZP::uv

PYTHON_VENV_NAME=".venv"
PYTHON_VENV_NAMES=($PYTHON_VENV_NAME venv)
zi snippet OMZP::python

zstyle ':omz:plugins:eza' 'dirs-first'  yes
zstyle ':omz:plugins:eza' 'git-status'  yes
zstyle ':omz:plugins:eza' 'header'      yes
zstyle ':omz:plugins:eza' 'icons'       yes
zstyle ':omz:plugins:eza' 'color-scale' all
zstyle ':omz:plugins:eza' 'time-style'  relative
(( $+commands[eza] )) && zi snippet OMZP::eza   # ls → eza; silently skipped if eza is not installed

# ---------- Third-party plugins ----------
zi wait lucid for MichaelAquilina/zsh-autoswitch-virtualenv

# Extra completion definitions: must be in fpath before compinit runs.
zi ice as'completion'
zi light zsh-users/zsh-completions
