# niri: teclas

`Mod` = tecla Super. Patrón: **Mod** enfoca · **Mod+Ctrl** mueve dentro del monitor ·
**Mod+Shift** cambia de monitor (foco) o mueve el workspace · **Mod+Alt** mueve a otro
monitor. Lista viva en pantalla: `Mod+F1`. Definidas en `binds.kdl`.

Teclado latam: los símbolos que no tienen tecla propia (`/` `=` `[` `]`) no sirven en atajos;
por eso aquí se usan `F1`, `+`, `,` y `.` donde la plantilla de niri usaba otros. En este
portátil (TUF F15) `Inicio`, `Fin`, `RePág` y `AvPág` van con `Fn`+flechas, así que tampoco:
primera/última columna en `Mod+A`/`Mod+E` y workspaces en `Mod+U`/`Mod+I`.

## noctalia

| Tecla | Acción |
| --- | --- |
| `Mod+Espacio` | Lanzador |
| `Mod+S` | Centro de control |
| `Mod+N` | Historial de notificaciones |
| `Mod+Shift+S` | Ajustes de noctalia |
| `Alt+Tab` | Selector de ventanas |
| `Mod+Alt+Esc` | Bloquear pantalla |
| `Mod+T` | Terminal (ghostty) |
| `Mod+F1` | Lista de teclas en pantalla |

## Ventanas y foco

| Tecla | Acción |
| --- | --- |
| `Mod+←↓↑→` o `Mod+H J K L` | Enfocar columna / ventana |
| `Mod+Ctrl+←↓↑→` o `Mod+Ctrl+H J K L` | Mover columna / ventana |
| `Mod+A` / `Mod+E` | Primera / última columna, como `Ctrl+A`/`Ctrl+E` en la shell (con `Ctrl`, mover ahí) |
| `Mod+Q` | Cerrar ventana |
| `Mod+O` | Vista general (overview) |
| `Mod+V` / `Mod+Shift+V` | Flotar ventana / saltar entre flotantes y mosaico |
| `Mod+W` | Columna en pestañas |

## Monitores y workspaces

| Tecla | Acción |
| --- | --- |
| `Mod+Shift+←↓↑→` o `Mod+Shift+H J K L` | Enfocar monitor |
| `Mod+Alt+←↓↑→` o `Mod+Alt+H J K L` | Mover la columna a ese monitor |
| `Mod+U` / `Mod+I` | Workspace abajo / arriba |
| `Mod+Ctrl+U` / `Mod+Ctrl+I` | Mover la columna al workspace de abajo / arriba |
| `Mod+Shift+U` / `Mod+Shift+I` | Mover el workspace entero |
| `Mod+1`…`9` / `Mod+Ctrl+1`…`9` | Ir al workspace N / mover la columna al N |
| `Mod+rueda` / `Mod+Ctrl+rueda` | Workspace / mover columna de workspace |
| `Mod+Shift+rueda` / `Mod+Alt+rueda` | Enfocar / mover columna a los lados |

## Columnas y tamaños

| Tecla | Acción |
| --- | --- |
| `Mod+R` / `Mod+Shift+R` | Siguiente / anterior ancho preset (⅓, ½, ⅔) |
| `Mod+Alt+R` / `Mod+Ctrl+R` | Alto preset / restablecer alto |
| `Mod+-` / `Mod++` | Ancho −10 % / +10 % (con `Shift`, alto) |
| `Mod+F` / `Mod+Shift+F` | Maximizar columna / pantalla completa |
| `Mod+M` | Maximizar hasta los bordes |
| `Mod+Ctrl+F` | Expandir la columna al ancho libre |
| `Mod+C` / `Mod+Ctrl+C` | Centrar columna / centrar las visibles |
| `Mod+,` / `Mod+.` | Absorber ventana en la columna / expulsarla |
| `Mod+Shift+,` / `Mod+Shift+.` | Meter o sacar la ventana de la columna vecina |

## Multimedia, capturas y sesión

| Tecla | Acción |
| --- | --- |
| Teclas de volumen y brillo | Por noctalia; funcionan con la pantalla bloqueada |
| Teclas de reproducción | `noctalia msg media …` |
| `Print` / `Ctrl+Print` / `Alt+Print` | Captura de región / pantalla / ventana → `~/Pictures/Screenshots` |
| `Mod+Esc` | Dejar pasar todos los atajos a la app (VM, escritorio remoto) |
| `Mod+Shift+P` | Apagar monitores |
| `Mod+Shift+E` o `Ctrl+Alt+Supr` | Salir de niri |
