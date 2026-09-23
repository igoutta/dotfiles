# System banner on new terminals. Skipped for nested shells, tmux, VS Code and SSH
# (SSH sessions get a MOTD from rust-motd instead; see the rust-motd package).
if (( $+commands[fastfetch] )) && [[ -o interactive && -z $FASTFETCH_SHOWN && -z $TMUX && -z $SSH_CONNECTION && $TERM_PROGRAM != vscode ]]; then
    export FASTFETCH_SHOWN=1
    fastfetch                  # reads $XDG_CONFIG_HOME/fastfetch/config.jsonc
fi
