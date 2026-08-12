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

## Conexión SSH

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

# Instalación base

## Particionado del Disco
~~~sh
lsblk -fpo NAME,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS
~~~

optional deleting SSD
~~~sh
blkdiscard -f *DRIVE*
~~~


~~~sh
sgdisk --clear \
       --new=1:0:+2GiB --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:+16GiB --typecode=2:8200 --change-name=2:cryptswap \
       --new=3:0:0 --typecode=3:8300 --change-name=3:cryptsystem *DRIVE*
~~~

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

~~~sh
cryptsetup open --type plain --cipher aes-xts-plain64 --key-size 512 --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap
~~~

~~~sh
mkswap -L swap /dev/mapper/swap
swapon -L swap
~~~

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

~~~sh
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mount --mkdir LABEL=EFI /mnt/boot
~~~

~~~sh
mkdir -p /mnt/etc
genfstab -L -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
~~~

Open the file '/mnt/etc/fstab' and replace 'LABEL=swap' with '/dev/mapper/swap'.

~~~sh
sed -i -e 's/^LABEL=swap/\/dev\/mapper\/swap/' /mnt/etc/fstab
~~~

~~~sh
reflector --verbose --sort score --save /etc/pacman.d/mirrorlist --ipv4 --threads 4 -p http,https -c 'ec,de,us,co,pe,cl,*' -l 250 -f 50 -a 6
mkdir -p /mnt/etc/pacman.d
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
~~~

~~~sh
pacstrap -iK /mnt base base-devel \
                  micro helix \
                  efibootmgr btrfs-progs inotify-tools fuse3 ntfs-3g ntfsprogs \
                  grub grub-btrfs os-prober \
                  zsh zsh-autosuggestions zsh-completions zsh-doc zsh-syntax-highlighting \
                  linux linux-headers linux-firmware intel-ucode mkinitcpio \
                  networkmanager openssh git
~~~

~~~sh
nvim /mnt/etc/crypttab
swap /dev/disk/by-partlabel/cryptswap /dev/urandom swap,offset=2048,cipher=aes-xts-plain64,size=512
~~~

arch-chroot -S /mnt


ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime
hwclock -w

sed -i -e "/^#"es_EC.UTF-8"/s/^#//" /etc/locale.gen
locale-gen
echo LANG=es_EC.UTF-8 > /etc/locale.conf
echo LC_MESSAGES=en_US.UTF-8 >> /etc/locale.conf

export LANG=es_EC.UTF-8
export EDITOR=micro
echo KEYMAP=la-latin1 > /etc/vconsole.conf
localectl set-x11-keymap latam

echo tuf > /etc/hostname
echo "127.0.1.1 tuf" >> /etc/hosts

/etc/pacman.conf
ILoveCandy

pacman -Sy
 
pacman -S git xdg-utils xdg-user-dirs dialog
pacman -S bat fzf eza ripgrep helix

/etc/mkinitcpio.conf

HOOKS=(base udev autodetect microcode modconf kms keyboard keymap sd-vconsole block encrypt btrfs filesystems fsck)
COMPRESSION="zstd"
COMPRESSION_OPTIONS=(-9)
mkinitcpio -P


refind-install --usedefault /dev/part_UEFI --alldrivers
 mkrlconf
 micro/boot/refind linux.conf (erase firsts two lines)
 blkid -s PARTUUID -o value /dev/part_UEFI >> /boot/EFI/BOOT/refind.conf
 blkid -s PARTUUID -o value /dev/part_ROOT
 micro /boot/EFI/BOOT/refind.conf
 options "rw root=PARTUUID=PARTUUID(/dev/part_ROOT) initrd=\intel-ucode.img"

pacman -S grub efibootmgr os-prober fuse3 ntfs-3g 
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg



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
