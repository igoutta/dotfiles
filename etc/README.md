# etc/

Archivos del sistema (fuera de `$HOME`) que este repo también versiona. **No son paquetes
stow**: se copian a mano con `install`, como indica la sección «Dotfiles» de `INSTALL.md`.

| Archivo | Destino | Para qué |
| --- | --- | --- |
| `zsh/zshenv` | `/etc/zsh/zshenv` | Define `ZDOTDIR=~/.config/zsh` para todos los usuarios; sin él zsh busca `~/.zshrc` y la config de `zsh/` no carga. Ubuntu/Fedora: mismo destino; si se prefiere no tocar `/etc`, crear `~/.zshenv` con `export ZDOTDIR="$HOME/.config/zsh"`. |
| `greetd/config.toml` | `/etc/greetd/config.toml` | greetd arranca `noctalia-greeter-session -- --session niri` en el VT 1 como usuario `greeter`. Ubuntu/Fedora: greetd está en sus repos; mismo destino. |
| `pam.d/greetd` | `/etc/pam.d/greetd` | Abre el llavero de gnome-keyring al iniciar sesión (`pam_gnome_keyring.so` en auth y en session con `auto_start`). Fedora: sustituir `system-local-login` por `system-auth`; Ubuntu: por `common-auth`/`common-session`. |
| `security/pam_env.conf` | `/etc/security/pam_env.conf` | Define `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME` y `XDG_CACHE_HOME` para toda sesión (consola, greetd, SSH), antes de que corra ninguna shell. Mismo archivo y sintaxis en las tres distros. |
