# Shell behaviour. Pure zsh, no distro-specific parts.

# Changing directories
setopt AUTOCD                 # `dir` alone means `cd dir`

# Expansion and globbing
setopt EXTENDED_GLOB          # #, ~ and ^ operators in globs
setopt MAGIC_EQUAL_SUBST      # expand ~ and = after `opt=` arguments
setopt NUMERIC_GLOB_SORT      # file1 file2 file10, not file1 file10 file2
unsetopt NOMATCH              # pass unmatched globs through instead of erroring

# I/O
setopt CORRECT                # offer to correct misspelled commands
setopt INTERACTIVE_COMMENTS   # allow # comments on the command line

# Job control
setopt NOTIFY                 # report background job status immediately

# GPG: pinentry needs to know the tty. Interactive-only, so it lives here and not in .zshenv.
export GPG_TTY=$TTY

# Colours for ls/eza/completion listings (LS_COLORS).
# vivid (pacman -S vivid; Fedora: dnf; Ubuntu: cargo or GitHub release) generates a full
# theme. "ansi" uses only the terminal's 16 ANSI colours, so it follows whatever palette
# noctalia sets on the terminal instead of fighting it. Other themes: `vivid themes`.
# Fallback: `dircolors` from GNU coreutils, present on every distro.
VIVID_THEME=ansi
if (( $+commands[vivid] )); then
    export LS_COLORS="$(vivid generate $VIVID_THEME)"
elif (( $+commands[dircolors] )); then
    eval "$(dircolors -b)"
fi
