# fastfetch

Banner de sistema que zsh muestra al abrir una terminal (`conf.d/80-fastfetch.zsh`; no en
SSH, tmux ni VS Code). Este paquete stow contiene:

| Ruta | Qué es |
| ---- | ------ |
| `config.jsonc` | Logo, formato de las barras y lista de módulos, en un solo archivo por secciones |
| `scripts/` | Lo que necesita shell (batería, snapper, última actualización, tiempo, saludo): cada uno se prueba solo |
| `text/` | Logos de texto (arte braille): `.txt` monocromo, `.ansi` con sus propios códigos de color |
| `images/` | Logos de imagen: PNG con fondo transparente para usar, y los originales |

Arch: `pacman -S fastfetch`. Fedora: `dnf install fastfetch`. Ubuntu: no está en apt
hasta 24.10; antes, el `.deb` de las releases de GitHub o el PPA `zhangsongcui3371/fastfetch`.

## Probar sin tocar la config

Cualquier opción del bloque `logo` tiene su equivalente `--logo-*` en la línea de comandos
y manda sobre `config.jsonc`, así que se prueba primero y se escribe después:

~~~sh
fastfetch --logo text/eva-01.txt --logo-type file          # otro ASCII
fastfetch --logo-color-1 blue                               # otro color
fastfetch --logo-padding-right 8 --logo-padding-top 2       # separación
fastfetch --logo-position top                               # logo encima, módulos debajo
fastfetch --logo images/chainsaw-man-graveyard.png --logo-type kitty-direct --logo-width 40
fastfetch --logo none                                       # solo módulos
~~~

`--logo-position top` es la salida para logos más anchos que la terminal menos el texto:
el dibujo va arriba y los módulos debajo, a todo el ancho.

## Logos de texto

Dos tipos de archivo, distinguidos por la extensión, y hay que decirle a fastfetch cuál es:

- **`.txt` → `"type": "file"`**, archivos **monocromos**. El color lo pone la config con
  `"color": { "1": "magenta" }`. Para varias zonas se escribe `$1`…`$9` dentro del
  `.txt` donde cambie el color y se define cada número en `"color"`. Un `$` literal se
  escribe `$$`. Usar nombres ANSI (`blue`, `magenta`, `light_red`…) y no RGB para que el
  logo siga la paleta que noctalia ponga en la terminal.
- **`.ansi` → `"type": "file-raw"`**, archivos que **ya traen sus códigos de color** (RGB de
  24 bits, `ESC[38;2;R;G;Bm`). fastfetch los imprime tal cual; `"color"` no aplica y el
  logo no cambia con la paleta. También sirve `file`, pero cualquier `$` del arte se
  interpretaría como cambio de color.

Ejemplo del bloque actual (monocromo):

~~~jsonc
"logo": {
  "type": "file",
  "source": "$XDG_CONFIG_HOME/fastfetch/text/evangelion-longinus.txt",
  "color": { "1": "magenta" },
  "padding": { "left": 2, "right": 4, "top": 1 }
}
~~~

### Inventario

| Archivo | Líneas | Columnas | Tipo |
| --- | --- | --- | --- |
| `eva-01-letterboard-circular.txt` | 49 | 102 | monocromo → `file` |
| `eva-01.ansi` | 27 | 65 | color propio → `file-raw` |
| `eva-01.txt` | 27 | 65 | monocromo → `file` |
| `evangelion-longinus.txt` | 49 | 20 | monocromo → `file` |
| `ichigo-hollow-mask.txt` | 25 | 39 | monocromo → `file` |
| `itachi-mangekyou-sharingan.txt` | 12 | 50 | monocromo → `file` |
| `the-legend-of-zelda.txt` | 15 | 14 | monocromo → `file` (en negativo: el fondo es `⣿`) |

Los módulos actuales ocupan 42 líneas. Un logo más alto deja cola por debajo del texto; uno
más bajo deja el texto colgando. Los márgenes vacíos de un arte braille (columnas de `⠀` comunes a todas
las líneas, filas vacías; en un arte en negativo, lo mismo con `⣿`) se pueden recortar
sin tocar el dibujo; el padding lo pone la
config. Las columnas del logo más el padding más la línea más
larga de los módulos (unas 70) tienen que caber en la terminal. `--logo-position top` pone el logo encima y los módulos
debajo a todo el ancho, pero deja vacío todo lo que hay a la derecha del dibujo: fastfetch
no envuelve el texto alrededor del logo.

### Arte a color pegado desde una web: los `ESC` perdidos

`eva-01.ansi` (antes `hola.txt`) llegó así, arreglado el 2026-09-23: arte a color RGB al que, al pegarlo, se le
perdió el byte de escape (`ESC`, 0x1b) que precede a cada código. El archivo tenía
`[38;2;30;40;80m` en vez de `ESC[38;2;30;40;80m` y fastfetch imprimía los códigos como
texto. Si en el editor se ven `[38;2;…m` literales, es esto. Se comprueba y se repara así:

~~~sh
rg -c --include-zero '\x1b\[' text/archivo.ansi        # 0 → le faltan los ESC
sed -i 's/\(^\|[^\x1b]\)\[\([0-9;]*m\)/\1\x1b[\2/g' text/archivo.ansi
rg -c --include-zero '\x1b\[' text/archivo.ansi        # = nº de líneas → arreglado
fastfetch --logo text/archivo.ansi --logo-type file-raw
~~~

## Logos de imagen

fastfetch no dibuja la imagen: se la pasa a la terminal con un protocolo gráfico, así que
el tipo depende de la terminal.

| `type` | Cuándo |
| --- | --- |
| `kitty-direct` | ghostty y kitty (las dos hablan el protocolo gráfico de kitty). El más rápido: la terminal lee el archivo directamente |
| `kitty` | Igual, pero fastfetch envía los datos; útil por SSH o si `kitty-direct` no muestra nada |
| `chafa` | Cualquier terminal: convierte la imagen a caracteres de color. Este fastfetch está compilado con libchafa |
| `sixel` | Terminales con sixel (foot, wezterm, xterm); ghostty no lo soporta |
| `iterm` | iTerm2 y wezterm; requiere `width` y `height` |

Opciones que importan:

- `"width"` en **columnas**; `"height"` en **líneas**. Con solo `width`, la altura sale de
  la proporción de la imagen. `"preserveAspectRatio": true` evita estirarla si se dan los
  dos.
- `"padding"`: `left`, `right`, `top`, como en ASCII.
- fastfetch cachea la imagen escalada; tras cambiar el PNG, `--logo-cache regen` (`--logo-recache` ya no existe en 2.69).
- Fondo transparente: el PNG con alfa se respeta en kitty y ghostty.

### Inventario de imágenes

| Archivo | Tamaño | Qué es |
| --- | --- | --- |
| `evangelion-eva-01.png` | 563x900 | EVA-01 morada, fondo transparente. **En uso**, al azar con las otras dos |
| `evangelion-eva-00.png` | 645x900 | EVA-00 amarilla, fondo transparente. **En uso**, al azar |
| `evangelion-eva-02.png` | 584x900 | EVA-02 roja, fondo transparente (cortada a la derecha, como en el original). **En uso**, al azar |
| `evangelion-evas-00-01-02.jpg` | 3840x2160 | Original de las tres Evas, del que salen los tres PNG |
| `evangelion-eva-01-longinus-sunset.jpg` | 736x1472 | EVA-01 con la lanza de Longinus en un atardecer rojo; escena completa, sin transparencia |
| `chainsaw-man-graveyard.png` | 850x900 | Chainsaw Man entre cruces, fondo transparente (antes `chainsaw-man.png`) |

Los tres PNG de Evas (2026-10-01): cortes por el centro de los dos huecos negros del original
(columnas 1330 y 2591), cada figura ajustada a su dibujo con 48 px de margen, el fondo negro
exterior vuelto transparente (los píxeles oscuros conectados al borde; los negros de dentro de
la figura se quedan) y escalados a 900 px de alto. Así, sobre ghostty translúcido no queda un
rectángulo oscuro alrededor.

Tamaño para una terminal a media pantalla (columna al 50 % en niri: 91 columnas, 49 líneas con
FiraCode a 12): `"width": 20` y 2 + 4 de márgenes dejan 65 columnas al texto; la línea más
larga (la batería) mide unas 60. Con 20 de ancho el logo mide unas 15 líneas, y `"top": 15` lo
centra frente a las 42 del texto. En los monitores verticales (unas 74 columnas) quedan 48 y
algunas líneas se parten. Cada terminal elige una de las tres Evas: `"source"` lleva
`$(shuf -n 1 -e …/evangelion-eva-0[012].png)`, que fastfetch expande.

Bloque de la imagen que estaba en uso hasta 2026-09-23:

~~~jsonc
"logo": {
  "type": "kitty-direct",
  "source": "$XDG_CONFIG_HOME/fastfetch/images/chainsaw-man-graveyard.png",   // 850x900 px
  "width": 50,
  "padding": { "left": 2 }
}
~~~

## Colores del texto

Los módulos usan nombres ANSI (`yellow`, `light_black`…) en `keyColor`, `outputColor`,
`percent.color` y `bar.color`; dentro de un formato, `{#yellow}`, `{#dim_default}` (tenue),
`{#1}` (negrita) y `{#22}` (fin de negrita), y `{#}` lo devuelve todo a como estaba. Nada de
`\u001b[…m` a mano: con `--pipe` saldría como texto. Igual que con el logo: nombres, no RGB,
para que todo siga la paleta de la terminal. Números, barras y temperaturas cambian de color
según el valor (`display.percent` y `display.temp`; sin `"num"` en `percent.type` las variables
`{…percentage}` salen vacías).

## Datos que necesitan shell: `scripts/`

Cada línea que fastfetch no da por sí solo es un script de bash, casi sin procesos, que se puede
ejecutar a mano para depurarlo: `~/.config/fastfetch/scripts/battery.sh`. Si un script no
imprime nada, fastfetch oculta su línea; si tarda más de 300 ms (`general.processingTimeout`),
también. Medidos el 2026-10-01: el total pasó de unos 21 a 34 ms por terminal.

| Script | Qué muestra | De dónde |
| --- | --- | --- |
| `greeting.sh` | Saludo según la hora y la fecha | `printf` de bash, con el idioma de `locale.conf` |
| `weather.sh` | Tiempo, mínima y máxima, ocaso | La caché de noctalia (`~/.cache/noctalia/weather.json`), sin red; nada si tiene más de 2 h |
| `last-upgrade.sh` | Última actualización completa | El log de pacman (`starting full system upgrade`) |
| `snapshot.sh` | Última instantánea de snapper | `/.snapshots/<n>/info.xml` (legible para ga por la ACL de snapper) |
| `battery.sh` + `battery.lua` | La barra de carga con el tope marcado dentro (┃), estado, salud y perfil. La carga y la barra son del módulo `battery`; el `.lua` (cargado con `general.preload.lua`) marca el tope y junta el texto del `.sh` | `/sys/class/power_supply/BAT1` y `/sys/firmware/acpi/platform_profile` |

fastfetch lanza sus comandos con `LANG=C.UTF-8`: un script que dependa del idioma (la fecha)
tiene que leerlo de `locale.conf`, como `greeting.sh`.

## Depurar

- `fastfetch --show-errors`: una clave mal escrita en un módulo solo avisa así; un `type` mal
  escrito desaparece sin aviso.
- Con la salida en una tubería, fastfetch no aplica colores y un color mal escrito no da error,
  pero en una terminal de verdad corta todo lo que viene después («invalid color code found»).
  Para probar como en una terminal sin abrir ninguna: `script -qc fastfetch /dev/null`.
- Los tiempos de cada módulo: `fastfetch --stat`.
