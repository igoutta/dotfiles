# TODO

Cada tarea vive en una sola sección. Dentro de cada sección, el orden es la prioridad. Lo
terminado baja a «Hecho» con fecha. Lo de «Sistema» se hace en la máquina y, a la vez, se
escribe en `INSTALL.md` en su fase, con el porqué de cada paquete.

**En curso**, en este orden: (1) pasada visual de niri + noctalia y usarla unos días; (2) sistema
pesado: NVIDIA, hibernación; (3) sistema menor: servicios, cups, firewalld, bluetooth, Windows,
user-dirs, portapapeles; (4) auditoría de paquetes; después ghostty y zsh segunda vuelta.

## Sistema

- [~] **Qué instalar y qué no** (inventario del 2026-09-24 contra lo que necesita un portátil ASUS
      con niri, Btrfs y LUKS; la base de audio, red, bluetooth, portales, llavero y polkit está
      completa). Decidido ese día; cada cosa entra en su fase de INSTALL.md al hacerse:
      - Instalando: `snapper snap-pac fwupd ffmpegthumbnailer webp-pixbuf-loader gvfs-mtp
        wl-clipboard` y `photoqt` (AUR) como visor de imágenes; hoy png y jpg abren con f3d, un
        visor 3D. Loupe descartado. snap-pac avisa en cada pacman hasta que exista la config de
        snapper (tarea «Snapper»). fwupd: `fwupdmgr get-devices`, luego `update`.
      - Con yazi como gestor principal, no Nautilus: `udiskie` sí. Nautilus solo monta un USB al
        pulsarlo en su barra lateral, que con yazi no existe; udiskie lo monta al conectarlo y
        avisa, y hay plugin de noctalia `aristides/udiskie` para la barra. El móvil por USB va
        con gvfs-mtp y `gio mount`. Carpetas y terminal: tarea «xdg» en Dotfiles.
      - No instalar: `orca` (lector de pantalla para invidentes; el texto a voz de verdad es la
        tarea «Texto a voz»), `asusctl`/`supergfxctl` (abajo), `swayidle`,
        `sound-theme-freedesktop`, `ttf-nerd-fonts-symbols`, `noto-fonts-cjk`: noctalia lleva
        idle, bloqueo y sonidos; FiraCode Nerd ya trae los símbolos; CJK solo si se lee chino,
        japonés o coreano.
      - Falta decidir, cada uno con tarea propia abajo: PDF, utilidad de discos, documentos de
        oficina, keepassxc.
      - Curiosidad, asusctl y supergfxctl: asusctl es un demonio (asusd) sobre el driver
        asus-wmi del kernel que añade curvas de ventilador, RGB del teclado, perfiles y límite
        de carga con interfaz (rog-control-center); aquí el kernel ya da perfiles, límite y luz
        de teclado. supergfxctl cambia el modo de la GPU (integrated, hybrid, vfio) descargando
        y cargando el driver NVIDIA, con cierre de sesión; en este portátil integrated deja sin
        señal el USB-C del tercer monitor.
- [ ] **Snapper**: analizado el 2026-09-24 en `docs/snapper.md` contrastando SysGuides (Fedora):
      configs `root` (pacman 20+5 importantes, una diaria 7 días) y `home` (12 h, 7 d, 4 sem),
      sin cuotas Btrfs, `~/.cache` y contenedores fuera como subvolúmenes, hook que copia
      `/boot` (vfat, fuera de Btrfs) tras cada kernel, drop-in de mkinitcpio que solo añade
      `grub-btrfs-overlayfs` (`resume` y `btrfs` se deciden con la hibernación), vuelta atrás
      renombrando `@`. Pendiente de discutir junto a la hibernación (hook `resume`). Todo en
      `etc/` y los pasos en «Mantenimiento» de INSTALL.md; falta ejecutarlos (sudo) y probar
      arrancar una instantánea desde GRUB. Después, valorar `snapper-rollback` (AUR).
- [ ] **Límite de carga 80 %**: `etc/tmpfiles.d/charge-limit.conf` preparado; instalar con la
      línea de la sección Dotfiles. Hoy marca 80 pero nada lo fija al arrancar.
- [ ] **Texto a voz**, necesario: `speech-dispatcher` (extra) como servicio de voz del sistema,
      que es lo que Zen/Firefox y las apps usan para «leer en voz alta», y `piper-tts` (AUR,
      `piper-tts-bin`) como motor neuronal local, con voces en español de rhasspy/piper-voices
      (es_MX y es_ES). Enganche: módulo de piper para speech-dispatcher en
      `~/.config/speech-dispatcher/`; probar con `spd-say "hola"`. Nada de orca.
- [ ] **Podman**, decidido: `podman podman-compose passt` (extra). Rootless: subuid/subgid para
      `ga` (`usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ga`), red con passt,
      almacén en `~/.local/share/containers` (el subvolumen `@containers` de la guía es el de
      root; valorar otro para el usuario). Fedora/Ubuntu: podman en sus repos.
- [ ] **KDE Connect**, decidido: `kdeconnect` (extra); `kdeconnectd` al entrar (spawn-at-startup
      en niri) y `kdeconnect-indicator` en la bandeja de noctalia (no hay plugin). Necesita
      firewalld con el servicio `kdeconnect` (puertos 1714-1764 tcp/udp): va con esa tarea.
- [ ] **PDF**: hoy los abre Vivaldi. Candidatos: papers (GNOME, coherente con adw-gtk3),
      zathura (teclas vi, ligero), sioyek (para papers técnicos). Decidir y `xdg-mime`.
- [ ] **Utilidad de discos**: gnome-disk-utility (LUKS, SMART, imágenes ISO) o solo
      `udisksctl`/`cryptsetup` en terminal. Decidir.
- [ ] **Documentos de oficina**: libreoffice-fresh (libre) u onlyoffice-bin (fiel a MS Office);
      o solo web. Decidir.
- [ ] **keepassxc**: sin decidir. Contraseñas hoy en el llavero de GNOME (seahorse); keepassxc
      añade base de datos portátil y navegador. Decidir.
- [ ] **Greeter, formulario abajo a la izquierda**: no se puede en 1.5.0, la última versión
      (2026-09-10). El formulario va siempre centrado; solo se colocan los botones de
      apagado (`power_buttons_position`) y el selector de esquema (`scheme_selector_position`),
      con valores `top-left`, `top-right`, `bottom-left`, `bottom-right` o `hidden`, en
      `[appearance]` de `etc/noctalia-greeter/greeter.toml`. Nadie lo ha pedido en GitHub:
      abrir sugerencia o revisar en cada versión nueva. Desenfoque del fondo tampoco existe.
      Translúcido: un bloque `[appearance.palette]` completo con `surface_variant` en
      `#RRGGBBAA` lo consigue, PERO en 1.5.0 una paleta en greeter.toml deja el greeter sin
      fondo: el código de esa versión toma paleta y fondos del mismo sitio y, si la paleta
      viene de greeter.toml, ya no mira los fondos de sync.toml (verificado por Gustavo dos
      veces el 2026-09-24; yo lo negué leyendo la rama main, que ya lo tiene separado). Para
      tener las dos cosas habría que declarar también los fondos en greeter.toml apuntando a
      los archivos que escribe el sync (`/var/lib/noctalia-greeter/wallpaper*.jpg`); sin probar.
- [ ] **SDDM con login animado**, posible: sí. SDDM 0.21 (extra) corre su greeter en Wayland
      con weston como compositor de quiosco y temas QML; `sddm-astronaut-theme` (AUR, o el
      script de su repo) pone vídeo o GIF de fondo con qt6-multimedia, ya instalado por PhotoQt,
      y trae variantes animadas (Pixel Sakura, Jake the Dog, Hyprland Kath) y teclado virtual.
      Precio:
      - `sddm` arrastra `xorg-server` aunque el greeter vaya en Wayland (+50 MB), más `weston`
        y `qt6-virtualkeyboard`.
      - Se pierde el greeter de noctalia: sync de paleta y fondos, `passwordless-sync` y
        `greeter.toml`; `auto_sync` a false. El tema lleva sus colores y fondo en
        `astronaut.conf`, versionable en `etc/`.
      - Nuevo en `etc/`: `sddm.conf.d/` (`DisplayServer=wayland`, `GreeterEnvironment` con
        `QT_WAYLAND_SHELL_INTEGRATION=layer-shell`, `InputMethod=qtvirtualkeyboard`,
        `Current=` el tema), `pam.d/sddm` con las líneas de gnome-keyring de `pam.d/greetd`, y
        `weston.ini` para girar el HDMI en la pantalla de entrada. Weston no verá el DP-2 de la
        NVIDIA; en el login da igual. Teclado latam: `XKB_DEFAULT_LAYOUT` en
        `GreeterEnvironment`, comprobar.
      - Cambio: `systemctl disable greetd && systemctl enable sddm`; volver atrás es lo inverso.
      Veredicto: hacerlo después de la pasada visual, si el login animado importa más que el
      greeter a juego con noctalia sin tocar nada. Sin Xorg no hay opción hoy: noctalia-greeter
      1.5.0 no admite vídeo.
- [ ] **NVIDIA + Intel**: RTX 3050 Ti Mobile junto a Intel TigerLake UHD; solo mesa e
      intel-media-driver. Restricción nueva (2026-09-24): el USB-C con DisplayPort está
      cableado a la NVIDIA, así que apagarla del todo (envycontrol integrated) deja sin señal
      el tercer monitor; hoy lo sirve nouveau con GSP. El driver propietario solo hace falta
      para CUDA y juegos (wine, ares); para la salida de vídeo nouveau ya basta.
      Camino si se instala: nvidia-open-dkms, `nvidia-drm.modeset=1`, PRIME render offload;
      envycontrol o supergfxctl solo en modo híbrido, nunca integrated.
- [ ] **Reinstalación de Arch**, al terminar los dotfiles. La guía ya está corregida (2026-09-24):
      dos particiones (ESP de 1 G en `/efi` y un LUKS2), LVM dentro del LUKS con swap de 34 G
      redimensionable y raíz Btrfs, `/boot` como directorio de `@` (cifrado y dentro de las
      instantáneas), ranura PBKDF2 para GRUB y clave de archivo Argon2id en el initramfs para no
      teclear dos veces, `cryptodisk` antes de `grub-install`, contraseña solo con `[a-z0-9]`
      porque GRUB teclea en US sin eco. Con eso la hibernación y snapper quedan resueltos de
      raíz. Antes: copiar `/home` y `~/.ssh` fuera, exportar claves del llavero, lista de
      paquetes explícitos (`pacman -Qqe`) y probar la guía de cabo a rabo en una VM. Como el
      `cryptdevice=` va por `PARTLABEL`, `/etc/default/grub` ya no tiene nada de esta máquina:
      versionarlo en `etc/` al reinstalar.
      **Al reinstalar, quitar o ajustar lo que solo era de la instalación de 2026-08:**
      - `etc/pacman.d/hooks/95-bootbackup.hook`, su fila en `etc/README.md`, su línea en la
        sección Dotfiles y el párrafo «/boot fuera de Btrfs» de `docs/snapper.md`.
      - La tabla «Punto de partida» de `docs/snapper.md` y la nota del README sobre la máquina
        actual; el comentario de `91-grub-reinstall.hook` sobre la ESP en `/boot`.
      - Los ítems de esta lista que sean de esta máquina (greeter, tercer monitor, hibernación).
      - Comprobar que el `HOOKS` del drop-in y el de la guía siguen siendo el mismo.
- [ ] **Hibernación**: imposible en esta instalación y no se toca; la reinstalación la trae de
      serie (swap como volumen lógico dentro del LUKS, `resume=/dev/system/swap`). Descartes
      para esta máquina, por si vuelve la tentación: `openswap` (AUR, una clave más, 16 G de
      swap para 32 G de RAM), `sd-encrypt` (rompe el hook overlayfs de snapper, que es de
      busybox), swapfile (por preferencia), swap nueva encogiendo la raíz (una hora con riesgo
      para algo que la reinstalación da gratis). Al reinstalar: `suspend-then-hibernate` en
      logind y en el idle de noctalia.
- [ ] **Drop-in de mkinitcpio unificado**: el `HOOKS` del repo ya es el definitivo (con `lvm2`,
      sin `btrfs`), válido también aquí. Reinstalarlo y regenerar: `sudo install -Dm644
      etc/mkinitcpio.conf.d/dotfiles.conf /etc/mkinitcpio.conf.d/dotfiles.conf && sudo mkinitcpio -P`.
- [ ] **GRUB tras actualizarlo**: hoy grub pasó a 2.16 y la ESP sigue con 2.14 de agosto
      (`grub-mkconfig` corrió antes de la actualización). Ejecutar una vez `grub-install … --recheck`
      y `grub-mkconfig`, e instalar `etc/pacman.d/hooks/91-grub-reinstall.hook` para que pase
      solo en adelante.
- [ ] **Servicios en la guía**: `bluetooth` y `avahi-daemon` están activos y la guía no los
      activa; añadirlos a los `systemctl enable` del chroot (greetd ya está en «Escritorio»).
- [ ] **cups**: instalado y apagado. Activar `cups.socket`; avahi-daemon ya está activo.
- [ ] **firewalld**: instalado y apagado. Activar y abrir lo que se use (ssh, kdeconnect).
- [ ] **Bluetooth dual con Windows**: compartir las claves de emparejamiento (chntpw
      sobre el registro, o bt-dualboot) para no re-emparejar en cada cambio de sistema.
- [ ] **Disco de Windows fijo**: `nvme0n1p3` (NTFS, 476 G). fstab con `ntfs3` del
      kernel, punto tipo `/mnt/windows`, `nofail`; desactivar el inicio rápido de Windows.
- [ ] **user-dirs.dirs**: tiene `XDG_PROJECTS_DIR="$HOME/"` a mano, que apunta al home entero.
      No se versiona (lo reescribe xdg-user-dirs); revisar y documentar el comando.
- [ ] **Portapapeles, elegir a conciencia**: hoy lo lleva noctalia (`clipboard_enabled`):
      historial de 100 entradas con anclados y búsqueda, imágenes (`clipboard_image_action_command`
      para abrirlas, capturas como PNG), `clipboard_keep_from_closed_apps` para no perder lo
      copiado al cerrar la app, y almacenamiento cifrado con el llavero. Probar con casos
      reales antes de decidir: imagen del navegador a otra app, texto con formato (HTML),
      archivos desde yazi o Nautilus (uri-list), texto largo, y qué conserva el historial de
      cada uno al volver a pegarlo. `wl-clipboard` va de todas formas: Helix hoy copia por
      OSC 52 (`helix --health clipboard` → termcode, que ghostty entiende y sirve por SSH) y
      con wl-copy pasaría al proveedor nativo; yazi y los scripts usan `wl-copy`. Si
      noctalia se queda corto en formatos: copyq (Qt; todos los MIME, entradas editables,
      scripts) o cliphist + wl-clipboard (simple; texto e imágenes; selector desde el
      lanzador de noctalia). wl-clip-persist sobra: lo cubre `keep_from_closed_apps`.
      La decisión va a la fase «Escritorio» de INSTALL.md y a `00-shell.toml`.
- [ ] **Tercer monitor (DP-2)**: verificado el 2026-09-24. No es DisplayLink: el ASUS MB169CK
      va por DisplayPort sobre USB-C, y ese puerto cuelga de la NVIDIA (nouveau con GSP), no
      de evdi. niri no renderiza en nouveau («software EGL renderers are skipped») y pinta en
      la Intel copiando cada fotograma; conectado, con modo, EDID y DPMS On, sin errores.
      Declarado en `niri/outputs.kdl` a la derecha del HDMI. Falta: decidir su sitio real
      (`position`), y confirmar que `displaylink` y `evdi-dkms` no sirven para nada más
      antes de desinstalarlos (auditoría).
- [ ] **Auditoría de paquetes**: 71 instalados explícitamente que la guía no menciona. El
      que se quede entra en su fase con su comentario; el resto se desinstala.
      Además, `pacman -Qtdq` lista 38 huérfanos: 11 `-debug` de compilar AUR con la opción
      `debug` de makepkg, y 27 herramientas de compilar (cmake, meson, rust, go, nodejs,
      nasm, yasm…) que el helper de AUR dejó como makedepends. Revisar y `pacman -Rns`;
      `nodejs` se resuelve en «Node para Claude».
      - Escritorio: ya en la fase «Escritorio» de INSTALL.md (niri noctalia noctalia-greeter
        greetd xwayland-satellite xdg-desktop-portal-gnome gnome-keyring seahorse mpvpaper
        polkit-gnome).
      - Terminales: ghostty kitty
      - Navegadores: vivaldi vivaldi-ffmpeg-codecs zen-browser-bin
      - Multimedia: mpv gst-libav gst-plugin-va gst-plugins-bad gst-plugins-ugly
        qt6-multimedia-ffmpeg intel-media-driver gpu-screen-recorder cava f3d resvg
      - Wine y juegos: wine-staging winetricks wine-gecko wine-mono bottles winegui vkd3d
        vkd3d-docs lib32-vkd3d ares
      - Drones / ArduPilot: ardupilot-mission-planner qgroundcontrol-bin python-wxpython
        python-scipy opencv gdal openbox gtk2 (openbox: gestor de ventanas del Xwayland con
        ventana raíz que lanza `~/.local/bin/mission-planner`; gtk2: lo cargan
        System.Windows.Forms de mono y SkiaSharp.Views.Gtk de Mission Planner)
      - Desarrollo: uv python-pip python-virtualenv ccache visual-studio-code-bin itstool
        (mise ya en «Desarrollo»)
      - Utilidades CLI: fd trash-cli unrar patool toilet tealdeer vivid pacman-contrib
        rust-motd-bin exhibit qalculate-qt
      - Hardware: linux-firmware-intel lvm2 (ddcutil ya en «Escritorio»). Sobran salvo otro aparato DisplayLink:
        displaylink evdi-dkms (el MB169CK no los usa; ver «Tercer monitor»)
      - Fuentes: gsfonts opendesktop-fonts woff2-cascadia-code wqy-bitmapfont wqy-microhei
        wqy-zenhei
      - Remoto y repos: rustdesk blackarch-mirrorlist

## Dotfiles

- [~] **niri + noctalia + gtk**: paquetes hechos el 2026-09-24 (ver Hecho); el login por
      greetd con la config declarativa y `adw-gtk-theme` ya se probaron ese día. Falta:
      - Fondos de vídeo: no estaba roto. Con vídeo asignado noctalia retira su capa de fondo y
        las imágenes no se ven hasta parar el vídeo (Stop / `clear-all`); documentado en el
        README de noctalia el 2026-09-24. Falta `sudo pacman -S socat` si se usan presentaciones
        (ya en INSTALL.md) y decidir `extract_last_frame`.
      - Teclas Fn del TUF, para el futuro: comprobar con `wev` qué keysyms llegan (luz del teclado
        `XF86KbdBrightnessUp/Down`, touchpad `XF86TouchpadToggle`, cambio de pantalla
        `XF86Display`, perfil, avión) y atarlas en `binds.kdl`: luz del teclado a `noctalia msg
        keyboard-backlight-up/down`, las demás a lo que corresponda. Brillo y volumen ya están.
      - Usarlo unos días: paleta Ayu Red vs Vesper, `Mod+Alt+Esc` para bloquear, `Mod+N`
        notificaciones, `Mod+F1` chuleta en pantalla.
      - Pasada visual, con los valores medidos el 2026-09-24. Radios: niri 20 px, barra 12,
        esquinas de pantalla apagadas → unificar y encender `screen_corners` al mismo radio.
        Márgenes: gaps de niri 16, barra pegada al borde → barra flotante con margen 16.
        Transparencia: barra opaca, dock 0.88, ghostty 0.7 con blur → barra y paneles a
        ~0.85 con el blur de `rules.kdl`. Sombras: noctalia sí, niri no → `shadow { on }` en
        `layout.kdl`. Bordes: dejar el anillo de foco de niri (4 px) como único borde.
        Probar `transparency_mode` en vivo desde los ajustes de noctalia antes de escribirlo
        al TOML.
- [~] **ghostty**: paquete stow hecho el 2026-09-23 (fuente Nerd, padding, sin CSD para
      niri, shell integration con ssh-terminfo, copy-on-select al portapapeles, resize de
      splits sin tres modificadores). Falta usarlo unos días.
- [ ] **bin**: paquete stow para `~/.local/bin`. Hoy solo `mission-planner`, sin versionar y
      propiedad de root (`chown ga:ga`). Arranca un Xwayland con ventana raíz en `:10` con
      openbox dentro y lanza ahí Mission Planner (mono), porque bajo xwayland-satellite los
      menús de WinForms no se dibujan. Comentarios al español; revisar
      `LIBGL_ALWAYS_SOFTWARE=1` cuando esté NVIDIA.
- [ ] **zsh, segunda vuelta**: usarlo unos días y anotar aquí la fricción real; luego
      pasar los comentarios de `conf.d/*.zsh` y `.zshenv` al español (hoy en inglés); luego
      compararlo con otras configs públicas y copiar solo lo que la resuelva.
- [ ] **rust-motd**: paquete stow y que funcione al entrar por SSH, donde hoy no hay banner
      (fastfetch se salta en SSH desde `80-fastfetch.zsh`).
- [ ] **yazi**: paquete stow y arreglar la configuración.
- [ ] **kitty**: desinstalar, `sudo pacman -Rns kitty`. No se usa y ghostty ya está integrado
      (tema por noctalia, shell integration, GTK4). En velocidad real están a la par: los dos
      renderizan en GPU; kitty gana en pruebas sintéticas de caudal, no en uso. Con él se va
      `kitty-open.desktop`, que abría las carpetas.
- [ ] **starship**: rehacer la configuración desde cero.
- [ ] **atuin**: mejorar, solo si algo molesta al usarlo.
- [ ] **nvim**: nunca configurado; decidir si se usa junto a Helix.

## Documentación del repo

- [ ] URL real del repo en `README.md` y en la sección «Dotfiles» de `INSTALL.md`.
- [ ] `INSTALL.md` supera las 500 líneas: partirlo en capítulos bajo `docs/` (regla de
      modularizar), dejando en la raíz el índice.
- [ ] Cada punto de «Sistema», al cerrarse, como pasos en su fase de `INSTALL.md`.
- [ ] **Optimizar INSTALL.md**, futuro lejano, cuando la auditoría de paquetes esté cerrada:
      releerlo de principio a fin, quitar repeticiones, dejar cada fase con un solo bloque por
      tipo (paquetes, servicios, archivos de `etc/`), y decidir si los bloques de comandos se
      convierten en un script reproducible o siguen siendo guía comentada.

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
- Gestor de archivos principal: yazi en ghostty, Nautilus solo de apoyo (arrastrar, diálogos).
  Visor de imágenes: PhotoQt. Instantáneas: snapper + snap-pac, no timeshift.
- Idioma: interfaces en inglés (`LC_MESSAGES=en_US` con `LANG=es_EC`; `lang = "en"` en
  noctalia, cuya traducción va al 79 %; niri no tiene idioma). En español solo lo del repo:
  chuletas, comentarios, README, títulos de `Mod+F1` y commits.

## Hecho

- 2026-09-24 **xdg**: paquete stow con `mimeapps.list` (imágenes en PhotoQt, carpetas en yazi
  dentro de ghostty, web en Zen), `yazi-ghostty.desktop` y `xdg-terminals.list` para
  xdg-terminal-exec (paquete pendiente de instalar: en «Escritorio» de INSTALL.md).
- 2026-09-24 **i2c y energía**: `ga` en el grupo `i2c` (brillo externo por ddcutil);
  power-profiles-daemon activo (equilibrado); ambos en la fase «Escritorio» de INSTALL.md.
- 2026-09-24 **Node para Claude**: `nodejs` de pacman fuera (era dependencia de una compilación
  de AUR del 23, nada lo usaba); `mise` de pacman con paquete stow `mise/` (node LTS, pnpm con
  `minimumReleaseAge`, shims en `environment.d`), activado en `60-tools.zsh`; fase
  «Desarrollo» en INSTALL.md.
- 2026-09-24 **Limpieza del escritorio**: a la papelera (`trash-put`, recuperable con `trash-restore`)
  las configs GTK y xsettingsd de KDE apartadas, la config de niri anterior, el `settings.toml`
  de noctalia previo a la declarativa y la copia entera de su estado. Quedan los paquetes.
- 2026-09-24 **Greeter**, verificado tras volver a entrar: mostraba el sync del 2026-09-02 porque `pkexec` no tenía agente de
  polkit en la sesión. `polkit-gnome` instalado y en `niri/startup.kdl`; regla
  `noctalia-greeter passwordless-sync enable ga`; `auto_sync` en `00-shell.toml`; sync
  aplicado (Ayu Red, fondos, escala 1, HDMI a 90°); `etc/noctalia-greeter/greeter.toml` y
  fase «Escritorio» de INSTALL.md con todo ello. `greeter.toml` instalado en `/var/lib/noctalia-greeter`.
- 2026-09-24 **Restos de KDE, paquetes**: `breeze-icons` y `matugen` desinstalados (Adwaita trae los
  iconos de ghostty; noctalia 5 genera la paleta sin matugen). openbox y gtk2 se quedan por
  Mission Planner.
- 2026-09-24 **Limpieza**: `pacman -Rns hollywood` (se llevó byobu, tmux, htop, tree, plocate,
  moreutils y otros que solo él requería); `~/.config/byobu` y los `.bash*` del home
  borrados, nada los leía (shell de login zsh, contenido igual al de `/etc/skel`).
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
