
# ###################################################################################
# Zinit bootstrap
# ###################################################################################
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zi light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ###################################################################################
# History Configuration
# ###################################################################################
HISTSIZE=10000
SAVEHIST="$HISTFILE"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTDUP=erase
setopt APPEND_HISTORY
setopt SHARE_HISTORY    # inc_append_history & extended_history at once 
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_VERIFY

# ###################################################################################
# Shell Behaviour
# ###################################################################################
# Changing Directories
setopt AUTOCD
# Completion
# setopt COMPLETE_IN_WORD
# Expansion and Globbing
setopt EXTENDED_GLOB
setopt MAGIC_EQUAL_SUBST
unsetopt NOMATCH
setopt NUMERIC_GLOB_SORT
# I/O
setopt CORRECT
setopt INTERACTIVE_COMMENTS
# Job Control
setopt NOTIFY
# Prompting
setopt PROMPT_SUBST

# ###################################################################################
# Aliases
# ###################################################################################
# Core utilities
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# Navigation
alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# Git
alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Video
alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'

# ###################################################################################
# OMZ Libraries (load early, before plugins that depend on them)
# ###################################################################################
zi snippet OMZL::git.zsh
zi snippet OMZL::async_prompt.zsh
zi snippet OMZL::directories.zsh

# ###################################################################################
# OMZ Plugins & tools that don't need compinit
# ###################################################################################
zi snippet OMZP::git
zi snippet OMZP::sudo
zi snippet OMZP::systemd
zi snippet OMZP::uv

PYTHON_VENV_NAME=".venv"
PYTHON_VENV_NAMES=($PYTHON_VENV_NAME venv)
# PYTHON_AUTO_VRUN=true
zi snippet OMZP::python

zi wait lucid for MichaelAquilina/zsh-autoswitch-virtualenv

zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'color-scale' all
zstyle ':omz:plugins:eza' 'time-style' relative
zi snippet OMZP::eza

# zi snippet OMZP::direnv
zi light ajeetdsouza/zoxide
zi ice as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' pick"direnv" src"zhook.zsh"
zi light direnv/direnv

# ###################################################################################
# Completion providers (adds functions to fpath BEFORE compinit)
# ###################################################################################
zi ice as'completion'
zi light zsh-users/zsh-completions

# ###################################################################################
# Completion styling (must be set before compinit runs)
# ###################################################################################
# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Use LS_COLORS for completion listings
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Disable default menu so fzf-tab can take over
zstyle ':completion:*' menu no
# Enable group descriptions (required for fzf-tab groups)
zstyle ':completion:*:descriptions' format '[%d]'
# Don't sort git-checkout candidates (keep branch order)
zstyle ':completion:*:git-checkout:*' sort false

# ###################################################################################
# fzf-tab styling
# ###################################################################################
# Preview directories with eza (falls back to ls)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
# Custom fzf flags for the tab menu
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border --bind=tab:accept
# Switch groups with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'
# Remove the middle dot prefix for better look
zstyle ':fzf-tab:*' prefix ''

# ###################################################################################
# Fuzzy finder (fzf package)
# ###################################################################################
# Fedora
if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
  source /usr/share/fzf/shell/key-bindings.zsh
fi
#:! MISSING COMPLETIONS XDDDDDDDD

# Arch
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
fi

# Ubuntu
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# Replace default find command with ripgrep since it's faster
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# Ctrl-T uses ripgrep
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#UI
export FZF_DEFAULT_OPTS='
	--height=50% -1
	--layout=reverse-list
	--multi
	--border=rounded
	--prompt="  "
	--pointer="  "
	--preview-window=right:65%:wrap:border-left
'

export _FZF_PREVIEW_CMD='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always --line-range=:500 {} || cat {}) 2> /dev/null | head -300'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"


# ###################################################################################
# Ardupilot
# ###################################################################################
export PATH=/opt/gcc-arm-none-eabi-10-2020-q4-major/bin:$PATH
export PATH=/home/ga/ardupilot/Tools/autotest:$PATH
export MAP_SERVICE=GoogleSat

# ###################################################################################
# Load completions efficiently after prompt is ready
# ###################################################################################
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Replay any compdefs that were queued by plugins loaded above
zi cdreplay -q

# ###################################################################################
# Post-compinit plugins (order matters!)
# fzf-tab → syntax-highlighting → zsh-autosuggestions → others
# ###################################################################################
zi light Aloxaf/fzf-tab
# zi ice wait lucid; zi light joshskidmore/zsh-fzf-history-search
# zi light zdharma-continuum/fast-syntax-highlighting
zi light zsh-users/zsh-syntax-highlighting
zi light zsh-users/zsh-autosuggestions
zi light iffse/pay-respects

eval "$(navi widget zsh)"
# ###################################################################################
# Key bindings
# ###################################################################################


# ###################################################################################
# Fastfetch
# ###################################################################################
if [[ -o interactive ]] && [[ -z "$FASTFETCH_SHOWN" ]] && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
    export FASTFETCH_SHOWN=1
    # Print fastfetch without blocking prompt appearance
    # () {
    #     local out
    #     out=$(fastfetch --pipe 2>/dev/null)
    #     [[ -n "$out" ]] && print -P "$out"
    # } &
    fastfetch --config ~/.config/fastfetch/config.jsonc
fi

# ###################################################################################
# Prompt 
# ###################################################################################
FUNCNEST=100
# zi snippet OMZP::starship
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# ###################################################################################
# Atuin — it replaces history widgets and could override other plugins
# ###################################################################################
zi ice wait lucid
zi load atuinsh/atuin
