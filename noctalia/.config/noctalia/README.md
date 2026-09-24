# noctalia

Shell del escritorio (barra, lanzador, notificaciones, fondos, bloqueo) sobre niri.
Noctalia 5 es un binario nativo con configuración TOML. Arch: `pacman -S noctalia`, greeter
y fondos de vídeo desde AUR (`yay -S noctalia-greeter mpvpaper`). Fedora/Ubuntu: sin
paquete oficial, releases de GitHub.

## Dos capas de configuración

1. **Declarativa**: todos los `*.toml` de este directorio, en orden alfabético. Es la que
   vive en el repo. Recarga en caliente: `noctalia msg config-reload`.
2. **De la GUI**: `~/.local/state/noctalia/settings.toml`. La escribe la ventana de ajustes
   y comandos como `color-scheme-set`, `theme-mode-set` o `wallpaper-set`. Guarda solo
   diferencias frente a los valores por defecto, y **pisa** a la capa declarativa clave a
   clave.

Comprobado el 2026-09-24 en esta máquina:

- Al arrancar sin `settings.toml`, noctalia carga solo lo declarativo y escribe un
  `settings.toml` nuevo con únicamente estado de ejecución: `[lockscreen_widgets]`,
  `[wallpaper.last]` y `[wallpaper.monitors.*]`. Esa convivencia es la buena.
- Cualquier cambio desde la GUI o desde un `noctalia msg …-set` vuelca en `settings.toml`
  **todas** las diferencias frente a los defaults, con los valores que tenga en memoria. A
  partir de ahí ese archivo pisa a los `.toml` del repo clave a clave.
- `config-reload` relee los archivos pero no re-evalúa la paleta ni la lista de plugins y
  widgets de la barra. Tras cambiar `10-theme.toml` o `30-plugins.toml`, reiniciar:
  `pkill -x noctalia; niri msg action spawn -- noctalia`.

Regla: lo que se quiera conservar va a un `.toml` de aquí; `settings.toml` es desechable.
Cuando la GUI haya guardado algo que interese:

~~~sh
noctalia config export merged > /tmp/merged.toml     # estado efectivo (declarativo + GUI)
diff <(cat ~/.config/noctalia/*.toml) /tmp/merged.toml   # o a ojo: qué claves cambiaron
# copiar las claves a su .toml con su comentario, y luego:
noctalia config validate ~/.config/noctalia
mv ~/.local/state/noctalia/settings.toml{,.bak}          # quitar la capa que pisa
pkill -x noctalia; niri msg action spawn -- noctalia      # reload no basta para paleta y plugins
~~~

Ninguna clave se repite entre los archivos de aquí, así que el orden no importa.

| Archivo | Qué contiene |
| --- | --- |
| `00-shell.toml` | shell, barra, dock, audio, brillo, batería, calendario, ubicación, luz nocturna, bloqueo |
| `10-theme.toml` | paleta (Ayu Red, negro puro) y plantillas por app |
| `20-wallpaper.toml` | directorio de fondos y fondo por defecto |
| `30-plugins.toml` | plugins activos y sus ajustes |

Fuera del repo, y por qué: `~/.local/state/noctalia/` entero (settings.toml, state.toml,
plugins descargados, portapapeles, historiales: lo reescribe la app), `~/.cache/noctalia/`,
`[lockscreen_widgets]` (posiciones puestas con el ratón) y todo lo que generan las
plantillas.

## Plantillas: lo que noctalia escribe en otras apps

Con la paleta activa genera un archivo de tema junto a la config de cada app y espera una
línea de enganche en su config principal. Esa línea la escribimos a mano en el paquete de
cada app; si falta, el `apply.sh` de la plantilla la añade al final del archivo, y como los
archivos son enlaces de stow **acabaría escribiendo dentro del repo**.

| App | Genera (fuera del repo) | Línea de enganche (en el repo) |
| --- | --- | --- |
| ghostty | `ghostty/themes/noctalia` | `theme = noctalia` en `config.ghostty` |
| niri | `niri/noctalia.kdl` | `include "noctalia.kdl"` en `config.kdl` |
| gtk3 / gtk4 | `gtk-{3,4}.0/noctalia.css` | `@import url("noctalia.css");` en `gtk.css` |
| btop | `btop/themes/noctalia.theme` | `color_theme = "noctalia"` en `btop.conf` |
| helix | `helix/themes/noctalia.toml` | `theme = "noctalia"` en `config.toml` |
| bat (comunidad) | `bat/themes/noctalia.tmTheme` | `--theme=noctalia` en `bat/config` |

Comprobación tras cualquier cambio de paleta: `noctalia msg templates-apply` y
`git -C ~/dotfiles status` debe salir limpio.

No activar la plantilla `fastfetch`: mezcla con `jq` y falla con los comentarios de
`config.jsonc`.

## Fondos de vídeo (plugin mpvpaper)

El plugin lanza un `mpvpaper` por salida (o uno para todas con «All outputs») y, mientras
un vídeo esté asignado, **retira la capa de fondo de noctalia** en esas salidas para que se
vea el vídeo. Por eso elegir una imagen en el panel de fondos no cambia nada hasta parar el
vídeo: **Stop** en el selector del plugin, o por IPC:

~~~sh
noctalia msg panel-toggle noctalia/mpvpaper:picker                    # selector de vídeos
noctalia msg plugin noctalia/mpvpaper:service all clear-all           # parar todo y volver a imágenes
noctalia msg plugin noctalia/mpvpaper:service all reapply             # volver a poner el último vídeo
noctalia msg plugin noctalia/mpvpaper:service all toggle [salida]     # pausar / reanudar
~~~

Al parar, con `extract_last_frame` (por defecto) el plugin saca un fotograma con ffmpeg y lo
deja como fondo de esas salidas, pisando la imagen que tuvieran: hay que volver a elegirla.
Las miniaturas del selector las genera mpv la primera vez que se abre (31 vídeos, unos
segundos; parece colgado y no lo está). `socat` solo hace falta para las presentaciones
(intervalo en el selector): sin él el vídeo rota igual, pero el selector no marca cuál va.
Estado del plugin en `~/.local/state/noctalia/mpvpaper/assignments.json`.

## Greeter

`noctalia-greeter` (greetd) toma paleta y fondo con `noctalia msg greeter-sync`, que pide
autenticación (polkit) y escribe en `/var/lib/noctalia-greeter/`. Fuera del repo. Repetirlo
tras cambiar de paleta o de fondo si se quiere el greeter a juego.
