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
- [~] **INSTALL.md**: revisión de comandos hecha (2026-09-23). rEFInd movido a
      `docs/refind.md`; plugins de zsh solo por zinit (decidido: un solo gestor, un solo
      `zinit update`, misma config en Ubuntu/Fedora). Quedan:
      - 74 paquetes instalados explícitamente que la guía no menciona. Por grupos; cada
        uno que se quede entra en su fase con su comentario, el resto se desinstala:
        - Escritorio (ya en «Sistema»): niri noctalia noctalia-greeter greetd
          xwayland-satellite matugen xdg-desktop-portal-gnome gnome-keyring seahorse
          mpvpaper breeze-icons openbox
        - Terminales: ghostty kitty
        - Navegadores: vivaldi vivaldi-ffmpeg-codecs zen-browser-bin
        - Multimedia: mpv gst-libav gst-plugin-va gst-plugins-bad gst-plugins-ugly
          qt6-multimedia-ffmpeg intel-media-driver gpu-screen-recorder cava f3d resvg
        - Wine y juegos: wine-staging winetricks wine-gecko wine-mono bottles winegui
          vkd3d vkd3d-docs lib32-vkd3d ares
        - Drones / ArduPilot: ardupilot-mission-planner qgroundcontrol-bin python-wxpython
          python-scipy opencv gdal
        - Desarrollo: uv python-pip python-virtualenv ccache visual-studio-code-bin itstool
        - Utilidades CLI: fd trash-cli unrar patool toilet tealdeer vivid pacman-contrib
          rust-motd-bin hollywood exhibit qalculate-qt
        - Hardware: displaylink linux-firmware-intel lvm2 ddcutil
        - Fuentes: gsfonts opendesktop-fonts woff2-cascadia-code wqy-bitmapfont
          wqy-microhei wqy-zenhei
        - Remoto y repos: rustdesk blackarch-mirrorlist
        - Sin clasificar: gtk2
      - Cada punto de la sección «Sistema» de abajo tiene que acabar como pasos en la guía.
- [ ] **fastfetch**: buscar una imagen slim o un ASCII adecuado con un
      esquema de colores vistoso; definir el setup final.

## Sistema (pendiente en la máquina y en la guía)

Cada uno se hace en el sistema actual y, a la vez, se escribe en `INSTALL.md` en la fase
que le toque, con el porqué de cada paquete. Sin prisa, uno por uno.

- [ ] **Escritorio en la guía**: hoy no aparece nada de la interfaz. Instalado y activo:
      niri, noctalia, noctalia-greeter + greetd (activado), xwayland-satellite, matugen,
      ghostty, kitty, gnome-keyring + seahorse, xdg-desktop-portal-gnome, mpvpaper.
- [ ] **Hibernación**: imposible con el swap actual (16 G, `cryptswap` con clave aleatoria
      en cada arranque, sin `resume=` en la cmdline). Opciones: swap LUKS con clave fija
      guardada en la raíz, o swapfile en un subvolumen `@swap` con `resume_offset`. Va
      ligado al hook `resume`, que hoy está en `mkinitcpio.conf` sin poder funcionar y
      además antes de `encrypt`; el hook `btrfs` tampoco hace falta.
- [ ] **Energía**: no hay ningún gestor (ni power-profiles-daemon, ni tlp, ni thermald).
      power-profiles-daemon es lo que noctalia sabe mostrar; decidir y activar.
- [ ] **NVIDIA + Intel**: RTX 3050 Ti Mobile (GA107) junto a Intel TigerLake UHD. Solo
      están mesa e intel-media-driver; sin driver nvidia. Camino probable: nvidia-open-dkms
      (linux-headers ya va en pacstrap), `nvidia-drm.modeset=1` para niri/Wayland, PRIME
      render offload para usar la NVIDIA bajo demanda; envycontrol o supergfxctl si se
      quiere apagarla del todo. Añadir `nvidia` a MODULES del initramfs si se elige early KMS.
- [ ] **Bluetooth dual con Windows**: el servicio está activo y la guía no lo activa.
      Falta compartir las claves de emparejamiento con Windows (extraerlas del registro con
      chntpw o usar bt-dualboot) para no re-emparejar en cada cambio de sistema.
- [ ] **Disco de Windows en un sitio fijo**: `nvme0n1p3` (NTFS, 476 G) y su EFI en
      `nvme0n1p1`. Montaje por fstab con `ntfs3` del kernel (o ntfs-3g), punto fijo tipo
      `/mnt/windows`, `nofail`, y desactivar el inicio rápido de Windows para que no quede
      sucio.
- [ ] **cups**: instalado y desactivado. Activar `cups.socket`; avahi-daemon ya está
      activo (y tampoco aparece en la guía) para descubrir impresoras de red.
- [ ] **firewalld**: instalado y desactivado. Activar y abrir lo que se use (ssh,
      kdeconnect).
- [ ] **Servicios en la guía**: añadir `bluetooth`, `avahi-daemon`, `greetd` y los que
      salgan de los puntos anteriores a los `systemctl enable` del chroot.

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
