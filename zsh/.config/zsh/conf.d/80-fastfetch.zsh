# Banner al abrir una terminal (fastfetch). Por SSH, la variante ssh.jsonc: «usuario @ equipo» en
# grande, servicios y últimos accesos (paquete fastfetch/). No en shells anidadas, tmux ni VS Code.
if (( $+commands[fastfetch] )) && [[ -o interactive && -z $FASTFETCH_SHOWN && -z $TMUX && $TERM_PROGRAM != vscode ]]; then
    export FASTFETCH_SHOWN=1
    if [[ -n $SSH_CONNECTION ]]; then
        fastfetch -c "${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/ssh.jsonc"
    else
        fastfetch                  # lee $XDG_CONFIG_HOME/fastfetch/config.jsonc
    fi
fi
