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
loadkeys la-latin1 / es / us
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

~~~sh
sgdisk --clear \
       --new=1:0:+2GiB --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:+16GiB --typecode=2:8200 --change-name=2:cryptswap \
       --new=3:0:0 --typecode=3:8300 --change-name=3:cryptsystem *DRIVE*
~~~

### Configurar el cifrado de la partición principal

~~~sh
cryptsetup luksFormat \
           --type luks2 \
           --cipher aes-xts-plain64 \
           --key-size 512 \
           --hash sha512 \
           --iter-time 2000 \
           --pbkdf argon2id \
           --use-urandom \
           --verify-passphrase \
           /dev/disk/by-partlabel/cryptsystem
~~~

~~~sh
cryptsetup open /dev/disk/by-partlabel/cryptsystem system
~~~

### Configurar el cifrado de la partición de intercambio

~~~sh
cryptsetup open --type plain --cipher aes-xts-plain64 --key-size 512 --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap
~~~

~~~sh
mkswap -L swap /dev/mapper/swap
swapon -L swap
~~~

### Formatear y montar el sistema de archivos con subvolumenes usando BTRFS

~~~sh
mkfs.btrfs --label system --nodesize 32k /dev/mapper/system
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
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,nodatacow,subvol=@containers LABEL=system /mnt/var/lib/containers
mount -m -t btrfs -o defaults,noatime,autodefrag,ssd,nodatacow,subvol=@libvirt LABEL=system /mnt/var/lib/libvirt
~~~

In case you need to change some option, you should use this 

~~~sh
mount -o remount,x-mount.mkdir,
~~~

### Formatear y montar la partición de arranque

~~~sh
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mount --mkdir LABEL=EFI /mnt/boot
~~~

# Instalación del sistema 

## Actualización de los repositorios espejo óptimos para descarga

~~~sh
reflector --verbose --sort score --save /etc/pacman.d/mirrorlist --ipv4 --threads 4 -p http,https -c 'ec,de,us,co,pe,cl,*' -l 250 -f 50 -a 6
mkdir -p /mnt/etc/pacman.d
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
cat !$
~~~

## Últimos detalles

~~~sh
echo KEYMAP=la-latin1 > /etc/vconsole.conf
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
# "inotify-tools" used by grub btrfsd deamon to automatically spot new snapshots and update grub entries
# "grub" the bootloader
# "grub-btrfs" adds btrfs support for the grub bootloader and enables the user to directly boot from snapshots

# "timeshift" a GUI app to easily create,plan and restore snapshots using BTRFS capabilities

# "networkmanager" to manage Internet connections both wired and wireless ( it also has an applet package network-manager-applet )
# "openssh" to use ssh and manage keys
# "pipewire pipewire-alsa pipewire-pulse pipewire-jack" for the new audio framework replacing pulse and jack. 
# "wireplumber" the pipewire session manager.

# "zsh" my favourite shell
# "zsh-completions" for zsh additional completions
# "zsh-autosuggestions" very useful, it helps writing commands [ Needs configuration in .zshrc ]

# terminus-font for ter-132 family font for the hooks

# "neovim" my goto editor, if unfamiliar use nano

# "man" for manual pages
# "navi" is an interactive cheatsheet tool for the command-line
# "git" to install the git vcs
pacstrap -iK /mnt base base-devel \
                  linux linux-headers linux-firmware intel-ucode mkinitcpio \ #dracut sof-firmware
                  efibootmgr btrfs-progs inotify-tools fuse3 ntfs-3g ntfsprogs dosfstools cryptsetup \
                  grub grub-btrfs os-prober \
                  util-linux dhcpcd networkmanager iwd firewalld bluez bluez-utils cups \ #dnsmasq libnvme modemmanager openresolv pacrunner ppp
                  avahi acpi acpi_call acpid \
                  alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
                  zsh zsh-doc zsh-autosuggestions zsh-completions zsh-syntax-highlighting \ #
                  terminus-font ttf-dejavu atuin \
                  micro helix neovim \
                  bat fzf fzf-tab eza rsync ripgrep jq \
                  mandoc man-pages navi \
                  openssh git pkgstats
~~~

## Generar y editar correctamente la tabla del sistema de archivos (fstab)

~~~sh
genfstab -L -p /mnt >> /mnt/etc/fstab
cat !$
~~~

### Configurar el cifrado del espacio de intercambio (swap)

Open the file '/mnt/etc/fstab' and replace 'LABEL=swap' with '/dev/mapper/swap'.

~~~sh
sed -i -e 's/^LABEL=swap/\/dev\/mapper\/swap/' /mnt/etc/fstab
cat !$
~~~

Con ese cambio, el kernel esperará que un contenedor cifrado abierto llamado swap, así que agregue lo siguiente al archivo '/mnt/etc/crypttab' para que se abra en el arranque.

~~~sh
echo "\nswap\t\t   /dev/disk/by-partlabel/cryptswap\t\t\t /dev/urandom\t\t\t swap,offset=2048,cipher=aes-xts-plain64,size=512\n" >> /mnt/etc/crypttab
cat !$
~~~

Tenga en cuenta que esto generará una clave aleatoria en cada arranque, por lo que el intercambio (swap) no será persistente. Esto tiene implicaciones en la hibernación, tengalo en cuenta.

~~~sh
echo tuf > /mnt/etc/hostname
cat !$
~~~

~~~sh
echo "127.0.1.1\t tuf\n" >> /mnt/etc/hosts
cat !$
~~~

~~~sh
echo "LANG=es_EC.UTF-8\nLC_MESSAGES=en_US.UTF-8\n" > /mnt/etc/locale.conf
cat !$
~~~

~~~sh
sed -i -e "/^#"es_EC.UTF-8"/s/^#//" /mnt/etc/locale.gen
cat !$
~~~

~~~sh
ln -sf /usr/share/zoneinfo/America/Guayaquil /mnt/etc/localtime
cat !$
~~~

~~~sh
arch-chroot -S /mnt
~~~

~~~sh
hwclock -w
~~~

~~~sh
locale-gen
localectl set-x11-keymap latam
~~~

~~~sh
export LANG=es_EC.UTF-8
export EDITOR=helix
~~~

### Anadir repositorios extra a pacman

~~~sh
pacman-key --recv-keys 7931B6D628C8D3BA
pacman-key --finger 7931B6D628C8D3BA
pacman-key --lsign-key 7931B6D628C8D3BA
helix /etc/pacman.conf
~~~

~~~sh
ILoveCandy

[arch4edu]
Include = /etc/pacman.d/mirrorlist.arch4edu
~~~

~~~sh
curl -s https://api.arch4edu.org/status/mirrors.json | jq -r --argjson cutoff "$(date -d '30 days ago' +%s 2>/dev/null)" '
  .mirrors[] 
  | select(.status != "error")
  | select(.timestamp != null)
  | select(.timestamp > $cutoff)
  | "Server = " + .url + "$arch"
' > /etc/pacman.d/mirrorlist.arch4edu
cat !$
~~~

~~~sh
pacman -Sy
~~~

pacman -S xdg-utils xdg-user-dirs dialog

Modify /etc/mkinitcpio.conf to have btrfs in MODULES, /usr/bin/btrfs in BINARIES, and encrypt in HOOKS. Add encrypt hook after block and before filesystems.

If hibernation is to be used, resume needs to be added (somewhere after udev). If it is from a swap file inside an encrypted container (as in this case), then resume should be placed after the encrypt and filesystem hooks.

~~~sh
helix /etc/mkinitcpio.conf
~~~

BTRFS support, Intel Graphics

TPM2, UKI,

~~~sh
MODULES=(btrfs tpm_crb i915)
BINARIES=(/usr/bin/btrfs)
HOOKS=(base udev resume btrfs autodetect microcode modconf kms keyboard keymap consolefont numlock block encrypt filesystems fsck)
COMPRESSION="zstd"
COMPRESSION_OPTIONS=(-v -5 --long)
~~~

~~~sh
mkinitcpio -P
~~~

Note: ==> WARNING: Possibly missing firmware for module: 'qat_6xxx'


~~~sh
refind-install --usedefault /dev/part_UEFI --alldrivers
mkrlconf
micro/boot/refind linux.conf # erase firsts two lines
blkid -s PARTUUID -o value /dev/part_UEFI >> /boot/EFI/BOOT/refind.conf
blkid -s PARTUUID -o value /dev/part_ROOT
micro /boot/EFI/BOOT/refind.conf
options "rw root=PARTUUID=PARTUUID(/dev/part_ROOT) initrd=\intel-ucode.img"
~~~

~~~sh
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
~~~

# Opening default grub config file with nvim
nvim /etc/default/grub

Uncomment the line GRUB_ENABLE_CRYPTODISK=y:

# Uncomment to enable booting from LUKS encrypted disks
GRUB_ENABLE_CRYPTODISK=y

Search other operational systems

If you want that grub search for other operational systems, you can also uncomment the line GRUB_DISABLE_OS_PROBER=false:

GRUB_DISABLE_OS_PROBER=false

Remember last selected entry

If you want that grub remember the last selected entry, you can also uncomment the line GRUB_SAVEDEFAULT=true and change the line GRUB_DEFAULT=0 to GRUB_DEFAULT=saved:

...
GRUB_DEFAULT=saved
...
GRUB_SAVEDEFAULT=true
...

~~~sh
blkid /dev/nvme1n1p3 -o export
~~~

~~~sh
grub-mkconfig -o /boot/grub/grub.cfg
~~~

mkinitcpio-numlock with yay

useradd -m -U -G wheel,users,uucp,storage,power --shell /usr/bin/zsh ga

passwd ga

EDITOR=micro visudo # %wheel
 
su ga -c "xdg-user-dirs-update"
LC_ALL=C.UTF-8 xdg-user-dirs-update --force

pacman -S man-db man-pages tealdeer lsb-release fastfetch btop
 
pacman -S gnu-free-fonts powerline-fonts nerd-fonts noto-fonts-emoji woff2-font-awesome
 ttf-hack ttf-inconsolata ttf-liberation ttf-ubuntu-font-family ttf-bitstream-vera ttf-dejavu adobe-source-sans-pro-fonts ttf-anonymous-pro noto-fonts noto-fonts-cjk 

systemctl enable NetworkManager

systemctl enable sshd
 
exit

 
umount -R /mnt
 
reboot

nmcli device wifi connect 'ssid' password 'password'

sudo pacman -S ffmpeg pipewire pipewire-audio pipewire-pulse pipewire-jack wireplumber
sudo pacman -S hunspell-en_US aspell-en gst-plugins-good icedtea-web gufw dnscrypt-proxy p7zip tar rsync libreoffice-still vlc keepassxc kdeconnect --needed
 
tldr --update

sudo localectl set-x11-keymap latam,us

sudo mkswap /dev/part_SWAP
sudo swapon /dev/part_SWAP
echo "UUID=device_UUID none swap defaults 0 0" > /etc/fstab
