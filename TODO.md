# TODO

Cada tarea vive en una sola sección. Dentro de cada sección, el orden es la prioridad. Lo
terminado baja a «Hecho» con fecha. Lo de «Sistema» se hace en la máquina y, a la vez, se
escribe en `INSTALL.md` en su fase, con el porqué de cada paquete.

**En curso**, en este orden: (1) cerrar el escritorio: i2c, energía, node; (2) pasada visual
de niri + noctalia y usarla unos días; (3) sistema
pesado: NVIDIA, hibernación; (4) sistema menor: servicios, cups, firewalld, bluetooth, Windows,
user-dirs, portapapeles; (5) auditoría de paquetes; después ghostty y zsh segunda vuelta.

## Sistema

- [ ] **Greeter, formulario abajo a la izquierda**: no se puede en 1.5.0, la última versión
      (2026-09-10). El formulario va siempre centrado; solo se colocan los botones de
      apagado (`power_buttons_position`) y el selector de esquema (`scheme_selector_position`),
      con valores `top-left`, `top-right`, `bottom-left`, `bottom-right` o `hidden`, en
      `[appearance]` de `etc/noctalia-greeter/greeter.toml`. Nadie lo ha pedido en GitHub:
      abrir sugerencia o revisar en cada versión nueva. Desenfoque del fondo tampoco existe.
      Translúcido sí: `surface_variant = "#161A22BF"` en `[appearance.palette]` del mismo
      archivo (preparado el 2026-09-24, pendiente de instalar y ver; ajustar el `BF`).
- [ ] **ddcutil**: noctalia lo usa para el brillo del monitor externo pero `ga` no está en el
      grupo `i2c`. O `sudo usermod -aG i2c ga`, o `enable_ddcutil = false` en `00-shell.toml`.
- [ ] **Energía**: sin gestor (ni power-profiles-daemon, ni tlp, ni thermald).
      power-profiles-daemon es lo que noctalia muestra; decidir y activar.
- [ ] **Node para Claude (mise + pnpm)**: Claude Code va con el instalador nativo
      (`~/.local/share/claude`) y no necesita node; sí lo necesitan los servidores MCP y
      plugins que se lanzan con `npx`. Hoy hay un `nodejs` 26 huérfano (dependencia del
      2026-09-23) y ningún npm. Lo más seguro ahora, por los gusanos de npm de 2025:
      - `pacman -S mise` (extra) como único gestor de versiones: descargas con checksum,
        versión fijada por proyecto con `mise.toml`, misma config en Ubuntu/Fedora (allí
        mise va por su script o por copr, no por apt/dnf).
      - `mise use -g node@lts pnpm@latest`, sin npm global: pnpm 10+ no ejecuta scripts de
        instalación de dependencias salvo lista blanca, y `minimumReleaseAge = 10080`
        (7 días) en `~/.config/pnpm/rc` evita instalar versiones recién publicadas, que es
        como entraron los paquetes comprometidos.
      - `pacman -Rns nodejs` para no tener dos node; `mise` en `60-tools.zsh`
        (`eval "$(mise activate zsh)"`) y paquete stow `mise` con `config.toml` y el rc
        de pnpm. Fase «Desarrollo» en INSTALL.md.
      Alternativa simple sin versiones por proyecto: `pacman -S nodejs-lts-krypton pnpm`.
- [ ] **NVIDIA + Intel**: RTX 3050 Ti Mobile junto a Intel TigerLake UHD; solo mesa e
      intel-media-driver. Camino probable: nvidia-open-dkms, `nvidia-drm.modeset=1` para
      niri, PRIME render offload; envycontrol o supergfxctl para apagarla del todo.
- [ ] **Hibernación**: imposible hoy. Swap de 16 G con clave aleatoria y sin `resume=`.
      Opciones: swap LUKS con clave fija en la raíz, o swapfile en `@swap` con
      `resume_offset`. Arrastra el hook `resume`, hoy en `mkinitcpio.conf` antes de
      `encrypt` y sin poder funcionar; el hook `btrfs` tampoco hace falta.
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
- [ ] **Tercer monitor (DP-2)**: aparece en el estado de noctalia y hay displaylink + evdi
      instalados; el soporte de DisplayLink en niri no está verificado. Al conectarlo, bloque
      `output` en `niri/outputs.kdl`.
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
      - Utilidades CLI: fd trash-cli unrar patool toilet tealdeer vivid pacman-contrib
        rust-motd-bin exhibit qalculate-qt
      - Hardware: displaylink linux-firmware-intel lvm2 ddcutil
      - Fuentes: gsfonts opendesktop-fonts woff2-cascadia-code wqy-bitmapfont wqy-microhei
        wqy-zenhei
      - Remoto y repos: rustdesk blackarch-mirrorlist

## Dotfiles

- [~] **niri + noctalia + gtk**: paquetes hechos el 2026-09-24 (ver Hecho); el login por
      greetd con la config declarativa y `adw-gtk-theme` ya se probaron ese día. Falta:
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
      compararlo con otras configs públicas y copiar solo lo que la resuelva.
- [ ] **rust-motd**: paquete stow y que funcione al entrar por SSH, donde hoy no hay banner
      (fastfetch se salta en SSH desde `80-fastfetch.zsh`).
- [ ] **yazi**: paquete stow y arreglar la configuración.
- [ ] **kitty**: paquete stow cuando llegue (mismo `^H` para Ctrl-Backspace que ghostty).
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
- Idioma: interfaces en inglés (`LC_MESSAGES=en_US` con `LANG=es_EC`; `lang = "en"` en
  noctalia, cuya traducción va al 79 %; niri no tiene idioma). En español solo lo del repo:
  chuletas, comentarios, README, títulos de `Mod+F1` y commits.

## Hecho

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
