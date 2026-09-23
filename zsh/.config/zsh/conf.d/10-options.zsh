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

# Colours for ls/eza/completion listings. `dircolors` is GNU coreutils, present on
# Arch, Ubuntu and Fedora alike. Swap for `vivid generate <theme>` if you install vivid.
(( $+commands[dircolors] )) && eval "$(dircolors -b)"
