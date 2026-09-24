# Aliases and small functions. Machine-specific ones belong in hosts/<hostname>.zsh.
# `ls` is aliased to eza by OMZP::eza (30-plugins.zsh); `..`, `d`, `1`-`9` come from
# OMZL::directories; `g*` git aliases from OMZP::git.

# Core utilities. rg replaces grep on purpose.
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# Navigation
alias -- -='cd -'             # -- so `-` is not parsed as an option

# Git
alias glog='PAGER="less -F -X" git log'                                   # -F quit if one screen, -X no clear
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'

# This repo (a plain git repo deployed with stow, see INSTALL.md)
alias dotfiles='git -C $HOME/dotfiles'
alias dots='cd $HOME/dotfiles'

# keys [app]: cheatsheets. Every stow package keeps its own CHEATSHEET.md next to its
# config, so they land in $XDG_CONFIG_HOME/<app>/CHEATSHEET.md. No argument shows all
# of them, zsh first; `keys ghostty` shows one.
keys() {
    local -a files
    files=("$ZDOTDIR/CHEATSHEET.md" "$XDG_CONFIG_HOME"/*/CHEATSHEET.md(N))
    typeset -U files
    (( $# )) && files=("$XDG_CONFIG_HOME/$1/CHEATSHEET.md")
    [[ -f $files[1] ]] || { print -u2 "keys: no hay cheatsheet para '$1'"; return 1 }
    if (( $+commands[bat] )); then
        bat --language=markdown --style=header -- $files
    else
        cat -- $files
    fi
}

# Completion cache: compinit reuses the dump for 24 h (see 40-completion.zsh), so a
# freshly installed package's completions show up after this, or tomorrow.
alias compreset='rm -f $XDG_CACHE_HOME/zsh/zcompdump* && exec zsh'
