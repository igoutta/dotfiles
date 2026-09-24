# Shell integration for CLI tools. Key overlaps between them are settled in 65-keybinds.zsh. Every block is guarded with (( $+commands[x] )) so a
# missing binary costs nothing and prints nothing; install the tool and it lights up.
#
# Arch: all of these are in [extra] or the AUR (pacman -S fzf zoxide direnv navi
# pay-respects atuin yazi eza).
#   Fedora: fzf zoxide direnv eza are in dnf; atuin/navi/pay-respects/yazi via cargo
#   or their GitHub releases.
#   Ubuntu: fzf zoxide direnv are in apt but old (see the fzf note); eza needs the
#   gierens.de repo; atuin/navi/pay-respects/yazi via cargo or GitHub releases.

# ---------- fzf ----------
# `fzf --zsh` (fzf ≥ 0.48) prints key bindings + completion in one go.
#   Ubuntu ≤ 24.04 ships an older fzf: replace the source line with
#     source /usr/share/doc/fzf/examples/key-bindings.zsh
#     source /usr/share/doc/fzf/examples/completion.zsh
#   Fedora (if --zsh is missing): source /usr/share/fzf/shell/key-bindings.zsh
if (( $+commands[fzf] )); then
    source <(fzf --zsh)

    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='
        --height=50% -1
        --layout=reverse-list
        --multi
        --border=rounded
        --prompt="  "
        --pointer="  "
        --preview-window=right:65%:wrap:border-left
    '
    _fzf_preview='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always --line-range=:500 {} || cat {}) 2>/dev/null | head -300'
    export FZF_CTRL_T_OPTS="--preview '$_fzf_preview'"
    unset _fzf_preview
fi

# ---------- zoxide (smarter cd: z, zi) ----------
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# ---------- direnv ----------
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# ---------- navi (Ctrl-G cheatsheets) ----------
(( $+commands[navi] )) && eval "$(navi widget zsh)"

# ---------- pay-respects (fix the last failed command) ----------
(( $+commands[pay-respects] )) && eval "$(pay-respects zsh --alias)"

# ---------- yazi: `y` opens yazi and cds to where you quit ----------
if (( $+commands[yazi] )); then
    y() {
        local tmp cwd
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# ---------- mise (node, pnpm y versiones por proyecto) ----------
# `activate` ajusta PATH al entrar en un directorio con mise.toml. Las apps gráficas usan los
# shims de ~/.config/environment.d/50-mise.conf (paquete stow mise/).
#   Fedora/Ubuntu: mise no está en dnf/apt; instalador oficial (https://mise.run) o COPR jdxcode/mise.
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# ---------- atuin (history database; takes over Ctrl-R and Up) ----------
# Last on purpose: it must win the Ctrl-R binding over fzf.
# --disable-ai: atuin ≥ 18.9 otherwise binds "?" on an empty line to its AI assistant.
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-ai)"
