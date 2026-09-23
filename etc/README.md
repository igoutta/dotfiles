# etc/

Archivos del sistema (fuera de `$HOME`) que este repo también versiona. **No son paquetes
stow**: se copian a mano con `install`, como indica la sección «Dotfiles» de `INSTALL.md`.

| Archivo | Destino | Para qué |
|---|---|---|
| `zsh/zshenv` | `/etc/zsh/zshenv` | Define `ZDOTDIR=~/.config/zsh` para todos los usuarios; sin él zsh busca `~/.zshrc` y la config de `zsh/` no carga. Ubuntu/Fedora: mismo destino; si se prefiere no tocar `/etc`, crear `~/.zshenv` con `export ZDOTDIR="$HOME/.config/zsh"`. |
