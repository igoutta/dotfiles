# dotfiles

Configuración personal para Arch Linux, desplegada con [GNU Stow](https://www.gnu.org/software/stow/).
Cada carpeta de primer nivel es un *paquete* que refleja `$HOME`; `stow <paquete>` crea
los enlaces simbólicos y el repo queda como única fuente de verdad.

## Estructura

| Ruta | Qué es |
| --- | --- |
| `zsh/` | Shell: `.zshenv`, `.zshrc` modular (`conf.d/NN-*.zsh`), config por máquina en `hosts/`, prompt `starship.toml`, `CHEATSHEET.md` |
| `atuin/` | Historial de shell sincronizable |
| `fastfetch/` | Banner de sistema; logos de texto en `text/` (`.txt`/`.ansi`) e imágenes; README propio |
| `ghostty/` | Terminal: fuente, ventana para niri, shell integration y teclas; el tema lo pone noctalia |
| `tealdeer/` | Cliente tldr (`Alt-h` en zsh) con caché automática |
| `niri/` | Compositor: `config.kdl` solo incluye módulos (`input`, `outputs`, `layout`, `rules`, `binds`, `startup`); los colores los pone noctalia |
| `noctalia/` | Shell del escritorio: config declarativa en cuatro TOML por tema; README con las dos capas de configuración |
| `gtk/` | GTK3/4: adw-gtk3, cursor e iconos Adwaita, y el `gtk.css` que engancha la paleta de noctalia |
| `xdg/` | Apps por defecto: `mimeapps.list` (PhotoQt para imágenes, yazi en ghostty para carpetas, Zen para web), `yazi-ghostty.desktop` y `xdg-terminals.list` |
| `mise/` | Versiones de herramientas: node LTS y pnpm declarados en `config.toml`, `config.yaml` de pnpm con `minimumReleaseAge`, y `environment.d` para que las apps gráficas los vean |
| `etc/` | Archivos del sistema fuera de `$HOME`: zshenv, pam_env, greetd y su PAM. **No es un paquete stow**: se copian con `install`, ver `etc/README.md` |
| `INSTALL.md` | Guía de instalación de Arch (Btrfs + LUKS2 + GRUB) y, al final, despliegue de estos dotfiles |
| `TODO.md` | Hoja de ruta y decisiones tomadas |
| `docs/` | Guías secundarias: alternativas no usadas hoy (`refind.md`) |
| `.stowrc` | Opciones fijas de stow: `--no-folding` (enlaces archivo a archivo, directorios reales) |
| `.stow-local-ignore` | Lo que stow no debe enlazar: docs, licencia, `etc/` |

## Uso rápido

~~~sh
sudo pacman -S --needed stow git
git clone <url-del-repo> ~/dotfiles && cd ~/dotfiles
sudo install -Dm644 etc/zsh/zshenv /etc/zsh/zshenv
stow zsh atuin fastfetch tealdeer ghostty niri noctalia gtk mise
stow zsh atuin fastfetch tealdeer ghostty niri noctalia gtk mise xdg
~~~

Ejecuta `stow` siempre desde `~/dotfiles` para que aplique `.stowrc`. Detalles,
simulación (`stow -n`) y `--adopt` para archivos que ya existan:
[INSTALL.md › Dotfiles](INSTALL.md#dotfiles). Al abrir la primera terminal, `zinit`
descarga los plugins; `keys` muestra teclas y alias.

## Convenciones

- **Solo Arch**, sin ramas para otras distros. Cada línea específica de Arch lleva un
  comentario con cómo adaptarla a Ubuntu y Fedora (paquete, nombre del binario, ruta).
- **Dedos cerca.** Teclas sueltas, acordes con letras cercanas o la misma tecla repetida;
  nunca acorde y luego escribir una palabra. Los solapamientos se resuelven en un solo
  sitio (`zsh/.config/zsh/conf.d/65-keybinds.zsh`).
- **Una chuleta por paquete.** Cada paquete con teclas lleva su `CHEATSHEET.md` junto a la
  config; `keys` en zsh las muestra todas, `keys <app>` una.
- **Por máquina, versionado:** `zsh/.config/zsh/hosts/<hostname>.zsh` (rutas de SDKs,
  alias raros). **Secretos:** `local.zsh` en el mismo directorio, ignorado por git.
- **Herramientas del sistema, no del gestor de plugins.** starship, atuin, zoxide, fzf…
  vienen de pacman; la shell arranca limpia aunque falten (cada integración está
  protegida con `(( $+commands[x] ))`). zinit solo gestiona plugins de zsh.
- **Stow sin plegado** (`--no-folding`, vía `.stowrc`): nunca un enlace a un directorio
  del repo, para que lo que escriban las aplicaciones no acabe versionado. Tras añadir
  un archivo a un paquete, `stow -R <paquete>`.
- **Modularizar.** Todo archivo de configuración largo se parte en módulos por tema
  (`zsh/conf.d/`, `niri/*.kdl` con `include`, `noctalia/*.toml`), cada uno con su porqué.
- **Lo que genera una app no se versiona.** Los temas que noctalia escribe (`noctalia.kdl`,
  `noctalia.css`, `themes/noctalia`) y su `settings.toml` viven junto a cada config, fuera del
  repo; las líneas de enganche que noctalia espera se escriben a mano en el paquete de cada
  app, para que sus scripts no toquen archivos del repo.
- **Un cambio, un commit**, mensajes en español.

## Licencia

[GPL-3.0](LICENSE).
