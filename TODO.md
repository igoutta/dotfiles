# TODO

Cada tarea vive en una sola sección. Dentro de cada sección, el orden es la prioridad. Lo
terminado baja a «Hecho» con fecha. Lo de «Sistema» se hace en la máquina y, a la vez, se
escribe en `INSTALL.md` en su fase, con el porqué de cada paquete.

**En curso:** niri + noctalia + gtk (probar unos días; ver decisiones) → ghostty → zsh segunda vuelta.

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
- [ ] **Servicios en la guía**: `bluetooth` y `avahi-daemon` están activos y la guía no los
      activa; añadirlos a los `systemctl enable` del chroot (greetd ya está en «Escritorio»).
- [ ] **ddcutil**: noctalia lo usa para el brillo del monitor externo pero `ga` no está en el
      grupo `i2c`. O `sudo usermod -aG i2c ga`, o `enable_ddcutil = false` en `00-shell.toml`.
- [ ] **Tercer monitor (DP-2)**: aparece en el estado de noctalia y hay displaylink + evdi
      instalados; el soporte de DisplayLink en niri no está verificado. Al conectarlo, bloque
      `output` en `niri/outputs.kdl`.
- [ ] **user-dirs.dirs**: tiene `XDG_PROJECTS_DIR="$HOME/"` a mano, que apunta al home entero.
      No se versiona (lo reescribe xdg-user-dirs); revisar y documentar el comando.
- [ ] **Restos de KDE**: apartados en `~/.config/kde-restos.bak-2026-09-24`; borrar cuando
      todo GTK se vea bien. Desinstalar `breeze-icons`, `gtk2`, `openbox`, `matugen`.
- [ ] **wl-clipboard**: noctalia cubre el portapapeles; decidir si se instala solo por
      comodidad en scripts (`wl-copy`/`wl-paste`).
- [ ] **Auditoría de paquetes**: 74 instalados explícitamente que la guía no menciona. El
      que se quede entra en su fase con su comentario; el resto se desinstala.
      - Escritorio: ya en la fase «Escritorio» de INSTALL.md (niri noctalia noctalia-greeter
        greetd xwayland-satellite xdg-desktop-portal-gnome gnome-keyring seahorse mpvpaper).
        Sobran: breeze-icons openbox matugen
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
- [~] **niri + noctalia + gtk**: paquetes hechos el 2026-09-24 (ver Hecho). Falta usarlos
      unos días: paleta Ayu Red vs Vesper, `Mod+Alt+Esc` para bloquear, `Mod+N`
      notificaciones, y confirmar que el greeter tomó la paleta (`noctalia msg greeter-sync`).
- [ ] **starship**: rehacer la configuración desde cero.
- [ ] **atuin**: mejorar, solo si algo molesta al usarlo.
- [ ] **nvim**: nunca configurado; decidir si se usa junto a Helix.

## Documentación del repo

- [ ] URL real del repo en `README.md` y en la sección «Dotfiles» de `INSTALL.md`.
- [ ] `INSTALL.md` supera las 500 líneas: partirlo en capítulos bajo `docs/` (regla de
      modularizar), dejando en la raíz el índice.
- [ ] Cada punto de «Sistema», al cerrarse, como pasos en su fase de `INSTALL.md`.

## Decisiones

- Plugins de zsh solo por zinit, no por pacman: un gestor, un `zinit update`, misma config
  en Ubuntu/Fedora.
- Completado: la caché de compinit dura 24 h; `compreset` la fuerza. Sin hook de pacman.
- Historial de zsh: empieza vacío el 2026-09-23 (nunca se guardó antes); atuin tiene todo
  lo anterior y responde a `Ctrl-R` y `↑`.
- Stow con `--no-folding` (`.stowrc`): nunca enlaces a directorios del repo.
- Paleta del escritorio: comunidad «Ayu Red» sobre negro puro, no derivada del fondo.
- Noctalia se configura en `~/.config/noctalia/*.toml` (repo); `settings.toml` del state es
  desechable y solo debe guardar estado de ejecución. Plugin `niri-displays` fuera: las
  salidas se declaran en `niri/outputs.kdl`.
- Modularizar: todo archivo de configuración largo se parte por temas.

## Hecho

- 2026-09-24 **Escritorio**: paquetes `niri` (config modular, outputs, sin CSD, teclas sin
  programas rotos, chuleta), `noctalia` (declarativo en 4 TOML, paleta Ayu Red, README con
  las dos capas, chuleta) y `gtk` (adw-gtk3, Adwaita, hooks de noctalia); `etc/` con greetd,
  PAM y pam_env; fase «Escritorio» en INSTALL.md.
- 2026-09-23 **zsh**: modularizado en `conf.d/NN-*.zsh` + `hosts/<hostname>.zsh`; historial
  arreglado; emacs + modo vi con Esc; cheatsheet (`keys`).
- 2026-09-23 **INSTALL.md**: revisión de comandos (pacstrap, nodatacow, chroot, XDG como
  root, paquetes renombrados, reflector); rEFInd a `docs/refind.md`; sección «Dotfiles»
  con stow y `etc/zsh/zshenv`.
- 2026-09-23 **tealdeer**: paquete stow con caché automática; `Alt-h` en zsh.
- 2026-09-23 **fastfetch**: logo de texto (The Legend of Zelda) centrado, colección en
  `text/` con `.txt`/`.ansi`, README del paquete.
