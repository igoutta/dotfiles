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
