# Zsh's own history file. Atuin (see 60-tools.zsh) keeps its own database on top of
# this, but the plain file is still what `history`, `!!` and non-atuin shells use.
#
# Bug this replaces: SAVEHIST used to be assigned the *text* of $HISTFILE, which is not
# a number, so zsh treated it as 0 and never wrote history to disk.

HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=50000                # lines kept in memory
SAVEHIST=50000                # lines written to $HISTFILE

setopt SHARE_HISTORY          # share between sessions; implies INC_APPEND + EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS     # strip superfluous whitespace
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_IGNORE_DUPS       # skip a command identical to the previous one
setopt HIST_EXPIRE_DUPS_FIRST # trim duplicates before unique entries when full
setopt HIST_SAVE_NO_DUPS      # never write duplicates to the file
setopt HIST_FIND_NO_DUPS      # skip duplicates when searching
setopt HIST_VERIFY            # show the expanded !-line before running it
