# ~/.config/zsh/.zshrc
# Interactive shells only. Each concern lives in its own file under conf.d/,
# sourced in lexical order (the NN- prefix is the load order, and order matters:
# plugins before completion, completion before the post-compinit plugins, and
# keybinds before the tools that override keys).
#
# Layout:
#   conf.d/NN-*.zsh        shared config, committed
#   hosts/<hostname>.zsh   machine-specific config (PATH for SDKs, odd aliases), committed
#   local.zsh              secrets and one-off hacks, git-ignored, optional

for _f in "$ZDOTDIR"/conf.d/*.zsh(N); do
    source "$_f"
done

# $HOST comes from /etc/hostname on Arch, Ubuntu and Fedora alike.
[[ -f "$ZDOTDIR/hosts/$HOST.zsh" ]] && source "$ZDOTDIR/hosts/$HOST.zsh"
[[ -f "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
unset _f
