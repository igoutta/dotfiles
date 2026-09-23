# TODO

## Ahora

- [x] **zsh**: arreglar, reorganizar y modularizar la configuración (2026-09-23:
      `conf.d/NN-*.zsh` + `hosts/<hostname>.zsh`; historial arreglado, modo vi con Esc).
- [ ] **zsh, segunda vuelta**: usarlo unos días, anotar aquí la fricción real y entonces
      compararlo con otras configs públicas para ver qué merece copiarse.
- [ ] **ghostty**: añadir como paquete stow y arreglar el setup actual (fuente con iconos,
      colores de noctalia, teclas coherentes con `65-keybinds.zsh`).
- [ ] **SSH sin banner**: fastfetch ya no se muestra por SSH (`80-fastfetch.zsh`); añadir
      **rust-motd** como paquete stow y hacer que funcione al entrar por SSH.
- [~] **INSTALL.md**: revisión de comandos hecha (2026-09-23). Quedan decisiones:
      - `resume` en HOOKS de mkinitcpio con swap de clave aleatoria no sirve; quitarlo o
        pasar a swap con clave fija si se quiere hibernar. El hook `btrfs` tampoco hace falta.
      - Bloque de rEFInd (líneas de `refind-install`): resto de otra máquina; borrar o
        marcar como alternativa.
      - Plugins de zsh por pacman (autosuggestions, syntax-highlighting, completions) son
        redundantes con zinit: quitar de pacstrap o quitar de zinit.
      - Servicios: el sistema tiene `bluetooth` y `avahi-daemon` activos y la guía no los
        activa; `cups` y `firewalld` se instalan pero están desactivados.
      - `reflector -c '...,*'`: comprobar que acepta `*` como país.
      - 74 paquetes instalados explícitamente que la guía no menciona (escritorio niri +
        noctalia + greetd, ghostty, kitty, wine, ardupilot, navegadores…): decidir cuáles
        entran y en qué fase, con su comentario.
- [ ] **fastfetch**: buscar una imagen slim o un ASCII adecuado con un
      esquema de colores vistoso; definir el setup final.

## Después

- [ ] **starship**: rehacer la configuración desde cero.
- [ ] **atuin**: mejorar la configuración, solo si algo molesta al usarlo.
- [ ] **yazi**: añadir como paquete stow y arreglar la configuración.
- [ ] **niri + noctalia**: añadir como paquetes stow y ajustar.
- [ ] **nvim**: nunca se ha instalado ni configurado; decidir si se usa junto a Helix.
- [ ] **kitty**: añadir como paquete stow cuando llegue (mismo `^H` para Ctrl-Backspace
      que ghostty, ver `65-keybinds.zsh`).

## Decisiones tomadas (por si se quieren revisar)

- Completado: la caché de compinit dura 24 h; `compreset` la fuerza. No hay hook de pacman.
- Historial de zsh: empieza vacío desde 2026-09-23 (nunca se guardó antes); atuin tiene
  todo lo anterior y es quien responde a `Ctrl-R` y `↑`.

## Pendiente del repo

- [x] Documentar en `INSTALL.md` cómo desplegar los dotfiles con `stow` (2026-09-23,
      sección «Dotfiles»; `/etc/zsh/zshenv` vive en `etc/`).
- [ ] Poner la URL real del repo en la sección «Dotfiles» de `INSTALL.md`.
