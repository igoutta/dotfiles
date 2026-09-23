# Key bindings. Loaded AFTER 60-tools.zsh on purpose: fzf, atuin, navi and the OMZ sudo
# plugin all bind keys of their own, and this file has the last word so every overlap
# is resolved in one place. The human-readable list is CHEATSHEET.md (alias: keys).
#
# Design rules:
#   - Fingers stay close. A binding is a single key, a Ctrl-/Alt- chord with a nearby
#     letter, or a sequence of the SAME key (Esc Esc). Never a chord followed by typing
#     a word (the OMZ "Esc Esc tldr" style) and never far-apart chords.
#   - Insert mode uses the emacs keymap (Ctrl-A/E/W behave like every other prompt).
#     Vi command mode is one Esc away, like Helix. The prompt shows ❮ while in it.
#   - Key codes come from terminfo where possible, with the common xterm-style codes as
#     fallbacks so ghostty, kitty, foot, the Linux console and SSH sessions all agree.
#     Ubuntu/Fedora: nothing distro-specific here.

bindkey -e

# ---------- Esc → vi command mode ----------
# Esc is also the first byte of every Alt- chord and arrow key. Those arrive as one
# burst, so zsh only waits KEYTIMEOUT (in hundredths of a second) after a *lone* Esc.
KEYTIMEOUT=25
bindkey -M emacs '\e' vi-cmd-mode
# Back to insert mode: i, a, I, A (vi defaults). Ctrl-R in vi mode is atuin, not fzf.
(( $+widgets[atuin-search] )) && bindkey -M vicmd '^R' atuin-search

# ---------- sudo ----------
# The OMZ sudo plugin binds "Esc Esc" in every keymap. In insert mode that now collides
# with Esc = vi mode, so there it becomes Alt-s (replacing spell-word, which nobody
# uses). In vi command mode Esc alone does nothing, so Esc Esc stays: from insert mode
# that is Esc, Esc, Esc — same key three times, no timing involved.
for _m in emacs viins vicmd; do
    bindkey -M $_m '\es' sudo-command-line
done
bindkey -M emacs -r '\e\e'
bindkey -M viins -r '\e\e'

# ---------- Edit the command line in $EDITOR (Helix) ----------
autoload -Uz edit-command-line
zle -N edit-command-line
for _m in emacs viins vicmd; do
    bindkey -M $_m '\ee' edit-command-line
done

# ---------- Help for the command being typed ----------
# Alt-h: tldr page for the first word of the line (falls back to man when no tldr client
# is installed). Alt-m: man page. The line you were typing is kept and comes back after.
#   Arch: pacman -S tlrc (or tealdeer); Fedora: dnf install tlrc; Ubuntu: apt install tldr.
#   All three install a `tldr` binary.
_help_for_line() {
    local tool=$1 cmd=${${(z)BUFFER}[1]}
    [[ -z $cmd ]] && return
    [[ $cmd == sudo ]] && cmd=${${(z)BUFFER}[2]}
    [[ $tool == tldr ]] && (( ! $+commands[tldr] )) && tool=man
    zle push-input                # stash the current line; zle restores it afterwards
    BUFFER="$tool $cmd"
    zle accept-line
}
_tldr_for_line() { _help_for_line tldr }
_man_for_line()  { _help_for_line man }
zle -N _tldr_for_line
zle -N _man_for_line
for _m in emacs viins vicmd; do
    bindkey -M $_m '\eh' _tldr_for_line
    bindkey -M $_m '\em' _man_for_line
done
unset _m

# ---------- Editing keys ----------
# Terminal "application mode" makes the terminfo codes below match what the terminal
# actually sends while zle is reading a line (ghostty: Home is \EOH in app mode, \E[H
# otherwise). Both variants are bound anyway; this just makes terminfo reliable.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    _zle_app_mode_on()  { echoti smkx }
    _zle_app_mode_off() { echoti rmkx }
    add-zle-hook-widget zle-line-init   _zle_app_mode_on
    add-zle-hook-widget zle-line-finish _zle_app_mode_off
fi

# _bind WIDGET KEY... binds every non-empty KEY to WIDGET in the emacs keymap
_bind() { local w=$1 k; shift; for k in "$@"; do [[ -n $k ]] && bindkey -M emacs "$k" $w; done }
_bind beginning-of-line  "${terminfo[khome]}" '^[[H' '^[[1~'        # Home
_bind end-of-line        "${terminfo[kend]}"  '^[[F' '^[[4~'        # End
_bind delete-char        "${terminfo[kdch1]}" '^[[3~'               # Delete
_bind overwrite-mode     "${terminfo[kich1]}" '^[[2~'               # Insert
_bind forward-word       '^[[1;5C' '^[[1;3C'                        # Ctrl-Right / Alt-Right
_bind backward-word      '^[[1;5D' '^[[1;3D'                        # Ctrl-Left  / Alt-Left
_bind kill-word          '^[[3;5~'                                  # Ctrl-Delete
_bind backward-kill-line '^[[3;2~'                                  # Shift-Delete
unfunction _bind

# Ctrl-Backspace. ghostty and kitty send ^H for it and ^? for plain Backspace
# (terminfo kbs=^?). On a terminal where plain Backspace is ^H (old xterm, some serial
# consoles) this binding would eat a whole word, so it is skipped there.
[[ ${terminfo[kbs]} != $'\b' ]] && bindkey -M emacs '^H' backward-kill-word

# Word boundaries: stop at / . - _ so Ctrl-W and Ctrl-Left move one path component
WORDCHARS=${WORDCHARS//[\/.\-_]/}
