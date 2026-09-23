# dotfiles

Configuración personal para Arch Linux, desplegada con [GNU Stow](https://www.gnu.org/software/stow/).
Cada carpeta de primer nivel es un *paquete* que refleja `$HOME`; `stow <paquete>` crea
los enlaces simbólicos y el repo queda como única fuente de verdad.

## Estructura

| Ruta | Qué es |
|---|---|
| `zsh/` | Shell: `.zshenv`, `.zshrc` modular (`conf.d/NN-*.zsh`), config por máquina en `hosts/`, prompt `starship.toml`, `CHEATSHEET.md` |
| `atuin/` | Historial de shell sincronizable |
| `fastfetch/` | Banner de sistema, con ASCII e imágenes propias |
| `etc/` | Archivos del sistema fuera de `$HOME` (hoy `/etc/zsh/zshenv`). **No es un paquete stow**: se copian con `install`, ver `etc/README.md` |
| `INSTALL.md` | Guía de instalación de Arch (Btrfs + LUKS2 + GRUB) y, al final, despliegue de estos dotfiles |
| `TODO.md` | Hoja de ruta y decisiones tomadas |
| `.stow-local-ignore` | Lo que stow no debe enlazar: docs, licencia, `etc/` |

## Uso rápido

~~~sh
sudo pacman -S --needed stow git
git clone <url-del-repo> ~/dotfiles && cd ~/dotfiles
sudo install -Dm644 etc/zsh/zshenv /etc/zsh/zshenv
stow zsh atuin fastfetch
~~~

Detalles, simulación (`stow -n -v`) y `--adopt` para archivos que ya existan:
[INSTALL.md › Dotfiles](INSTALL.md#dotfiles). Al abrir la primera terminal, `zinit`
descarga los plugins; `keys` muestra teclas y alias.

## Convenciones

- **Solo Arch**, sin ramas para otras distros. Cada línea específica de Arch lleva un
  comentario con cómo adaptarla a Ubuntu y Fedora (paquete, nombre del binario, ruta).
- **Atajos de una sola pulsación.** Nada de secuencias tipo `Esc Esc`; los solapamientos
  entre herramientas se resuelven en un solo sitio (`zsh/.config/zsh/conf.d/65-keybinds.zsh`).
- **Por máquina, versionado:** `zsh/.config/zsh/hosts/<hostname>.zsh` (rutas de SDKs,
  alias raros). **Secretos:** `local.zsh` en el mismo directorio, ignorado por git.
- **Herramientas del sistema, no del gestor de plugins.** starship, atuin, zoxide, fzf…
  vienen de pacman; la shell arranca limpia aunque falten (cada integración está
  protegida con `(( $+commands[x] ))`). zinit solo gestiona plugins de zsh.
- **Un cambio, un commit**, mensajes en español.

## Licencia

[GPL-3.0](LICENSE).
