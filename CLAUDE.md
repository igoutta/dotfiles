# CLAUDE.md — memoria del proyecto

Dotfiles de Gustavo para Arch Linux en un ASUS TUF Gaming F15 (FX506HE, hostname `tuf`,
usuario `ga`). Este archivo es para Claude Code: cómo está montado el repo, cómo se trabaja en
él y lo que hay que saber de la máquina. El detalle de cada cosa está en `README.md`,
`INSTALL.md`, `TODO.md`, `etc/README.md` y los README/CHEATSHEET de cada paquete.

## Cómo está montado

- **GNU Stow con `--no-folding`** (`.stowrc` de la raíz): cada archivo es su propio enlace y
  los directorios son reales, así que lo que escriben las apps no cae en el repo. Un archivo
  nuevo en un paquete necesita `stow -R <paquete>`, siempre desde `~/dotfiles`. Si stow choca
  con un archivo real, mirarlo antes de moverlo: puede ser config del usuario.
- **Un paquete por programa** en la raíz (`zsh/`, `niri/`, `noctalia/`, `yazi/`, `fastfetch/`,
  `ghostty/`, …). La tabla de paquetes está en `README.md`.
- **`etc/` no es un paquete stow**: archivos del sistema que se instalan a mano con
  `sudo install` (comandos en la sección «Dotfiles» de `INSTALL.md`, tabla en `etc/README.md`).
  Todo lo que necesita sudo lo ejecuta Gustavo; Claude prepara el archivo y el comando.
- **`INSTALL.md`** es la guía de instalación de Arch, por fases, con un comentario por paquete
  diciendo por qué se instala. Nunca una lista plana; `pacman -Qqe` solo sirve para auditar.
  La guía describe el diseño de la reinstalación (LVM dentro de LUKS, `/efi`); la máquina actual
  (agosto de 2026) tiene otra disposición: comprobar con `findmnt`/`lsblk` antes de dar comandos.
- **`TODO.md`** ordena todo lo pendiente por secciones (Sistema, Dotfiles, Documentación,
  Decisiones, Upstream, Hecho). Lo terminado baja a «Hecho» con fecha.

## Reglas de trabajo

- **Commits solo cuando Gustavo los pide en ese mensaje**, con palabras («haz el commit»). «Dale»
  o «lo de arriba» no cuentan. Un commit por tema cerrado, no por paso. Mientras no esté subido,
  se puede rehacer (fixup, rebase) para meter correcciones en su commit.
- **Nunca `git push`** (ni force, ni tags, ni PRs) sin anunciarlo y recibir un sí en ese momento.
  Al terminar, decir qué queda sin subir.
- **Hacer solo lo que pide el mensaje.** Una pregunta o un problema se responde con el
  diagnóstico; los cambios, cuando los pida. El siguiente paso se ofrece en una línea.
- **«Quitar» o «borrar» es borrar**, no ocultar ni comentar. Antes, mirar qué depende de eso,
  arreglarlo en el mismo paso y decirlo.
- **Preguntar el objetivo antes de montar algo nuevo**, y nunca arrancar servicios que
  sincronicen o descarguen sin su permiso. En `~/OneDrive`, borrar es borrar en la nube.
- **Una tecla por acción**, sin atajos de repuesto. Solo teclas propias del teclado latam (no
  `/`, `=`, corchetes) y nada que en el TUF vaya con Fn (Inicio, Fin, RePág, AvPág). Dedos
  cerca: tecla sola, acorde con una letra cercana o la misma tecla repetida. Cada programa
  empareja distinto: niri compara con la tecla sin modificadores (por eso `Mod+Shift+Slash` no
  puede dispararse en latam); ghostty compara modificadores más el carácter sin Shift, así que
  `ctrl+shift+,` sí funciona y `ctrl+=` no. Comprobar un símbolo con
  `xkbcli compile-keymap --layout latam`.
- **Nada que exija un paso manual por cada elemento nuevo** (recodificar cada vídeo…): buscar
  antes una palanca de configuración y medirla.
- **Recomendaciones con veredicto**, basadas en comprobaciones en la máquina, no menús de opciones.
- **Recordar la limpieza antes de la reinstalación**: cuando se acerque, recordarle la lista de
  TODO «Reinstalación» con lo que solo valía para la máquina de 2026-08 (hook bootbackup, tabla
  de `docs/snapper.md`, nota del README).

## Estilo de los archivos

- **Español** en todo lo que escribe el repo: comentarios, README, CHEATSHEET, TODO, INSTALL,
  mensajes de commit y textos en pantalla propios (los `hotkey-overlay-title` de niri). Las
  interfaces de las apps y el idioma del sistema se quedan en inglés a propósito. Con Gustavo,
  siempre en español, también justo después de un resumen de contexto.
- **Solo Arch**, sin ramas para otras distros, pero con un comentario «Ubuntu/Fedora: …» junto a
  cada cosa específica de Arch (paquetes, rutas, comandos).
- **Cada config explica su porqué** en comentarios. Las configs largas se parten en módulos por
  tema si la herramienta lo permite (zsh `conf.d/`, niri `include`, noctalia un TOML por tema).
  fastfetch no sabe incluir archivos: es un solo `config.jsonc` por secciones.
- **Tablas Markdown** con el separador `| --- | --- |`, con espacios.
- Herramientas de Gustavo: `rg` (con `alias grep=rg`), Helix (`hx`), yazi, zsh, ghostty.
- **Paleta**: negro con naranja y rojo, vibrante; Ayu Red elegida, Vesper la alternativa, el
  verde sobre negro rechazado. Al tematizar cualquier cosa (fastfetch, starship, helix) usar
  nombres de color ANSI para que la paleta de noctalia mande.

## Verificar antes de decir que funciona

- **Leer el código de la versión instalada** (`pacman -Q`, etiqueta del repo), no `main`. Si lo
  que observa Gustavo contradice lo leído, manda su observación: volver a su estado y revisar.
- **Lo visual, en la app real:** abrir la ventana (`niri msg action spawn -- ghostty ...`),
  capturarla con `niri msg action screenshot-window --id ID --write-to-disk true`, mirar la imagen,
  cerrar la ventana, borrar o mover la captura de `~/Pictures/Screenshots` y restaurar el
  portapapeles (guardar antes `wl-paste --type text/plain`). Una terminal simulada (`script`) no
  dibuja imágenes y no sirve como prueba visual.
- **`LANG=es_EC`**: coma decimal en `printf`/Lua de las apps. fastfetch lanza sus comandos con
  `LANG=C.UTF-8`.
- **`ls` es eza y Helix usa tabulador de 4**: para enlaces y bytes usar `readlink`, `stat` o
  `cat -A`, no `ls`; las columnas alineadas con tabulador se ven distintas en Helix que en `cat`.
- **`noctalia config validate ~/.config/noctalia`** valida el TOML pero no los ids de widgets ni
  de plugins: un id inventado pasa. La prueba real es `~/.cache/noctalia/noctalia.log` tras
  reiniciarla («unknown widget» o la línea `widget.<id>`).
- **Potencia**: `energy_uj` de RAPL es solo root; los vatios se miden con `turbostat`
  (`linux-tools`).
- **Ediciones por rangos:** reemplazar texto exacto; después, `git diff --stat` contra HEAD y
  contar (binds, secciones). Que `niri validate` pase no prueba que no se perdió nada.
- **ghostty no admite comentarios detrás de un valor**: `keybind = … # algo` da
  `InvalidFormat`. El comentario va en la línea anterior. `ghostty +validate-config` lo delata.
- **Trampas de la propia herramienta**, ya pagadas: `rg -E` es codificación, no regex (usar
  `-e` o el patrón suelto); `git cherry-pick` no tiene `-q`; en un script con `set -e`, un fallo
  dentro de una cadena `&&` no aborta, y `git diff --stat` devuelve 0 aunque haya diferencias
  (comparar con `git diff --quiet`); la shell de la herramienta es zsh con `NOMATCH`, así que un
  glob sin coincidencias aborta la línea entera.
- **Arranque, greeter, udev, fstab:** comprobar el efecto real (`readlink -f`, `udevadm info -a`,
  `findmnt --verify`), que falle de forma segura y dar el comando para deshacerlo.

## La máquina

- **GPU híbrida:** Intel (card1, renderD128, PCI 00:02.0) y RTX 3050 Ti (card0, renderD129, PCI
  01:00.0, nvidia-open). El USB-C está cableado a la NVIDIA. **niri dibuja en la NVIDIA** desde
  el 2026-09-30 (`render-drm-device` en `niri/startup.kdl`): con la Intel, el ViewSonic a 1366
  por USB-C salía corrupto (fallo del EGL de NVIDIA, ver «Upstream» en TODO). Precio: la NVIDIA
  no se duerme (~15 W), y sus 4 GB de memoria van justos con tres fondos de vídeo 4K.
- **Monitores** reconocidos por marca, modelo y serie en `niri/outputs.kdl`: portátil (eDP-1,
  1920x1080@144), ViewSonic VA1903 vertical a la izquierda (USB-C, 1366x768), Samsung S19D300
  vertical a la derecha (HDMI con convertidor a VGA) o ASUS MB169CK horizontal a la derecha.
- **Discos:** Arch en `nvme1n1` (LUKS2 + Btrfs con subvolúmenes, snapper, swap con clave
  aleatoria, sin hibernación). Windows en `nvme0n1p3`, montado bajo demanda en `/mnt/windows`
  (ntfs3, inicio rápido de Windows apagado). La OneDrive de Windows tiene archivos solo en la
  nube: desde Linux se ven con tamaño pero vacíos.
- **Escritorio:** niri 26.04 + noctalia 5.2 (paleta Ayu Red), greetd con noctalia-greeter en la
  Intel. noctalia lee los TOML del repo y encima `~/.local/state/noctalia/settings.toml` (capa de
  su GUI); `config-reload` no aplica paleta ni código de plugins: hace falta reiniciarla.
  Ese `settings.toml` es desechable: recién arrancada sin él, noctalia lo recrea solo con
  estado de ejecución (`lockscreen_widgets`, `wallpaper.last`, `wallpaper.monitors`); pero
  cualquier cambio desde su GUI o un `noctalia msg …-set` vuelca ahí *todos* los deltas con
  lo que tenga en memoria y pisa al repo clave a clave. Para volver a limpio: `noctalia config
  export merged` → diff → portar al TOML → mover `settings.toml` → reiniciar noctalia.
- **Noctalia escribe en el repo si falta su línea de enganche.** Sus `apply.sh` editan la config
  principal de cada app siguiendo el symlink de stow, salvo que la línea exacta ya esté:
  `theme = noctalia` (ghostty), `include "noctalia.kdl"` (niri), `@import url("noctalia.css");`
  (gtk.css). Los archivos que genera (`noctalia.kdl`, `noctalia.css`, `themes/noctalia`) se quedan
  fuera del repo. La plantilla `fastfetch` no se activa nunca: mezcla con `jq` y rompe con los
  comentarios del jsonc.
- **Los `include` de niri se resuelven contra la ruta dada, no contra la real.** Por eso los
  módulos del repo, enlazados en `~/.config/niri/`, encuentran `noctalia.kdl`, que vive ahí
  como archivo real. Si cambia la forma de desplegar, esto se rompe sin aviso.
  xwayland-satellite da el X11; tras actualizarlo, cerrarlo para que niri arranque el nuevo.
- **Abrir carpetas desde un programa: `gio open`, nunca `xdg-open`.** Las carpetas van a
  `yazi.desktop` (`Terminal=true`) y `xdg-open` fuera de GNOME/KDE lanza yazi sin terminal.
- **yazi:** plugins oficiales de `yazi-rs/plugins` fijados en `package.toml`; uno de terceros
  solo si Gustavo lo aprueba (hoy `starship.yazi`). `ficha` es propio (vistas previas con datos).
- **Banner:** fastfetch en local (`config.jsonc`) y por SSH (`ssh.jsonc`), elegido por zsh.
- **Red:** firewalld con zonas propias (`etc/firewalld/`): `home` para las redes de confianza
  (SSH y mDNS), `public` cerrada.
- Teclado `latam`; idioma `es_EC.UTF-8` con mensajes en inglés.
- **Temperatura:** el firmware no expone curvas de ventilador (asusctl no sirve aquí); thermald
  con `--adaptive` aplica las tablas térmicas del BIOS según el perfil y en ese modo ignora
  `thermal-conf.xml`; Fn+F5 cicla los perfiles desde el kernel. Tabla y comandos en la fase
  «Temperatura» de INSTALL.md.
