# Prompt: starship, configured in $STARSHIP_CONFIG (set in .zshenv).
#
# Why this is so short now: the old config pulled starship a second time through zinit
# (from GitHub releases) and loaded OMZ's async_prompt library, which wraps precmd to
# render OMZ themes asynchronously. Starship installs its own precmd, the two wrapped
# each other, recursion blew past zsh's function-nesting limit, and FUNCNEST=100 was
# the band-aid. One prompt system, one precmd, no limit needed.
#
# Arch/Fedora: `starship` package. Ubuntu: `curl -sS https://starship.rs/install.sh | sh`
# or cargo; not in apt.
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
else
    # Minimal fallback so a shell without starship still has a usable prompt.
    PROMPT='%F{cyan}%~%f %F{green}❯%f '
fi
