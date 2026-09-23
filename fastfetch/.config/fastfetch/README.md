# fastfetch

Banner de sistema que zsh muestra al abrir una terminal (`conf.d/80-fastfetch.zsh`; no en
SSH, tmux ni VS Code). Este paquete stow contiene:

| Ruta | Qué es |
| ---- | ------ |
| `config.jsonc` | Logo, formato de las barras y lista de módulos |
| `text/` | Logos de texto (arte braille): `.txt` monocromo, `.ansi` con sus propios códigos de color |
| `images/` | Logos de imagen (PNG) |

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
fastfetch --logo images/chainsaw-man.png --logo-type kitty-direct --logo-width 40
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

Los módulos actuales ocupan 29 líneas. Un logo más alto deja cola por debajo del texto; uno
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
- fastfetch cachea la imagen escalada; tras cambiar el PNG, `--logo-recache`.
- Fondo transparente: el PNG con alfa se respeta en kitty y ghostty.

Bloque de la imagen que estaba en uso hasta 2026-09-23:

~~~jsonc
"logo": {
  "type": "kitty-direct",
  "source": "$XDG_CONFIG_HOME/fastfetch/images/chainsaw-man.png",   // 850x900 px
  "width": 50,
  "padding": { "left": 2 }
}
~~~

## Colores del texto

Los módulos usan nombres ANSI (`yellow`, `light_black`…) en `keyColor`, `percent.color`
y `bar.color`, y las cabeceras `「 OS 」` llevan `\u001b[33m` (amarillo). Igual que con el
logo: nombres, no RGB, para que todo siga la paleta de la terminal.
