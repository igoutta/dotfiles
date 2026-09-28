# TODO

Cada tarea vive en una sola sección. Dentro de cada sección, el orden es la prioridad. Lo
terminado baja a «Hecho» con fecha. Lo de «Sistema» se hace en la máquina y, a la vez, se
escribe en `INSTALL.md` en su fase, con el porqué de cada paquete.

**En curso**, en este orden: (1) OneDrive (2026-09-28); (2) sistema menor: servicios, cups,
firewalld, bluetooth, Windows, user-dirs, portapapeles; (3) auditoría de paquetes; después
ghostty y zsh segunda vuelta. NVIDIA y la pasada visual quedaron cerradas; la hibernación
espera a la reinstalación.

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
- [ ] **Greeter, formulario abajo a la izquierda**: no se puede en 1.5.0 ni en 1.6.0 (revisado
      el 2026-09-28 en su ejemplo de config). Desde ese día el formulario va solo en eDP-1
      (`[output] name`; las demás salidas se apagan durante el greeter). El formulario va
      siempre centrado; solo se colocan los botones de
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
- [ ] **ghostmirror, aplicar los units revisados** (análisis cerrado el 2026-09-25, ver Hecho):
      `sudo install -Dm644 -t /etc/systemd/system etc/systemd/system/ghostmirror*.{service,timer} &&
      sudo systemctl disable ghostmirror.service ghostmirror-deep.service && sudo systemctl
      daemon-reload && sudo systemctl restart ghostmirror.timer ghostmirror-deep.timer && sudo
      systemctl start ghostmirror-deep.service ghostmirror.service`; luego `head -20
      /etc/pacman.d/mirrorlist` debería mezclar Worldwide, EE. UU. y algo de Brasil o Chile.
- [~] **Temperatura**: el paquete de la CPU a 83-96 °C con poca carga y el ventilador a
      4000-4700 RPM (2026-09-25). thermald instalado y activo ese día. Veredictos, medidos:
      - **asusctl: no, y la culpa es del firmware, no del programa.** El kernel pide las curvas
        de ventilador al BIOS (316, 06/2025) y responde «sin datos» (`fan_curve_get_factory_default
        … failed: -61` en `journalctl -k`), así que no existe el hwmon `asus_custom_fan_curve` que
        `asusctl fan-curve` necesita; y `asus_armoury` avisa «No matching power limits», así que
        tampoco hay límites de potencia por Armoury. Lo que asusctl daría aquí (perfiles, límite
        de carga, RGB del teclado) ya lo hacen power-profiles-daemon, `charge-limit.conf` y sysfs.
        Descartados también los plugins `kv7499/asus-fan` (exige asusctl, solo muestra RPM) y
        `cleboost/asus-fans-controller-ec` (escribe el EC a ciegas, probado en el TUF A17, su
        binario no está en repos): el ventilador no es la palanca.
      - **La palanca es la potencia, y ya está montada**: thermald con `--adaptive` aplica las
        tablas térmicas del firmware (DPTF) según el perfil, por RAPL MMIO. Probado: al pasar a
        power-saver el PL1 baja de 65 a 28 W y el paquete de 83 a 75 °C en medio minuto. Tabla por
        perfil en la fase «Temperatura» de INSTALL.md. El XML propio que preparé se ignora en ese
        modo y se retiró del repo.
      - **Lo que calienta en vacío, medido a las 02:30**: con un 8 % de CPU en total el paquete
        estaba a 92-96 °C. (1) El fondo de vídeo: 4K a 30 fps con la gráfica Intel clavada a
        1450 MHz; en pausa bajó a 0 MHz y el paquete de 92 a 85 °C en medio minuto. Primero se
        recodificó la biblioteca a 1080p; descartado el mismo día: obliga a recodificar cada vídeo
        nuevo, y medido por el socket IPC resultó que lo caro eran los filtros por defecto de mpv,
        no el tamaño. Con `scale=bilinear dscale=bilinear dither=no correct-downscaling=no
        linear-downscaling=no sigmoid-upscaling=no` en `mpv_options` un 4K cuesta menos que el
        1080p con filtros por defecto, y lo mismo que el 1080p sin ellos (tabla en el README de
        noctalia); `video_directory` vuelve a los originales y `~/Videos/Wallpapers-1080p` (737 M)
        sobra. Se aplica al reiniciar noctalia y hay que volver a elegir el vídeo; mientras, las
        opciones ya van puestas por IPC en las dos instancias. Quedan caros HEVC y AV1 a 60 fps
        (tres vídeos): es el descodificador. (2) VS Code: el proceso de la ventana a 0,7
        núcleos de media desde el arranque, en parte por esta sesión de Claude dentro de VS Code;
        cpptools aparte. (3) La NVIDIA no: suspendida, ventilador parado, sensor a 0; estuvo
        encendida un tercio del arranque por las pruebas de prime-run y nvidia-smi.
      - **Perfil por defecto: power-saver**, fijado el 2026-09-25 (ppd lo recuerda entre
        arranques): 28-35 W, frena a 82 °C, sobra para editor y navegador; balanced para compilar.
        Fn+F5 cicla los tres perfiles desde el kernel (`platform_profile_cycle`) y el widget
        `power_profile` de la barra hace lo mismo con un clic. Si balanced sigue pareciendo
        caliente, la alternativa es un `thermal-conf.xml` propio con trip a 85 °C más un drop-in
        que quite `--adaptive`: tope fijo a cambio de perder la tabla por perfil.
      - **Pendiente, probar**: `auto_pause = "max"` en el plugin (pausa el vídeo con una ventana
        maximizada; niri 26.04 publica ese estado por `zwlr_foreign_toplevel`, pero solo para
        columnas en modo maximizado, no por ser anchas); medir vatios de verdad con `turbostat`
        (`linux-tools`; RAPL es solo root); undervolt, casi seguro bloqueado en el BIOS:
        `sudo pacman -S msr-tools && sudo modprobe msr && sudo rdmsr -f 20:20 0x194`, `1` es
        bloqueado; el panel a 60 Hz en vez de 144 en `outputs.kdl` ahorra algo más con el vídeo.
      - **Ventilador a tope a mano**: `echo 0 | sudo tee /sys/devices/platform/asus-nb-wmi/hwmon/hwmon*/pwm1_enable`
        (`2` vuelve a automático); es lo único que el firmware permite sobre el ventilador.
      - **Hardware**: 4700 RPM con 92 °C y un 8 % de CPU es propio de polvo o pasta seca (2021).
        Limpiar y repastar, mejor con pad de cambio de fase (PTM7950), vale más que cualquier
        software. Y la base: la entrada de aire está debajo; nada de camas ni telas.
      - Puntual: `code` y `cpptools` consumían el 60 % de un núcleo indexando; revisar qué
        indexa la extensión de C++.
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
- [~] **USB en la barra**: plugin `aristides/udiskie` activado el 2026-09-25 (widget `usb`, oculto
      sin dispositivos; monta y expulsa con `udisksctl`, avisa por notificación). `udiskie`
      instalado ese día; falta probar con un USB. En la barra van también `temp`, `cpu` y
      `power_profile`, widgets nativos de noctalia; el plugin system-monitor era redundante.
- [ ] **Teclado RGB sin asusctl**: el kernel expone
      `/sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/kbd_rgb_mode` («cmd modo R G B
      velocidad»: cmd 1 guarda en BIOS, modo 0 color fijo) y `kbd_rgb_state` («cmd arranque activo
      suspensión teclado»). Naranja fijo de la paleta: `echo "1 0 255 96 0 0" | sudo tee …/kbd_rgb_mode`;
      como se guarda en el BIOS basta una vez, o una línea `w` en tmpfiles.d como charge-limit.
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
      Desde el 2026-09-25 lo sirve el driver nvidia-open (fase «GPU»). Disposición nueva ese
      día en `niri/outputs.kdl`: HDMI a la izquierda, portátil en medio y este a la derecha;
      la alternativa, debajo del HDMI, va comentada al lado. Funciona sin parpadeos en esa
      posición. Falta: fijar su sitio definitivo si al final va abajo,
      `noctalia msg greeter-sync` para que el greeter tome la disposición nueva, y confirmar
      que `displaylink` y `evdi-dkms` no sirven para nada más antes de desinstalarlos
      (auditoría).
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
      - Teclas Fn del TUF, hechas el 2026-09-25: Fn+F9 proyectar, Fn+F10 touchpad y Fn+F12 aviso
        del modo avión, sin atajos Mod repetidos (una tecla por acción); scripts en `niri/.local/bin`.
        Cadena verificada sin pulsar: keymap de asus-nb-wmi (0x61, 0x6B, 0x88), udev sin remapeos
        para este modelo y `xkbcli compile-keymap --layout latam` (XF86Display, XF86TouchpadToggle,
        XF86RFKill). Fn+F12 la invierte el kernel (`CONFIG_RFKILL_INPUT=y`). Falta pulsarlas una
        vez (hecho: Fn+F9 y Fn+F12 responden; Fn+F10 también, solo). Luz del
        teclado y Fn+F5 los hace asus-wmi. Duplicar pantalla necesita `wl-mirror` (instalado
        el 2026-09-25). Fn+F6, pantalla con X, apaga las pantallas: XF86ScreenSaver o
        XF86DisplayToggle según el firmware; una pulsación registrada dijo XF86ScreenSaver y
        queda solo esa. Fuera `Mod+Shift+P`, que venía de la plantilla de niri y duplicaba la
        misma acción. Mod+B abre o enfoca Zen y Mod+D, VS Code (`niri-focus-or-spawn`).
      - Usarlo unos días: paleta Ayu Red vs Vesper, `Mod+Alt+Esc` para bloquear, `Mod+N`
        notificaciones, `Mod+F1` chuleta en pantalla.
      - Pasada visual aplicada y aprobada el 2026-09-25: todo a 16 (gaps de niri,
        radio de ventanas antes 20, barra antes 12, dock, esquinas de pantalla encendidas),
        barra flotante a 16 px del borde y de los lados (antes pegada y con 100 a los lados),
        barra a 0.5 (como ghostty) y dock a 0.85 de opacidad, paneles en `transparency_mode = "soft"` y sombras de
        niri encendidas (`layout.kdl`). Aspecto de noctalia en su módulo nuevo `15-style.toml`.
        Si algo no gusta: `glass` o `solid` en los paneles, y el radio se cambia en los dos
        sitios (`rules.kdl` y `15-style.toml`). Ese mismo día: el overview ya no queda gris
        (`[backdrop] enabled` en noctalia, con el fotograma del vídeo difuminado) y ghostty
        translúcido deja ver el fondo (`draw-border-with-background false`: niri rellenaba
        detrás de la ventana con el color del anillo de foco).
        Después: la barra a 8 px del borde de arriba (16 la despegaba demasiado) y la derecha
        aligerada: fuera bluetooth y brillo (están en el centro de control), red y volumen solo
        con icono, multimedia oculto sin reproducción, bandeja en un botón, Claude solo con la
        ventana de 5 horas.
- [~] **ghostty**: paquete stow hecho el 2026-09-23 (fuente Nerd, padding, sin CSD para
      niri, shell integration con ssh-terminfo, copy-on-select al portapapeles, resize de
      splits sin tres modificadores). Falta usarlo unos días.
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

- 2026-09-28 **NVIDIA + Intel**, cerrado: driver `nvidia-open` 615 instalado el 2026-09-25 y verificado: nouveau
  fuera, `modeset`/`fbdev`, initramfs sin `kms`, GRUB con `PARTLABEL` y sin `udl`, niri
  renderizando en la Intel por ruta PCI, `vulkan-intel` y `vulkan-tools` puestos, la regla udev
  instalada y la GPU en `runtime_status=suspended` (su ventilador parado, su sensor a 0);
  `prime-run vulkaninfo` la lista junto a la Intel. Resuelto por el camino: mpvpaper caía con
  segfault en libnvidia-glcore y mantenía la RTX encendida (contexto Vulkan → NVIDIA, y libmpv
  cargando el interop CUDA); `30-plugins.toml` lo fija en la Intel por tres opciones. Dato
  nuevo: el HDMI y el DP-1 cuelgan de la Intel (`card1`); solo el USB-C (DP-2 y DP-3) va por la
  NVIDIA, así que un monitor por HDMI no la despierta. El monitor del USB-C por la NVIDIA,
  verificado ese día: estable y sin parpadeos. Cerrado también ese día: gpu-screen-recorder
  se queda en la Intel (`--info`: h264, hevc y hevc 10 bits por VA-API; NVENC despertaría la
  NVIDIA para lo mismo) y Mission Planner sin `LIBGL_ALWAYS_SOFTWARE=1` (su Xwayland da
  OpenGL 4.6 en la Intel; con la variable iba por llvmpipe, en la CPU). El script ya está en
  el paquete `bin/` (ver Hecho); HUD con GL por hardware comprobado en su log.
  Otro culpable de tener la NVIDIA encendida (2026-09-28: 1203 s activa y 2 suspendida
  en una sesión sin monitor en el USB-C): el monitor del sistema de noctalia elige NVML si
  al arrancar la NVIDIA está despierta, y al entrar siempre lo está; luego la consulta cada
  5 s. `[system.monitor] gpu_poll_seconds = 0` en `00-shell.toml` lo apaga: con la NVIDIA
  despierta al arrancar noctalia, se suspende a los 6 s y no vuelve.
- 2026-09-28 **Mensajes al entrar y salir**, cerrado (medidos el 2026-09-25), medidos en el journal; ninguno frena nada:
  - «Calling import-environment without a list of variable names is deprecated»: lo imprime
    `/usr/bin/niri-session` en la consola al pasar del greeter a niri. Es un aviso de systemd,
    y upstream sigue igual en main. Desde la contraseña: niri a los 0,5 s, la barra a los
    1,2 s y los vídeos a los 2 s. No tocar el script del paquete.
  - `pam_open_session: SERVICE_ERR` de greetd: solo al reiniciar o apagar desde la sesión.
    greetd relanza el greeter y logind se niega porque el apagado ya está en marcha. Tres
    veces este mes, nunca en un cierre de sesión normal. Inofensivo.
  - Bloq Num que se enciende y apaga varias veces al entrar: lo provoca RustDesk, no niri.
    Su servicio (`rustdesk.service`, de sistema) lanza `rustdesk --server` dos veces para
    el greeter y dos para `ga` al entrar, y lo relanza cada hora a los :13; cada vez crea un
    teclado virtual («RustDesk UInput Keyboard») y al aparecer invierte el Bloq Num global.
    Reproducido el 2026-09-25 matando el `--server` de `ga`: el LED de `input3::numlock`
    (teclado del portátil) pasó de 1 a 0 y se quedó así. Si no se usa el acceso sin
    vigilancia: `sudo systemctl disable --now rustdesk` y abrir RustDesk a mano cuando haga
    falta. Si se usa, no hay arreglo del lado de niri. Servicio desactivado el 2026-09-28
    (el paquete sigue): en ese arranque ningún teclado virtual de RustDesk y el LED de
    Bloq Num fijo en 1. Confirmado tras reiniciar el 2026-09-28: sin el vaivén, Bloq Num
    activo al entrar.
  - Hallazgo: el compositor del greeter (wlroots) renderiza en la NVIDIA («EGL vendor:
    NVIDIA» en `journalctl -b -t noctalia-greeter-compositor`), así que la despierta en cada
    arranque. Preparado el 2026-09-25: `etc/udev/rules.d/61-gpu-names.rules` crea
    `/dev/dri/igpu` y `/dev/dri/dgpu` (los `cardN` cambian y by-path lleva `:`), y
    `etc/greetd/greeter-intel-first` pone `WLR_DRM_DEVICES` con la Intel primero solo si
    esos nombres existen. Primer intento roto (2026-09-25): la regla por `ATTRS{vendor}`
    también casaba con el puerto PCIe de Intel del que cuelga la NVIDIA, igpu y dgpu
    acabaron en card0 y el greeter solo encendió el monitor del USB-C. Corregido por
    `DRIVERS` y el script ahora exige que igpu sea Intel y distinta de dgpu. Reinstalado y
    comprobado ese día: igpu → card1 (i915), dgpu → card0 (nvidia), y el script exportaría
    `/dev/dri/card1:/dev/dri/card0` (`udevadm trigger` no espera: `udevadm settle` antes de
    mirar). Tras reiniciar el 2026-09-28: el greeter ve las dos GPU, dibuja con la Intel
    (Mesa) y enciende eDP-1 y HDMI. Queda un detalle: 63 «Atomic commit failed: Device or
    resource busy» en eDP-1 durante los 14 s siguientes a encender el HDMI, que paran
    solos antes de entrar; en los arranques anteriores no había ninguno. Sin efecto que
    importe: la pantalla interna muestra el cuadro de ingreso (confirmado el 2026-09-28), el
    resto es solo visual.
- 2026-09-28 **sudo, un archivo menos**: en `/etc/sudoers.d` ya solo están `10-wheel` y
  `20-defaults`; el `10-pwfeedback` viejo no está (pwfeedback va dentro de 20-defaults).
- 2026-09-25 **bin y Mission Planner**: paquete stow `bin/` con `mission-planner`, que ya no es
  de root. Su Xwayland abre maximizado (regla de niri por app-id: Xwayland fija la resolución
  al abrir y luego ajusta la imagen a la ventana), openbox maximiza Mission Planner sin marco, se cierra con
  Mod+Q, y al terminar Mission Planner se cierra también la ventana de Xwayland (el `wait`
  esperaba a Xwayland y openbox). Sin `LIBGL_ALWAYS_SOFTWARE`: OpenGL 4.6 en la Intel.
  Probado por él el 2026-09-28: fluido, y al redimensionar se ve bien.
- 2026-09-25 **Sin botones de ventana**: gsettings `button-layout ':'` (INSTALL.md) y
  `gtk-decoration-layout=:` en gtk-3.0 y gtk-4.0 para GTK, libadwaita (Karere, Exhibit) y
  Firefox/Zen; VS Code con `window.controlsStyle: hidden`, fuera de Settings Sync para no
  llevarlo a Windows; Vivaldi con `vivaldi.windows.use_native_decoration` (ventana nativa).
  Las dos últimas viven fuera del repo (settings.json de VS Code, Preferences de Vivaldi).
  Confirmado a ojo el 2026-09-28 en VS Code, Zen y Vivaldi.
- 2026-09-25 **Plugins nuevos en el repo**: claude-cockpit (widget `claude` y `Mod+Shift+C`),
  systempulse (widget `pulse` en lugar del `cpu` nativo, `Mod+Shift+Escape`, sin GPU porque
  nvtop despierta la NVIDIA) y battery-graph (clic derecho en la batería, con `battery_BAT1`:
  el `BAT0` por defecto rompía el panel). Estaban solo en el `settings.toml` de la GUI; su
  bloque `[plugins]` se retiró para que mande `30-plugins.toml`. Barra reducida en el HDMI
  vertical (`[bar.default.monitor.hdmi]`). Reinicio de noctalia documentado en su CHEATSHEET:
  los mpvpaper se cierran antes, o quedan dos vídeos por pantalla.
- 2026-09-25 **Fondo de vídeo sin recodificar**: la biblioteca a 1080p del mismo día se descarta
  (obligaba a recodificar cada vídeo nuevo). Medido por el socket IPC de mpvpaper que lo caro
  eran los filtros por defecto de mpv, no el 4K: con `scale=bilinear dscale=bilinear dither=no
  correct-downscaling=no linear-downscaling=no sigmoid-upscaling=no` en `mpv_options` la Intel
  pasa de 631 a 116 MHz de media con un 4K a 30 fps, menos que el 1080p con filtros (283).
  `video_directory` vuelve a `~/Videos/Wallpapers`; tabla en el README de noctalia.
- 2026-09-25 **Node en apps gráficas**: SonarLint no encontraba node porque el PATH de VS Code
  es el de la shell de login que niri-session importa a systemd --user, y eso pisa el
  `environment.d` del paquete mise. Retirado ese archivo; los shims van en `.zshenv`. Aplica al
  volver a entrar; hasta entonces, `code` desde ghostty lo ve.
- 2026-09-25 **ghostmirror analizado**: los dos .service estaban habilitados en multi-user.target y
  corrían en cada arranque además del timer (hoy tres veces: tres barridos completos y ~720 MiB
  de prueba de velocidad); el orden `morerecent` antes que `ping` dejaba 35 espejos alemanes y
  5 Worldwide, ninguno americano. Units reescritos en `etc/`: sin [Install] en los .service,
  mensual por sanidad y latencia con `-T https -d 8 -O 10` y países útiles desde Ecuador (que
  no tiene espejo oficial), semanal en vez de diario para la prueba «light». reflector se
  queda solo para el USB de instalación, donde no hay AUR. `-D` (timers de usuario con linger)
  descartado: la lista es de root, que es justo lo que pedía el issue 22.
- 2026-09-25 **sudo y faillock decididos**: `etc/sudoers.d/20-defaults` (5 intentos, sin sermón,
  contraseña 10 min para todas las terminales, `sudoedit` con Helix) y `etc/security/faillock.conf`
  (5 fallos, 2 min). Con `insults`, sin `NOPASSWD`. Pendiente instalar en la máquina (sección
  Dotfiles de la guía).
- 2026-09-25 **sudo versionado**: `etc/sudoers.d/10-wheel` (permiso) y `20-defaults` (opciones, con el
  `pwfeedback` que había a mano); la guía escribe el de wheel en el chroot y ya no edita
  `/etc/sudoers` con visudo, que quedó como el del paquete.
- 2026-09-24 **Initramfs y GRUB al día**: drop-in de mkinitcpio unificado instalado y regenerado
  (23:54); GRUB 2.16 reinstalado en la ESP tras la actualización (22:41) y hook de pacman para
  que pase solo en adelante.
- 2026-09-24 **xdg**: paquete stow con `mimeapps.list` (imágenes en PhotoQt, carpetas en yazi
  dentro de ghostty, web en Zen), `yazi-ghostty.desktop` y `xdg-terminals.list` para
  xdg-terminal-exec (paquete pendiente de instalar: en «Escritorio» de INSTALL.md).
- 2026-09-24 **i2c y energía**: `ga` en el grupo `i2c` (brillo externo por ddcutil);
  power-profiles-daemon activo (equilibrado); ambos en la fase «Escritorio» de INSTALL.md.
- 2026-09-24 **Node para Claude**: `nodejs` de pacman fuera (era dependencia de una compilación
  de AUR del 23, nada lo usaba); `mise` de pacman con paquete stow `mise/` (node LTS, pnpm con
  `minimumReleaseAge`), activado en `60-tools.zsh`; fase «Desarrollo» en INSTALL.md. Los shims
  iban en `environment.d`, que niri-session pisa al importar el entorno de la shell de login;
  corregido el 2026-09-25: van en `.zshenv` (aplica al volver a entrar).
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
