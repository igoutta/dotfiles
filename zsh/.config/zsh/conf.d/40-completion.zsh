# Completion styling, compinit, and the plugins that must load AFTER compinit.

# ---------- Styling (must be set before compinit) ----------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'       # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"      # LS_COLORS set in 10-options.zsh
zstyle ':completion:*' menu no                               # fzf-tab draws the menu
zstyle ':completion:*:descriptions' format '[%d]'            # group headers, needed by fzf-tab
zstyle ':completion:*:git-checkout:*' sort false             # keep branch order

# ---------- fzf-tab ----------
zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border --bind=tab:accept
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' prefix ''

# ---------- compinit ----------
# The dump is regenerated at most once a day; otherwise -C skips the (slow) security check.
autoload -Uz compinit
_zdump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
[[ -d ${_zdump:h} ]] || mkdir -p "${_zdump:h}"
if [[ -n ${_zdump}(#qN.mh+24) || ! -f $_zdump ]]; then
    compinit -d "$_zdump"
else
    compinit -C -d "$_zdump"
fi
unset _zdump
zi cdreplay -q                # replay compdefs queued by the plugins above

# ---------- Post-compinit plugins (order matters) ----------
zi light Aloxaf/fzf-tab                     # fzf-tab first: it wraps the completion widget
zi light zsh-users/zsh-syntax-highlighting  # then highlighting
zi light zsh-users/zsh-autosuggestions      # then suggestions
