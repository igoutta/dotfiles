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

# Cheatsheet of keys and aliases (CHEATSHEET.md next to this config)
alias keys='${commands[bat]:-cat} --language=markdown --style=plain $ZDOTDIR/CHEATSHEET.md'

# Completion cache: compinit reuses the dump for 24 h (see 40-completion.zsh), so a
# freshly installed package's completions show up after this, or tomorrow.
alias compreset='rm -f $XDG_CACHE_HOME/zsh/zcompdump* && exec zsh'
