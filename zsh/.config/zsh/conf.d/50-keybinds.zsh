# Key bindings. Loaded before 60-tools.zsh so fzf/atuin/navi can override single keys
# on top of these defaults.
#
# Model: emacs-style insert mode by default (Ctrl-A/E/W/K work as in every terminal),
# plus vi command mode on demand:
#   Esc Esc   → vi command mode (the prompt symbol turns into ❮, see starship.toml)
#   i / a     → back to insert mode (the emacs keymap, since it is `main`)
#   v         → edit the current line in $EDITOR (default vicmd binding)
#
# Zsh would otherwise pick vi mode silently whenever $EDITOR contains "vi"; being
# explicit here removes that surprise.

bindkey -e
KEYTIMEOUT=20                 # 200 ms to complete multi-key sequences like Esc Esc
bindkey -M emacs '\e\e' vi-cmd-mode

# Make the usual editing keys work in the emacs keymap. Codes are the common xterm ones
# (ghostty, kitty, foot, gnome-terminal…). If a key misbehaves, check `cat -v` output.
bindkey -M emacs '^[[H'    beginning-of-line       # Home
bindkey -M emacs '^[[F'    end-of-line             # End
bindkey -M emacs '^[[3~'   delete-char             # Delete
bindkey -M emacs '^[[1;5C' forward-word            # Ctrl-Right
bindkey -M emacs '^[[1;5D' backward-word           # Ctrl-Left
bindkey -M emacs '^H'      backward-kill-word      # Ctrl-Backspace
bindkey -M emacs '^[[3;5~' kill-word               # Ctrl-Delete

# Ctrl-X Ctrl-E: edit the command line in $EDITOR (same as bash)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M emacs '^X^E' edit-command-line

# Word boundaries: treat / . - _ as separators so Ctrl-W stops at path components
WORDCHARS=${WORDCHARS//[\/.\-_]/}
