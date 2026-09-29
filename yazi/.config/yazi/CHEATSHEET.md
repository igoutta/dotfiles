# yazi: teclas

Dentro de yazi, `~` o `F1` lista todas las teclas y se filtra escribiendo. Al empezar una
secuencia (`g`, `c`, `m`, `,`, `t`) aparece un menú con lo que sigue. El ratón también
funciona: clic, rueda y arrastrar. Las marcadas con ★ son propias (`keymap.toml`); el resto
es de fábrica (yazi 26.9).

## Moverse

| Tecla | Acción |
| --- | --- |
| `j` / `k` (o flechas) | Bajar / subir |
| `l` / `h` | Entrar en la carpeta / volver a la carpeta de arriba |
| `Enter` ★ | Entrar en la carpeta o abrir el archivo |
| `gg` / `G` | Primero / último |
| `Ctrl+d` / `Ctrl+u` | Media página abajo / arriba |
| `H` / `L` | Carpeta anterior / siguiente del historial |
| `K` / `J` | Desplazar la vista previa; en un vídeo, retroceder / avanzar un 5 %; en un PDF, página anterior / siguiente |
| `T` ★ | Agrandar o restaurar la vista previa (leer un PDF) |
| `Tab` | Detalles del archivo (tipo, fechas, permisos, tamaño en píxeles) |
| `.` | Mostrar u ocultar archivos ocultos |
| `q` | Salir |

## Vistas previas

| Archivo | Qué se ve |
| --- | --- |
| Vídeo | Un fotograma, sacado por la Intel; `J`/`K` recorren el vídeo; debajo, duración, peso, pistas de vídeo, audio y subtítulos |
| Foto | La imagen; debajo, formato y tamaño (y cámara, lente, exposición y GPS si hay exiftool) |
| Audio | La portada si la trae; debajo, título, artista, álbum, año, duración y calidad |
| PDF | La página actual; `J`/`K` cambian de página |

`T` agranda cualquiera. Lo de vídeo, foto y audio es el plugin propio `ficha`. No hay vistas
previas animadas: yazi dibuja una sola imagen; `o` abre el vídeo en mpv.

## Saltar

| Tecla | Acción |
| --- | --- |
| `gh` | Inicio (`~`) |
| `go` ★ | OneDrive |
| `gd` | Downloads |
| `gu` ★ | USB montados (`/run/media/ga`) |
| `gc` | `~/.config` |
| `gt` | Papelera; dentro, `O` → «Restore» devuelve lo marcado a su sitio |
| `g` + espacio | Escribir la carpeta a la que ir |
| `gf` | Seguir un enlace simbólico |
| `z` | Buscar archivo o carpeta con fzf |
| `Z` | Saltar a una carpeta frecuente (zoxide) |

## Abrir

| Tecla | Acción |
| --- | --- |
| `o` | Abrir con la app por defecto (PDF → PDF4QT, imágenes → PhotoQt, texto → Helix) |
| `O` | Elegir con qué abrir |
| `i` ★ | Imprimir en la Epson (pide confirmación) |
| `R` ★ | OCR: crea `archivo-ocr.pdf` con texto buscable al lado del PDF |

## Seleccionar

| Tecla | Acción |
| --- | --- |
| espacio | Marcar o desmarcar y bajar |
| `v` | Modo selección: moverse marca todo lo que pasa |
| `V` | Modo contrario: moverse desmarca |
| `Ctrl+a` / `Ctrl+r` | Marcar todo / invertir la selección |
| `Esc` | Salir del modo y quitar la selección |

## Copiar, mover, borrar

| Tecla | Acción |
| --- | --- |
| `y` / `x` | Copiar / cortar lo seleccionado |
| `p` / `P` | Pegar / pegar sobrescribiendo |
| `X` o `Y` | Olvidar lo copiado o cortado |
| `d` | A la papelera (pide confirmación) |
| `D` | Borrar para siempre (pide confirmación) |
| `a` | Crear archivo; terminado en `/`, carpeta |
| `r` | Renombrar; con varios seleccionados, en el editor, todos a la vez |
| `-` / `_` | Enlace simbólico de lo copiado (ruta absoluta / relativa) |
| `w` | Tareas en curso (copias largas); `x` cancela una |

**En `~/OneDrive`, borrar es borrar en la nube**, también con `d`. La copia queda en la
papelera local (`gt`) y en la papelera de la web de OneDrive.

## Buscar

| Tecla | Acción |
| --- | --- |
| `s` | Buscar por nombre (fd), también en subcarpetas |
| `S` | Buscar por contenido (ripgrep) |
| `Ctrl+s` | Cancelar la búsqueda |
| `f` | Filtrar lo que se ve en la carpeta |
| `/` / `?` | Ir al siguiente / anterior que coincida; luego `n` / `N` |

## USB (`M` ★)

| Tecla | Acción |
| --- | --- |
| `M` | Abrir el panel de discos y USB |
| `j` / `k` | Elegir la partición |
| `m` / `u` | Montar / desmontar |
| `e` | Expulsar el disco (para sacarlo) |
| `l` | Entrar a donde está montado |
| `q` | Cerrar el panel |

udiskie ya monta solo el USB al conectarlo; el panel sirve para desmontar y expulsar.

## Copiar rutas, ordenar, ver

| Tecla | Acción |
| --- | --- |
| `cc` / `cd` / `cf` / `cn` | Copiar ruta / carpeta / nombre / nombre sin extensión |
| `,m` `,s` `,a` `,e` `,n` | Ordenar por fecha / tamaño / nombre / extensión / natural (mayúscula: al revés) |
| `ms` `mm` `mp` `mn` | Mostrar a la derecha tamaño / fecha / permisos / nada |

## Pestañas

| Tecla | Acción |
| --- | --- |
| `tt` | Nueva pestaña en esta carpeta |
| `1` … `9` | Ir a la pestaña |
| `[` / `]` | Pestaña anterior / siguiente |
| `Ctrl+c` | Cerrar la pestaña (en la última, sale) |

## Terminal

| Tecla | Acción |
| --- | --- |
| `;` | Correr un comando (`%s` son los seleccionados, `%h` el de debajo del cursor) |
| `:` | Igual, esperando a que termine y mostrando la salida |
| `Ctrl+z` | Dejar yazi en segundo plano; `fg` en la terminal para volver |

## Plugins

Oficiales de `yazi-rs/plugins`, con versión fijada en `package.toml`: mount, smart-enter,
git (estado de git junto al nombre dentro de un repo), full-border (bordes), toggle-pane
y mime-ext (tipo de archivo por la extensión, más rápido en carpetas grandes). Propio, en
`plugins/ficha.yazi` y fuera de `ya pkg`: ficha (las vistas previas con datos).
Reinstalar: `ya pkg install`. Actualizar: `ya pkg upgrade`, y probar antes de commitear.
