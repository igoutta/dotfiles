[BTRFS + LUKS2 + GRUB](https://gist.github.com/WELL1NGTON/47ab9f38ace6368636bebd75c1e17f8c)
[BTRFS + GRUB2: Simple but detailed](https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae)
[BTRFS + LUKS2 + Limine: All you need](https://gist.github.com/albisserAdrian/fb360fd4c4fb5d954809ea29db0c4450)
[BTRFS + LUKS2 + Systemd-boot: Simple guide](https://wiki.archlinux.org/title/User:ZachHilman/Installation_-_Btrfs_%2B_LUKS2_%2B_Secure_Boot)
[BTRFS + LUKS2 + UKI: Detailed guide](https://dev.to/thes1lv3r/installing-arch-linux-on-btrfs-with-luks-and-automatic-tpm2-unlocking-3oio)
[GRUB Crypted 1](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_(GRUB))
[GRUB Crypted 2](https://wiki.archlinux.org/title/GRUB#Encrypted_/boot)

# Guía de instalación de Arch avanzada

# Pasos preliminares

Primero configure el diseño de su teclado:
~~~sh
loadkeys la-latin1    # alternativas: es, us
~~~

Comprueba la conexión a internet:
~~~sh
ping -c 3 archlinux.org
~~~

~~~sh
iwctl station wlan0 connect 'NombreDeRed' --passphrase 'contraseña'
~~~

Compruebe el reloj del sistema:
~~~sh
timedatectl set-ntp 1
~~~

Verifica el número de bits de la UEFI:
~~~sh
cat /sys/firmware/efi/fw_platform_size
~~~

### Conexión SSH

1. Chequear estatus del servicio *sshd*
~~~sh
systemctl status sshd
~~~

2. Si no esta activo, iniciarlo con este comando
~~~sh
systemctl start sshd
~~~

3. Cambia la contraseña del usuario root del instalador.
~~~sh
passwd
~~~

4. En la terminal de otro dispositivo, inicia la conexión de esta manera.
~~~sh
ssh root@archiso
~~~

## Particionado del Disco
~~~sh
lsblk -fpo NAME,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS
~~~

### Limpieza del disco

Si se desea, se puede eliminar de manera rápida el disco y las particiones del mismo utilizando el siguiente comando:

~~~sh
blkdiscard -f *DRIVE*
~~~

Si quieres realizar un borrado mucho mas seguro puedes utilizar el siguiente comando:

~~~sh
dd if=/dev/urandom bs=10M status=progress of=*DRIVE*
~~~

### Definir las particiones

Dos particiones, no tres: la ESP y un solo contenedor LUKS que dentro lleva swap y raíz como
volúmenes lógicos (LVM). Así la swap queda cifrada con clave persistente sin archivos de clave
en `/boot`, se puede cambiar de tamaño cuando haga falta (`lvresize`), y la hibernación sale
sola. La instalación de 2026-08 usaba tres particiones con la swap en medio y de clave
aleatoria; de ahí venía que no se pudiera hibernar ni agrandar la swap.

~~~sh
sgdisk --clear \
       --new=1:0:+1GiB --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:0     --typecode=2:8309 --change-name=2:cryptsystem *DRIVE*
~~~

### Configurar el cifrado del contenedor principal

GRUB abre este contenedor para leer el kernel (`/boot` va cifrado, dentro de la raíz). GRUB
2.14 y posteriores entienden Argon2, pero su implementación es lenta y necesita mucha memoria
en el arranque; la ranura de la contraseña va con PBKDF2, que GRUB abre en segundos. La ranura
de la clave de archivo que usa el initramfs (más abajo) sí va con Argon2id.

PBKDF2 resiste peor que Argon2id un ataque por fuerza bruta con GPU, y se compensa con
longitud: 20 caracteres o más. Si en la prueba en máquina virtual GRUB abre en pocos segundos
una ranura Argon2id con memoria limitada (`--pbkdf argon2id --pbkdf-memory 262144`), usar esa
en vez de PBKDF2; lo que no se puede es dejar la memoria por defecto, que GRUB no tiene.

**La contraseña se teclea en GRUB con distribución US y sin eco**: solo letras minúsculas y
dígitos, que están en el mismo sitio en US y en latam. Nada de `-`, `'`, `¿` ni mayúsculas
con símbolos. Una contraseña mal tecleada en GRUB acaba en `grub rescue>`; se reinicia y se
vuelve a intentar.

~~~sh
cryptsetup luksFormat \
           --type luks2 \
           --cipher aes-xts-plain64 \
           --key-size 512 \
           --hash sha512 \
           --pbkdf pbkdf2 \
           --iter-time 2000 \
           --use-urandom \
           --verify-passphrase \
           /dev/disk/by-partlabel/cryptsystem
~~~

~~~sh
cryptsetup open /dev/disk/by-partlabel/cryptsystem system
~~~

### LVM dentro del contenedor: swap y raíz

~~~sh
pvcreate /dev/mapper/system
vgcreate system /dev/mapper/system
lvcreate -L 34G -n swap system          # ≥ RAM (32 G) para hibernar; luego se cambia con lvresize
lvcreate -l 100%FREE -n root system
mkswap -L swap /dev/system/swap && swapon /dev/system/swap
~~~

### Formatear y montar el sistema de archivos con subvolumenes usando BTRFS

`/boot` no es una partición: es un directorio dentro de `@`, cifrado y dentro de cada
instantánea, así que una vuelta atrás lleva el kernel que casa con sus módulos.

~~~sh
mkfs.btrfs --label system --nodesize 32k /dev/system/root
mount -t btrfs LABEL=system /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@spool
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@containers
btrfs subvolume create /mnt/@libvirt
~~~

~~~sh
umount -R /mnt
~~~

~~~sh
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@ LABEL=system /mnt
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@snapshots LABEL=system /mnt/.snapshots
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@home LABEL=system /mnt/home
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@opt LABEL=system /mnt/opt
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@srv LABEL=system /mnt/srv
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@spool LABEL=system /mnt/var/spool
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@log LABEL=system /mnt/var/log
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@cache LABEL=system /mnt/var/cache
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,compress=zstd,subvol=@tmp LABEL=system /mnt/var/tmp
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,subvol=@containers LABEL=system /mnt/var/lib/containers
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,subvol=@libvirt LABEL=system /mnt/var/lib/libvirt
~~~

`nodatacow` **no** funciona como opción de montaje por subvolumen: btrfs solo respeta las
opciones del primer montaje del sistema de archivos y las demás se ignoran en silencio
(el sistema actual lo confirma: `@containers` y `@libvirt` montan con `compress=zstd` y
con CoW activo). Lo correcto es marcar los directorios mientras están vacíos:

~~~sh
chattr +C /mnt/var/lib/containers /mnt/var/lib/libvirt
lsattr -d /mnt/var/lib/containers /mnt/var/lib/libvirt    # debe mostrar la C
~~~

Para cambiar una opción de un punto ya montado sin desmontar:

~~~sh
mount -o remount,<opciones> /mnt/<punto>
~~~

### Formatear y montar la partición EFI en /efi

Solo lleva el binario de GRUB; el kernel y el initramfs viven cifrados en `/boot`.

~~~sh
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mount --mkdir LABEL=EFI /mnt/efi
~~~

## Actualización de los repositorios espejo óptimos para descarga

`-c` filtra qué países entran. Los mirrors globales (`geo.mirror.pkgbuild.com`,
`fastly.mirror.pkgbuild.com`, `mirror.rackspace.com`…) no tienen país asignado, así que ni
`Worldwide` ni ningún código los selecciona; `*` los incluía, pero a costa de anular el
filtro de países. La cadena vacía `''` selecciona **solo** los globales, y con dos
llamadas quedan los países elegidos por puntuación y los globales al final como respaldo.
Se mantiene `http` a propósito: hay mirrors de los países cercanos que solo sirven por
http y con `-p https` desaparecerían del filtro; pacman verifica las firmas de los
paquetes, así que el transporte no compromete la integridad. El `-p` es obligatorio por otra
razón: sin él reflector incluye entradas `rsync://`, y pacman descarga con libcurl, que no
habla rsync (esos mirrors son para que otros mirrors se sincronicen).

~~~sh
reflector --verbose --sort score --save /etc/pacman.d/mirrorlist --ipv4 --threads 4 -p http,https -c 'ec,de,us,co,pe,cl' -l 250 -f 50 -a 6
reflector --sort score -p https -c '' -a 6 | sed '/^#/d' >> /etc/pacman.d/mirrorlist
mkdir -p /mnt/etc/pacman.d
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
cat !$
~~~

## Últimos detalles

~~~sh
printf 'KEYMAP=la-latin1\nFONT=ter-132b\n' > /mnt/etc/vconsole.conf
cat !$
~~~

## Instalación de paquetes esenciales

~~~sh
# This will install some packages to "bootstrap" methaphorically our system. Feel free to add the ones you want
# "base, linux, linux-firmware" are needed. If you want a more stable kernel, then swap linux with linux-lts
# "base-devel" base development packages

# "intel-ucode" microcode updates for the cpu. If you have an AMD one use "amd-ucode"

# "efibootmgr" needed to install grub
# "btrfs-progs" are user-space utilities for file system management ( needed to harness the potential of btrfs )
# "lvm2" volúmenes lógicos dentro del LUKS (swap y raíz) y el hook lvm2 del initramfs
# "inotify-tools" used by grub btrfsd deamon to automatically spot new snapshots and update grub entries
# "grub" the bootloader
# "grub-btrfs" adds btrfs support for the grub bootloader and enables the user to directly boot from snapshots

# Instantáneas: snapper + snap-pac se instalan y configuran tras el primer arranque (fase «Mantenimiento»);
#   grub-btrfs y grub-btrfsd las muestran en GRUB. timeshift descartado: snapper va solo y encaja con grub-btrfs

# "networkmanager" to manage Internet connections both wired and wireless ( it also has an applet package network-manager-applet )
# "openssh" to use ssh and manage keys
# "pipewire pipewire-alsa pipewire-pulse pipewire-jack" for the new audio framework replacing pulse and jack. 
# "wireplumber" the pipewire session manager.

# "zsh" my favourite shell, "zsh-doc" its manual. Plugins (autosuggestions, syntax-highlighting,
#   completions, fzf-tab) are NOT installed from pacman: zinit manages all of them from the dotfiles,
#   so one tool updates them (`zinit update`) and the same config works on Ubuntu/Fedora
# "starship" prompt, "atuin" shell history
# terminus-font for ter-132 family font for the hooks

# "helix" my editor ($EDITOR). "micro" editor de respaldo en la consola. "neovim" installed but never configured (see TODO.md)

# "mandoc" provides man (instead of man-db), "man-pages" the pages themselves
# "navi" is an interactive cheatsheet tool for the command-line (Ctrl-G in zsh)
# "vivid" LS_COLORS themes, "tealdeer" tldr client (Alt-h in zsh), "less" pager: the dotfiles expect them
# "git" to install the git vcs, "stow" to deploy the dotfiles
# "pkgstats" to help arch4edu learn the trends of the packages they maintain

# Optional, not installed by default: dracut sof-firmware (instead of mkinitcpio / Intel SOF audio),
#   dnsmasq libnvme modemmanager openresolv pacrunner ppp (extra networking),
#   udisks2-btrfs libblockdev-btrfs (btrfs support in udisks).
# Keep every continuation line ending in a bare backslash: "\ # comment" is NOT a
#   continuation (the backslash escapes the space) and the command silently ends there.
pacstrap -iK /mnt base base-devel \
                  linux linux-headers linux-firmware intel-ucode mkinitcpio \
                  efibootmgr btrfs-progs inotify-tools fuse3 ntfs-3g ntfsprogs dosfstools cryptsetup lvm2 \
                  grub grub-btrfs os-prober \
                  util-linux dhcpcd networkmanager iwd firewalld bluez bluez-utils cups \
                  avahi acpi acpi_call acpid \
                  alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
                  zsh zsh-doc starship atuin \
                  terminus-font ttf-dejavu ttf-firacode-nerd \
                  micro helix neovim \
                  bat zoxide fzf eza ripgrep direnv rsync jq btop yazi udisks2 vivid tealdeer less \
                  mandoc man-pages navi lsb-release fastfetch \
                  openssh git stow pkgstats
~~~

## Generar y editar correctamente la tabla del sistema de archivos (fstab)

~~~sh
genfstab -L -p /mnt >> /mnt/etc/fstab
cat !$
~~~

### Comprobar swap y raíz en fstab

`genfstab -L` deja la swap como `LABEL=swap` y la raíz como `LABEL=system`; los dos son
volúmenes lógicos dentro del LUKS y systemd los resuelve. No hace falta `crypttab`: el
initramfs abre el contenedor con la clave de archivo y LVM activa el resto.

~~~sh
rg -n 'swap|LABEL=system.* / ' /mnt/etc/fstab
~~~

~~~sh
echo tuf > /mnt/etc/hostname
cat !$
~~~

~~~sh
printf '127.0.1.1\ttuf\n' >> /mnt/etc/hosts
cat !$
~~~

~~~sh
printf 'LANG=es_EC.UTF-8\nLC_MESSAGES=en_US.UTF-8\n' > /mnt/etc/locale.conf
cat !$
~~~

~~~sh
sed -i -E 's/^#(es_EC|en_US)\.UTF-8 UTF-8/\1.UTF-8 UTF-8/' /mnt/etc/locale.gen
cat !$
~~~

### Huso horario

~~~sh
ln -sf /usr/share/zoneinfo/America/Guayaquil /mnt/etc/localtime
cat !$
~~~

~~~sh
arch-chroot /mnt
~~~

~~~sh
hwclock --systohc
~~~

`timedatectl` y `localectl` no funcionan dentro del chroot (no hay systemd corriendo):
NTP y el teclado de X11 se configuran tras el primer arranque, más abajo.

~~~sh
locale-gen
~~~

~~~sh
export LANG=es_EC.UTF-8
export EDITOR=helix
~~~

### Añadir repositorios extra al gestor de paquetes (pacman)

~~~sh
pacman-key --recv-keys 7931B6D628C8D3BA
pacman-key --finger 7931B6D628C8D3BA
pacman-key --lsign-key 7931B6D628C8D3BA
helix /etc/pacman.conf
~~~

~~~sh
ILoveCandy

[arch4edu]
Include = /etc/pacman.d/arch4edu-mirrorlist
~~~

~~~sh
curl -s https://api.arch4edu.org/status/mirrors.json | jq -r --argjson cutoff "$(date -d '30 days ago' +%s 2>/dev/null)" '
  .mirrors[] 
  | select(.status != "error")
  | select(.timestamp != null)
  | select(.timestamp > $cutoff)
  | "Server = " + .url + "$arch"
' > /etc/pacman.d/arch4edu-mirrorlist
cat !$
~~~

El sha1 cambia cada vez que BlackArch actualiza `strap.sh`: comprobar el vigente en
<https://blackarch.org/downloads.html> antes de ejecutar, o el `else` lo rechazará.

~~~sh
curl -O https://blackarch.org/strap.sh && \
       if echo "00688950aaf5e5804d2abebb8d3d3ea1d28525ed  strap.sh" | sha1sum -c >/dev/null 2>&1; \
       then chmod +x strap.sh && ./strap.sh; \
       else echo "[!] Checksum FAILED — strap.sh NOT executed." && rm -f strap.sh; fi
~~~

~~~sh
pacman -S xdg-utils xdg-user-dirs dialog
~~~

Clave de archivo para que el initramfs abra la raíz sin pedir la contraseña por segunda vez
(GRUB ya la pidió). Va dentro del initramfs, que vive en `/boot` cifrado; nunca en la ESP.

~~~sh
mkdir -m 700 /etc/keys && dd if=/dev/urandom of=/etc/keys/system.key bs=4096 count=1 && chmod 000 /etc/keys/system.key
cryptsetup luksAddKey --pbkdf argon2id /dev/disk/by-partlabel/cryptsystem /etc/keys/system.key
~~~

~~~sh
helix /etc/mkinitcpio.conf
~~~

`encrypt` abre el LUKS con la clave (`cryptkey=` en la línea del kernel), `lvm2` activa swap y
raíz, `resume` reanuda desde `/dev/system/swap` y `grub-btrfs-overlayfs` permite arrancar una
instantánea de solo lectura desde GRUB. Sin `btrfs` (solo para Btrfs en varios discos) ni
`tpm_crb`. El paquete `grub-btrfs` ya está instalado por pacstrap, así que el hook existe.

~~~sh
MODULES=(btrfs i915)
BINARIES=(/usr/bin/btrfs)
FILES=(/etc/keys/system.key)
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 resume filesystems fsck grub-btrfs-overlayfs)
COMPRESSION="zstd"
COMPRESSION_OPTIONS=(-v -5 --long)
~~~

~~~sh
mkinitcpio -P
chmod 600 /boot/initramfs-linux*.img      # llevan la clave; /boot ya está cifrado, pero por si acaso
~~~

Note: ==> WARNING: Possibly missing firmware for module: 'qat_6xxx'

Esta guía usa GRUB con `/boot` cifrado. La alternativa con rEFInd está en
[docs/refind.md](docs/refind.md). **El orden importa**: `GRUB_ENABLE_CRYPTODISK=y` tiene que
estar en `/etc/default/grub` antes de `grub-install`; si no, el núcleo de GRUB sale sin los
módulos de cifrado, no encuentra su propio `/boot` y arranca en `grub rescue>`. Ese fue el
fallo de los intentos de 2026-08 (la guía de entonces instalaba GRUB primero), sumado a la
contraseña tecleada en distribución US sin eco.

El hook `encrypt` acepta `UUID=`, `LABEL=`, `PARTUUID=` y `PARTLABEL=` en `cryptdevice=`, así
que no hace falta copiar ningún UUID: la etiqueta de partición que puso `sgdisk` basta, y el
archivo queda igual en cualquier máquina que siga esta guía.

~~~sh
helix /etc/default/grub
~~~

~~~sh
GRUB_ENABLE_CRYPTODISK=y
GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=PARTLABEL=cryptsystem:system:allow-discards cryptkey=rootfs:/etc/keys/system.key root=/dev/system/root rootflags=subvol=@ resume=/dev/system/swap loglevel=3 quiet"
GRUB_DISABLE_OS_PROBER=false      # encuentra Windows de otros discos
GRUB_DEFAULT=saved                # recuerda la última entrada elegida
GRUB_SAVEDEFAULT=true
~~~

Las entradas de instantáneas de grub-btrfs no deben reanudar una imagen de hibernación:

~~~sh
sed -i 's|^#GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=.*|GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="noresume"|' /etc/default/grub-btrfs/config
~~~

~~~sh
grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
~~~

En el primer arranque GRUB pide la contraseña del contenedor (teclado US, sin eco), tarda unos
segundos en abrirlo y en leer kernel e initramfs, y el initramfs ya no vuelve a preguntar.
Si aparece `grub rescue>`, la causa casi siempre es una de las dos de arriba; desde ahí
`cryptomount -a` permite reintentar la contraseña sin reiniciar.

`mkinitcpio-numlock` (AUR) se instala con yay tras el primer arranque si se quiere el
teclado numérico activo en el prompt de LUKS.

~~~sh
useradd -m -U -G wheel,users,uucp,storage,power --shell /bin/zsh ga
passwd ga
printf '%%wheel ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/10-wheel && chmod 440 /etc/sudoers.d/10-wheel && visudo -c   # sudo para wheel; /etc/sudoers queda intacto
~~~

~~~sh
su ga -c "xdg-user-dirs-update"
~~~

Los directorios XDG se crean **como ga**. Un `mkdir` aquí, que corre como root, los deja
con dueño root y todo lo que se escriba después dentro (por ejemplo `.zshrc`) hereda el
problema; así acabó este sistema con un `.zshrc` de root.

~~~sh
install -d -o ga -g ga /home/ga/{.config,.config/zsh,.cache,.local,.local/share,.local/state}
~~~

Las variables `XDG_*` de sesión (`/etc/security/pam_env.conf`) se instalan desde el repo en la
sección [Dotfiles](#dotfiles), junto con `/etc/zsh/zshenv`, greetd y PAM. Hasta entonces
rigen las rutas por defecto, que son las mismas.

El `ZDOTDIR` global (`/etc/zsh/zshenv`) se instala desde el repo en la sección
[Dotfiles](#dotfiles) del final, una vez clonado.

Fuentes. `nerd-fonts` es un **grupo** de 71 paquetes (varios GB); este sistema solo tiene
`ttf-firacode-nerd`, que ya va en pacstrap. `adobe-source-sans-fonts` es el nombre actual
de `adobe-source-sans-pro-fonts`.

~~~sh
pacman -S gnu-free-fonts powerline-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji woff2-font-awesome \
          ttf-hack ttf-inconsolata ttf-liberation ttf-ubuntu-font-family ttf-bitstream-vera \
          adobe-source-sans-fonts ttf-anonymous-pro
~~~

~~~sh
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable acpid
~~~

~~~sh
exit
umount -R /mnt
reboot
~~~

# Tras el primer arranque

~~~sh
nmcli device wifi connect 'ssid' password 'password'
sudo timedatectl set-ntp true
sudo localectl set-x11-keymap latam,us
~~~

~~~sh
sudo pacman -S --needed ffmpeg pipewire pipewire-audio pipewire-pulse pipewire-jack wireplumber
sudo pacman -S --needed hunspell-en_us aspell-en gst-plugins-good icedtea-web gufw dnscrypt-proxy 7zip tar rsync vlc keepassxc kdeconnect
~~~

~~~sh
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
~~~

~~~sh
yay -S pay-respects mmtui ghostmirror
~~~

# Escritorio: niri + noctalia

Como usuario con sudo, tras el primer arranque. Sesión gráfica: niri (compositor Wayland
de mosaico desplazable) con noctalia como shell (barra, lanzador, notificaciones, fondos,
bloqueo, capturas, portapapeles) y noctalia-greeter como pantalla de entrada sobre greetd.
Con eso no hacen falta swaylock, fuzzel, playerctl, wl-clipboard, grim ni mako.

~~~sh
# "niri" el compositor. "xwayland-satellite" X11 para apps sin Wayland; niri 26 lo arranca solo
# "greetd" gestor de entrada mínimo; el greeter lo pone noctalia-greeter (AUR, abajo)
# "gnome-keyring" llavero de secretos y SSH; "seahorse" su interfaz. PAM lo abre al entrar (etc/pam.d/greetd)
# "xdg-desktop-portal-gnome" y "-gtk" portales: capturas, diálogos de archivo y tema para Flatpak y navegadores
# "polkit" autorización de acciones privilegiadas; "polkit-gnome" el agente que pide la contraseña
#   (noctalia no lo trae; sin él el sync del greeter y cualquier acción privilegiada fallan en silencio)
# "adw-gtk-theme" GTK3 con el aspecto de libadwaita; es el que colorea la plantilla gtk3 de noctalia
# "adwaita-cursors" cursor Adwaita, el mismo que declaran niri (startup.kdl) y gtk (settings.ini)
# "power-profiles-daemon" perfiles de energía (ahorro, equilibrado, rendimiento); es lo que noctalia muestra y cambia
# "ddcutil" brillo del monitor externo por DDC/CI desde noctalia; requiere el grupo i2c (abajo)
# "udiskie" monta solo los USB al conectarlos y avisa; yazi es el gestor de archivos principal y no tiene barra
#   lateral donde pulsar como Nautilus. "gvfs-mtp" el móvil por USB (gio mount)
# "ffmpegthumbnailer" y "webp-pixbuf-loader" miniaturas de vídeo y webp en Nautilus y diálogos GTK
# "wl-clipboard" wl-copy/wl-paste para Helix, yazi y scripts (el historial lo lleva noctalia)
# "xdg-terminal-exec" GLib abre en ghostty toda app con Terminal=true (yazi como gestor de carpetas); paquete stow xdg
sudo pacman -S --needed niri xwayland-satellite \
                        greetd gnome-keyring seahorse \
                        xdg-desktop-portal-gnome xdg-desktop-portal-gtk polkit polkit-gnome \
                        adw-gtk-theme adwaita-cursors power-profiles-daemon ddcutil \
                        udiskie ffmpegthumbnailer webp-pixbuf-loader gvfs-mtp wl-clipboard xdg-terminal-exec
~~~

~~~sh
# "noctalia" la shell. Su config declarativa está en el paquete stow noctalia/ (ver su README.md)
# "noctalia-greeter" pantalla de entrada con la misma paleta y fondo (noctalia msg greeter-sync)
# "mpvpaper" fondos de vídeo, uno por salida, gestionados por el plugin mpvpaper de noctalia
# "socat" el plugin lo usa para seguir qué vídeo va en una presentación; sin él solo falla ese seguimiento
# "photoqt" visor de imágenes (Qt, interfaz translúcida); loupe descartado
sudo pacman -S --needed noctalia socat
yay -S noctalia-greeter mpvpaper photoqt
~~~

Ubuntu/Fedora: niri en Fedora por COPR `yalter/niri`, en Ubuntu sin paquete oficial; noctalia
y su greeter desde sus releases de GitHub; greetd está en los repos de ambas.

~~~sh
sudo systemctl enable greetd                       # entra por greetd en el VT 1 (etc/greetd/config.toml)
systemctl --user enable gnome-keyring-daemon.socket
sudo systemctl enable --now power-profiles-daemon       # perfiles de energía para noctalia
sudo usermod -aG i2c "$USER"                            # ddcutil: brillo del monitor externo; aplica al volver a entrar
sudo localectl set-x11-keymap latam                # teclado para X11; niri lleva el suyo en input.kdl y el greeter en greeter.toml
~~~

Los portales GNOME y las apps libadwaita leen dconf, no `settings.ini`:

~~~sh
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
~~~

La configuración de niri, noctalia, gtk y ghostty, y los archivos de sistema de greetd, PAM
y el greeter (`etc/noctalia-greeter/greeter.toml`: teclado latam y esquema `Synced`), se
despliegan en la sección siguiente.

Greeter: el sync copia paleta, fondos y salidas de noctalia a `/var/lib/noctalia-greeter/sync.toml`
con `pkexec`. Necesita la regla de polkit de abajo y un agente en la sesión (polkit-gnome, que
arranca niri desde `startup.kdl`); sin agente el sync falla en silencio. Una sola vez, tras el
primer inicio de sesión gráfico; después `auto_sync` (`00-shell.toml`) lo repite en cada cambio:

~~~sh
sudo noctalia-greeter passwordless-sync enable ga  # regla de polkit solo para la acción de sync; sin ella pide contraseña
noctalia msg greeter-sync                          # primer sync; el greeter solo pinta imágenes: de un vídeo manda un fotograma
journalctl -b | rg apply-appearance                # comprobación: pkexec ejecutando "--sync"; si no aparece, no se aplicó
~~~

# Mantenimiento: instantáneas, firmware y batería

Como usuario con sudo. Sin esto no hay ni una instantánea aunque grub-btrfs esté instalado.

~~~sh
# "snapper" instantáneas Btrfs con limpieza automática; "snap-pac" una antes y otra después de cada pacman,
#   que es lo que salva de una actualización rota. grub-btrfsd las añade a GRUB al aparecer
# "fwupd" actualizaciones de firmware por LVFS (SSD, controladoras): fwupdmgr get-devices / update
sudo pacman -S --needed snapper snap-pac fwupd
~~~

Análisis, decisiones y vuelta atrás: `docs/snapper.md`. La config va como archivos de `etc/`
(sección Dotfiles: dos configs, `conf.d/snapper`, `snap-pac.ini`, el hook de `/boot` y el
drop-in de mkinitcpio); no se usa `snapper create-config` porque la guía ya monta `@snapshots`.
Con esos archivos instalados, en este orden:

~~~sh
sudo chmod 750 /.snapshots                                       # root y, por ACL, wheel
sudo btrfs subvolume create /home/.snapshots && sudo chmod 750 /home/.snapshots   # instantáneas de home
# Fuera de las instantáneas de home, como subvolúmenes anidados (con la sesión cerrada o sin apps abiertas):
mv ~/.cache ~/.cache.old && btrfs subvolume create ~/.cache && cp -a ~/.cache.old/. ~/.cache/ && rm -rf ~/.cache.old
mkdir -p ~/.local/share && btrfs subvolume create ~/.local/share/containers                 # antes de usar podman
sudo mkinitcpio -P                                               # initramfs con grub-btrfs-overlayfs
sudo grub-mkconfig -o /boot/grub/grub.cfg                        # entra el submenú de instantáneas
sudo systemctl enable --now grub-btrfsd snapper-timeline.timer snapper-cleanup.timer
sudo snapper -c root create -d "base" && sudo snapper -c home create -d "base"
snapper -c root list                                              # sin sudo: ALLOW_GROUPS=wheel
~~~

# Desarrollo: node con mise

Como usuario con sudo. Claude Code va con instalador nativo y no necesita node; sí lo
necesitan los servidores MCP y plugins que arrancan con `npx`. Sin `nodejs` ni `npm` de
pacman: un solo gestor de versiones, fijadas por proyecto.

~~~sh
# "mise" gestor de versiones (node, pnpm…): descargas con checksum, versión por proyecto en mise.toml, misma
#   config en cualquier distro. Las herramientas se declaran en el paquete stow mise/ y se instalan con
#   `mise install` tras el stow (sección Dotfiles). pnpm en vez de npm: no ejecuta scripts de instalación
#   de dependencias salvo lista blanca, y minimumReleaseAge (config.yaml de pnpm) evita versiones recién
#   publicadas, la vía de los gusanos de npm de 2025.
sudo pacman -S --needed mise
~~~

Ubuntu/Fedora: mise no está en apt ni dnf; instalador oficial (`curl https://mise.run | sh`)
o el COPR `jdxcode/mise` en Fedora. El resto es idéntico.

# Dotfiles

Ya como usuario, tras el primer arranque. El repo es un árbol de paquetes
[GNU Stow](https://www.gnu.org/software/stow/): cada carpeta de primer nivel
(`zsh`, `atuin`, `fastfetch`…) refleja `$HOME`, y `stow` crea los enlaces.

~~~sh
sudo pacman -S --needed stow git
git clone https://github.com/<usuario>/dotfiles.git ~/dotfiles
cd ~/dotfiles
~~~

Archivos del sistema (fuera de `$HOME`, ver `etc/README.md`):

~~~sh
sudo install -Dm644 etc/zsh/zshenv /etc/zsh/zshenv
sudo install -Dm644 etc/security/pam_env.conf /etc/security/pam_env.conf
sudo install -Dm644 etc/greetd/config.toml /etc/greetd/config.toml
sudo install -Dm644 etc/pam.d/greetd /etc/pam.d/greetd
sudo install -Dm640 -o greeter -g greeter etc/noctalia-greeter/greeter.toml /var/lib/noctalia-greeter/greeter.toml
sudo install -Dm644 etc/tmpfiles.d/charge-limit.conf /etc/tmpfiles.d/charge-limit.conf && sudo systemd-tmpfiles --create charge-limit.conf
sudo install -Dm640 etc/snapper/configs/root /etc/snapper/configs/root
sudo install -Dm640 etc/snapper/configs/home /etc/snapper/configs/home
sudo install -Dm644 etc/conf.d/snapper /etc/conf.d/snapper
sudo install -Dm644 etc/snap-pac.ini /etc/snap-pac.ini
sudo install -Dm644 etc/pacman.d/hooks/95-bootbackup.hook /etc/pacman.d/hooks/95-bootbackup.hook   # solo si /boot está fuera de Btrfs (instalación de 2026-08)
sudo install -Dm644 etc/pacman.d/hooks/91-grub-reinstall.hook /etc/pacman.d/hooks/91-grub-reinstall.hook
sudo install -Dm644 etc/mkinitcpio.conf.d/dotfiles.conf /etc/mkinitcpio.conf.d/dotfiles.conf
sudo install -Dm440 -t /etc/sudoers.d etc/sudoers.d/10-wheel etc/sudoers.d/20-defaults && sudo visudo -c
sudo install -Dm644 etc/security/faillock.conf /etc/security/faillock.conf
~~~

Paquetes de usuario. El `.stowrc` de la raíz añade `--no-folding` a todo comando `stow`
lanzado desde el repo: se enlaza archivo por archivo y los directorios se crean reales.
Así, lo que una aplicación escriba junto a su config (cachés, estado, archivos generados)
se queda en `$HOME` y no aparece dentro del repo. El precio es que cada archivo nuevo en
un paquete necesita un `stow -R`.

Si ya existe un archivo real donde stow quiere enlazar, muévelo antes o usa
`stow --adopt` para meterlo en el repo y revisarlo con `git diff`:

~~~sh
cd ~/dotfiles                   # siempre desde aquí, para que aplique .stowrc
stow zsh atuin fastfetch tealdeer ghostty niri noctalia gtk mise xdg
stow -n zsh                     # simulación: muestra qué haría sin tocar nada
stow -R zsh                     # re-enlazar tras añadir archivos a un paquete
stow -D zsh                     # quitar los enlaces de un paquete
~~~

Abre una terminal nueva: zinit clona los plugins en el primer arranque. Chuletas de teclas y
alias: `keys` (todas) o `keys niri`, `keys ghostty`, `keys noctalia`.

Noctalia: la primera vez, `noctalia msg plugins update` descarga los plugins declarados en
`30-plugins.toml`; su ventana de ajustes escribe en `~/.local/state/noctalia/settings.toml`,
que pisa a la config del repo (ver `noctalia/.config/noctalia/README.md`).

mise: la primera vez, `mise install` descarga node LTS y pnpm, declarados en
`mise/.config/mise/config.toml`. Las apps gráficas los ven al volver a entrar, por los shims
que exporta `environment.d`.
