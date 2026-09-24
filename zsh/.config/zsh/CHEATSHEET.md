# zsh: teclas y alias

Regla: los dedos no viajan. Una tecla, un acorde Ctrl/Alt con una letra cercana, o la
misma tecla repetida (Esc Esc). Nunca "acorde + escribir una palabra". Ver `conf.d/65-keybinds.zsh`.
Mostrar este archivo: `keys zsh`. Todas las chuletas (una por paquete stow): `keys`.

## Modos

| Tecla | Acción |
| --- | --- |
| `Esc` | Entra en modo comando vi (el prompt cambia a `❮`) |
| `i` `a` `I` `A` | Vuelve a modo inserción (teclado emacs) |
| `v` (en modo vi) | Modo visual de zsh (no abre el editor; para eso `Alt-e`) |

## Edición

| Tecla | Acción |
| --- | --- |
| `Alt-e` | Edita la línea en Helix (`$EDITOR`); al guardar y salir vuelve al prompt |
| `Alt-s` | Antepone `sudo` a la línea actual (o a la última ejecutada si está vacía). En modo vi también `Esc Esc`, o sea `Esc Esc Esc` desde inserción |
| `Alt-h` | Página tldr del comando que estás escribiendo (man si no hay tldr); la línea vuelve después |
| `Alt-m` | Página man del comando que estás escribiendo |
| `Ctrl-A` / `Ctrl-E` | Inicio / fin de línea (también `Home` / `End`) |
| `Ctrl-←` / `Ctrl-→` | Palabra anterior / siguiente (también `Alt-←` / `Alt-→`) |
| `Ctrl-W` / `Ctrl-Backspace` | Borra la palabra anterior |
| `Ctrl-Delete` | Borra la palabra siguiente |
| `Ctrl-K` / `Ctrl-U` | Borra hasta el final / toda la línea |
| `Ctrl-Y` | Pega lo último borrado |
| `Ctrl-_` | Deshacer |
| `Ctrl-L` | Limpia la pantalla |
| `Ctrl-Q` | Aparta la línea actual, la recupera tras el siguiente comando |

Las palabras se cortan en `/ . - _`, así que `Ctrl-W` borra un componente de ruta.

## Historial (atuin)

| Tecla | Acción |
| --- | --- |
| `Ctrl-R` | Búsqueda interactiva en atuin (también en modo vi) |
| `↑` | Historial filtrado por lo ya escrito (atuin) |
| `Ctrl-P` / `Ctrl-N` | Historial de zsh sin atuin, anterior / siguiente |
| `!!` `!$` | Último comando / último argumento (con `HIST_VERIFY` se muestra antes de ejecutar) |
| ` cmd` (espacio delante) | No se guarda en el historial de zsh |

## Completado (fzf-tab) y sugerencias

| Tecla | Acción |
| --- | --- |
| `Tab` | Menú fzf-tab; `Tab` de nuevo acepta |
| `<` / `>` | Cambia de grupo dentro del menú |
| `ruta/**Tab` | Buscador de archivos de fzf en lugar del menú |
| `→` o `End` | Acepta la sugerencia gris completa (zsh-autosuggestions) |
| `Ctrl-→` | Acepta la sugerencia palabra a palabra |

## Herramientas

| Tecla / comando | Acción |
| --- | --- |
| `Ctrl-T` | Buscar archivo con fzf e insertarlo |
| `Alt-c` | `cd` a un directorio elegido con fzf |
| `Ctrl-G` | navi: hojas de trucos interactivas |
| `z dir` / `zi` | zoxide: saltar a un directorio frecuente / elegirlo |
| `y` | yazi; al salir hace `cd` a donde te quedaste |
| `f` | pay-respects: corrige el último comando fallido |

## Alias (de dónde salen)

| Origen | Ejemplos | Listarlos |
| --- | --- | --- |
| `70-aliases.zsh` | `grep`→`rg`, `glog`, `gadog`, `dotfiles`, `dots`, `keys`, `compreset` | `bat $ZDOTDIR/conf.d/70-aliases.zsh` |
| OMZ git | `g`, `ga`, `gc`, `gp`, `gst`, `gco`… | `alias \| rg '^g'` |
| OMZ directories | `..`, `...`, `d`, `1`…`9` | `alias \| rg "^\.\."` |
| OMZ systemd | `sc-status`, `sc-restart`, `scu-*` | `alias \| rg '^sc'` |
| OMZ eza | `ls`, `ll`, `la`, `lt`, `lx` | `alias \| rg eza` |
| hosts/tuf.zsh | `stream` | — |

## Mantenimiento

| Comando | Cuándo |
| --- | --- |
| `compreset` | Un paquete recién instalado no completa (la caché dura 24 h) |
| `zinit update` | Actualizar plugins |
| `zinit delete --clean` | Borrar clones de plugins que ya no están en la config |
| `bindkey -M emacs` / `bindkey -M vicmd` | Ver todas las teclas reales de cada modo |
