# TODO

Cada tarea vive en una sola sección. Dentro de cada sección, el orden es la prioridad. Lo
terminado baja a «Hecho» con fecha. Lo de «Sistema» se hace en la máquina y, a la vez, se
escribe en `INSTALL.md` en su fase, con el porqué de cada paquete.

**En curso:** ghostty (probar unos días) → zsh segunda vuelta.

## Sistema

- [ ] **Hibernación**: imposible hoy. Swap de 16 G con clave aleatoria y sin `resume=`.
      Opciones: swap LUKS con clave fija en la raíz, o swapfile en `@swap` con
      `resume_offset`. Arrastra el hook `resume`, hoy en `mkinitcpio.conf` antes de
      `encrypt` y sin poder funcionar; el hook `btrfs` tampoco hace falta.
- [ ] **NVIDIA + Intel**: RTX 3050 Ti Mobile junto a Intel TigerLake UHD; solo mesa e
      intel-media-driver. Camino probable: nvidia-open-dkms, `nvidia-drm.modeset=1` para
      niri, PRIME render offload; envycontrol o supergfxctl para apagarla del todo.
- [ ] **Energía**: sin gestor (ni power-profiles-daemon, ni tlp, ni thermald).
      power-profiles-daemon es lo que noctalia muestra; decidir y activar.
- [ ] **Bluetooth dual con Windows**: compartir las claves de emparejamiento (chntpw
      sobre el registro, o bt-dualboot) para no re-emparejar en cada cambio de sistema.
- [ ] **Disco de Windows fijo**: `nvme0n1p3` (NTFS, 476 G). fstab con `ntfs3` del
      kernel, punto tipo `/mnt/windows`, `nofail`; desactivar el inicio rápido de Windows.
- [ ] **cups**: instalado y apagado. Activar `cups.socket`; avahi-daemon ya está activo.
- [ ] **firewalld**: instalado y apagado. Activar y abrir lo que se use (ssh, kdeconnect).
- [ ] **Escritorio en la guía**: no aparece nada de la interfaz. Instalado: niri, noctalia,
      noctalia-greeter + greetd (activado), xwayland-satellite, matugen, ghostty, kitty,
      gnome-keyring + seahorse, xdg-desktop-portal-gnome, mpvpaper.
- [ ] **Servicios en la guía**: `bluetooth`, `avahi-daemon`, `greetd` y los que salgan de
      los puntos anteriores, en los `systemctl enable` del chroot.
- [ ] **Auditoría de paquetes**: 74 instalados explícitamente que la guía no menciona. El
      que se quede entra en su fase con su comentario; el resto se desinstala.
      - Escritorio: niri noctalia noctalia-greeter greetd xwayland-satellite matugen
        xdg-desktop-portal-gnome gnome-keyring seahorse mpvpaper breeze-icons openbox
      - Terminales: ghostty kitty
      - Navegadores: vivaldi vivaldi-ffmpeg-codecs zen-browser-bin
      - Multimedia: mpv gst-libav gst-plugin-va gst-plugins-bad gst-plugins-ugly
        qt6-multimedia-ffmpeg intel-media-driver gpu-screen-recorder cava f3d resvg
      - Wine y juegos: wine-staging winetricks wine-gecko wine-mono bottles winegui vkd3d
        vkd3d-docs lib32-vkd3d ares
      - Drones / ArduPilot: ardupilot-mission-planner qgroundcontrol-bin python-wxpython
        python-scipy opencv gdal
      - Desarrollo: uv python-pip python-virtualenv ccache visual-studio-code-bin itstool
      - Utilidades CLI: fd trash-cli unrar patool toilet tealdeer vivid pacman-contrib
        rust-motd-bin hollywood exhibit qalculate-qt
      - Hardware: displaylink linux-firmware-intel lvm2 ddcutil
      - Fuentes: gsfonts opendesktop-fonts woff2-cascadia-code wqy-bitmapfont wqy-microhei
        wqy-zenhei
      - Remoto y repos: rustdesk blackarch-mirrorlist
      - Sin clasificar: gtk2 (probable resto de algo desinstalado)

## Dotfiles

- [ ] **zsh, segunda vuelta**: usarlo unos días y anotar aquí la fricción real; luego
      compararlo con otras configs públicas y copiar solo lo que la resuelva.
- [~] **ghostty**: paquete stow hecho el 2026-09-23 (fuente Nerd, padding, sin CSD para
      niri, shell integration con ssh-terminfo, copy-on-select al portapapeles, resize de
      splits sin tres modificadores). Falta usarlo unos días.
- [ ] **rust-motd**: paquete stow y que funcione al entrar por SSH, donde hoy no hay banner
      (fastfetch se salta en SSH desde `80-fastfetch.zsh`).
- [ ] **kitty**: paquete stow cuando llegue (mismo `^H` para Ctrl-Backspace que ghostty).
- [ ] **yazi**: paquete stow y arreglar la configuración.
- [ ] **niri + noctalia**: paquetes stow y ajustar. Hoy están configurados pobremente:
      niri con la plantilla por defecto (`prefer-no-csd` comentado, aunque ghostty ya
      asume `window-decoration = none`), y `~/.config/noctalia` vacío, con todo en
      `~/.local/state`. Decidir aquí también el tema de ghostty, que hoy lo impone noctalia
      y no convence.
- [ ] **starship**: rehacer la configuración desde cero.
- [ ] **atuin**: mejorar, solo si algo molesta al usarlo.
- [ ] **nvim**: nunca configurado; decidir si se usa junto a Helix.

## Documentación del repo

- [ ] URL real del repo en `README.md` y en la sección «Dotfiles» de `INSTALL.md`.
- [ ] Cada punto de «Sistema», al cerrarse, como pasos en su fase de `INSTALL.md`.

## Decisiones

- Plugins de zsh solo por zinit, no por pacman: un gestor, un `zinit update`, misma config
  en Ubuntu/Fedora.
- Completado: la caché de compinit dura 24 h; `compreset` la fuerza. Sin hook de pacman.
- Historial de zsh: empieza vacío el 2026-09-23 (nunca se guardó antes); atuin tiene todo
  lo anterior y responde a `Ctrl-R` y `↑`.
- Stow con `--no-folding` (`.stowrc`): nunca enlaces a directorios del repo.

## Hecho

- 2026-09-23 **zsh**: modularizado en `conf.d/NN-*.zsh` + `hosts/<hostname>.zsh`; historial
  arreglado; emacs + modo vi con Esc; cheatsheet (`keys`).
- 2026-09-23 **INSTALL.md**: revisión de comandos (pacstrap, nodatacow, chroot, XDG como
  root, paquetes renombrados, reflector); rEFInd a `docs/refind.md`; sección «Dotfiles»
  con stow y `etc/zsh/zshenv`.
- 2026-09-23 **tealdeer**: paquete stow con caché automática; `Alt-h` en zsh.
- 2026-09-23 **fastfetch**: logo de texto (The Legend of Zelda) centrado, colección en
  `text/` con `.txt`/`.ansi`, README del paquete.
