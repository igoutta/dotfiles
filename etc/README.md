# etc/

Archivos del sistema (fuera de `$HOME`) que este repo también versiona. **No son paquetes
stow**: se copian a mano con `install`, como indica la sección «Dotfiles» de `INSTALL.md`.

| Archivo | Destino | Para qué |
| --- | --- | --- |
| `zsh/zshenv` | `/etc/zsh/zshenv` | Define `ZDOTDIR=~/.config/zsh` para todos los usuarios; sin él zsh busca `~/.zshrc` y la config de `zsh/` no carga. Ubuntu/Fedora: mismo destino; si se prefiere no tocar `/etc`, crear `~/.zshenv` con `export ZDOTDIR="$HOME/.config/zsh"`. |
| `greetd/config.toml` | `/etc/greetd/config.toml` | greetd arranca `noctalia-greeter-session -- --session niri` en el VT 1 como usuario `greeter`. Ubuntu/Fedora: greetd está en sus repos; mismo destino. |
| `pam.d/greetd` | `/etc/pam.d/greetd` | Abre el llavero de gnome-keyring al iniciar sesión (`pam_gnome_keyring.so` en auth y en session con `auto_start`). Fedora: sustituir `system-local-login` por `system-auth`; Ubuntu: por `common-auth`/`common-session`. |
| `noctalia-greeter/greeter.toml` | `/var/lib/noctalia-greeter/greeter.toml` | Capa declarativa del greeter: teclado latam, esquema `Synced` y selector de esquema oculto. Paleta, fondos y salidas llegan por `noctalia msg greeter-sync` a `sync.toml`, sobre el que este archivo manda. Sin bloque de paleta: en 1.5.0 una paleta aquí deja el greeter sin fondo. Propietario `greeter:greeter`, modo 640. Ubuntu/Fedora: mismo destino. |
| `snapper/configs/root` | `/etc/snapper/configs/root` | Instantáneas de la raíz: las de pacman (20 + 5 importantes) y una diaria 7 días; wheel las lista sin sudo. Escrito a mano porque `create-config` quiere crear él `.snapshots`. Análisis en `docs/snapper.md`. |
| `snapper/configs/home` | `/etc/snapper/configs/home` | Instantáneas de `/home`: 12 horas, 7 días, 4 semanas; `~/.cache` y contenedores fuera como subvolúmenes. |
| `snap-pac.ini` | `/etc/snap-pac.ini` | Paquetes que marcan como importante el par pre/post de pacman (kernel, systemd, grub…). |
| `pacman.d/hooks/95-bootbackup.hook` | `/etc/pacman.d/hooks/95-bootbackup.hook` | Copia `/boot` (vfat) a `/.bootbackup` tras cada kernel, para que la instantánea lleve el kernel que casa con sus módulos. |
| `mkinitcpio.conf.d/dotfiles.conf` | `/etc/mkinitcpio.conf.d/dotfiles.conf` | `HOOKS` de la guía más `grub-btrfs-overlayfs` (arrancar instantáneas desde GRUB); `resume` y `btrfs` esperan a la hibernación. Luego `mkinitcpio -P`. Fedora/Ubuntu: dracut. |
| `conf.d/snapper` | `/etc/conf.d/snapper` | Declara la config `root`. Fedora: `/etc/sysconfig/snapper`; Ubuntu: `/etc/default/snapper`. |
| `tmpfiles.d/charge-limit.conf` | `/etc/tmpfiles.d/charge-limit.conf` | Límite de carga de la batería al 80 % en cada arranque, por el driver asus-wmi del kernel; sin asusctl. Ubuntu/Fedora: mismo archivo. |
| `security/pam_env.conf` | `/etc/security/pam_env.conf` | Define `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME` y `XDG_CACHE_HOME` para toda sesión (consola, greetd, SSH), antes de que corra ninguna shell. Mismo archivo y sintaxis en las tres distros. |
