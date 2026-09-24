# noctalia: comandos

Desde zsh, `noctalia msg <comando>`. Las teclas que los lanzan están en `keys niri`.

| Comando | Acción |
| --- | --- |
| `config-reload` | Recargar los `.toml` de `~/.config/noctalia` |
| `templates-apply` | Regenerar los temas de ghostty, niri, gtk, btop, helix, bat |
| `color-scheme-get` / `theme-mode-get` | Ver paleta y modo activos |
| `color-scheme-set community "Vesper"` | Probar otra paleta (escribe en settings.toml: luego portar o borrar) |
| `panel-toggle launcher` | Lanzador (también `control-center`, `notification-history`, `session`, `wallpaper`, `tray`, `lockscreen`) |
| `settings-toggle` | Ventana de ajustes |
| `session lock` | Bloquear (también `suspend`, `lock-and-suspend`, `logout`, `reboot`, `shutdown`) |
| `media toggle` | Reproducir/pausar (también `stop`, `next`, `previous`) |
| `volume-up` / `volume-down` / `volume-mute` | Volumen |
| `brightness-up` / `brightness-down` | Brillo (externo por ddcutil) |
| `wallpaper-next` / `wallpaper-random` / `wallpaper-set eDP-1 <ruta>` | Fondos |
| `panel-toggle noctalia/mpvpaper:picker` | Selector de fondos de vídeo |
| `plugin noctalia/mpvpaper:service all clear-all` / `… reapply` / `… toggle` | Parar los vídeos (vuelven las imágenes) / reponer el último / pausar |
| `screenshot-region` / `screenshot-fullscreen` / `screenshot-annotate` | Capturas con edición |
| `nightlight-toggle` / `caffeine-toggle` | Luz nocturna / impedir suspensión |
| `greeter-sync` | Pasar paleta y fondo al greeter (pide contraseña) |
| `status` | Estado en JSON |
| `plugins list` | Plugins (`enable`, `disable`, `update`) |

Fuera de `msg`: `noctalia config export merged`, `noctalia config validate ~/.config/noctalia`,
`noctalia theme <imagen> --scheme vibrant --pure-black -o paleta.json` (paleta propia).
