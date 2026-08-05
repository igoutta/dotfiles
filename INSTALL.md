https://gist.github.com/WELL1NGTON/47ab9f38ace6368636bebd75c1e17f8c#set-the-keyboard-layout
https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae#packages-installation
https://wiki.archlinux.org/title/User:ZachHilman/Installation_-_Btrfs_%2B_LUKS2_%2B_Secure_Boot
https://dev.to/thes1lv3r/installing-arch-linux-on-btrfs-with-luks-and-automatic-tpm2-unlocking-3oio

~~~sh
loadkeys la-latin1 / es / us
setfont ter-132b
~~~

~~~sh
ping -c 3 archlinux.org
iwctl station wlan0 connect 'NombreDeRed' --passphrase 'contraseña' 
~~~

timedatectl set-ntp true

(optional ssh) 
systemctl status sshd
systemctl start sshd
passwd  (for installer root)

cat /sys/firmware/efi/fw_platform_size

lsblk -fpo NAME,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS
(optional deleting SSD) blkdiscard -f *DRIVE*

~~~sh
sgdisk --clear \
       --new=1:0:+1GiB --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:+16GiB --typecode=2:8200 --change-name=2:cryptswap \
       --new=3:0:0 --typecode=3:8300 --change-name=3:cryptsystem *DRIVE*
~~~

~~~sh
cryptsetup luksFormat \
  --type luks2 \
  --cipher aes-xts-plain64 \
  --hash sha512 \
  --iter-time 2000 \
  --key-size 512 \
  --pbkdf argon2id \
  --use-urandom \
  --verify-passphrase \
  /dev/disk/by-partlabel/cryptsystem
~~~
cryptsetup open /dev/disk/by-partlabel/cryptsystem system

(optional cryptoswap)
cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap (Kinda DEPRECATED)
cryptsetup open --type plain --use-urandom /dev/disk/by-partlabel/cryptswap swap
mkswap -L swap /dev/mapper/swap
swapon -L swap
 
mkfs.btrfs --label system -n 16k /dev/mapper/system
mount -t btrfs LABEL=system /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@spool
btrfs subvolume create /mnt/@containers
btrfs subvolume create /mnt/@libvirt


umount -R /mnt

mount -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@root LABEL=system /mnt
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@home LABEL=system /mnt/home
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@snapshots LABEL=system /mnt/.snapshots
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@opt LABEL=system /mnt/opt
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@log LABEL=system /mnt/var/log
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@cache LABEL=system /mnt/var/cache
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@tmp LABEL=system /mnt/var/tmp
mount --mkdir -o defaults,noatime,autodefrag,ssd,compress=lzo,subvol=@spool LABEL=system /mnt/var/spool
mount --mkdir -o defaults,noatime,autodefrag,ssd,nodatacow,subvol=@containers LABEL=system /mnt/var/lib/containers
mount --mkdir -o defaults,noatime,autodefrag,ssd,nodatacow,subvol=@libvirt LABEL=system /mnt/var/lib/libvirt

mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mount --mkdir LABEL=EFI /mnt/efi

reflector --verbose -c 'ec,de,us,co,pe,cl,*' -p https,http --save /mnt/etc/pacman.d/mirrorlist --latest 250 --sort score --ipv4 --threads 4 --fastest 50 --age 6
reflector --save /mnt/etc/pacman.d/mirrorlist --protocol http,https \
          --country Norway,Sweden,France,Germany,Finland,Iceland,US \
          --latest 250 --sort score --ipv4 --threads 4 --fastest 50 --age 6
          

pacstrap -iK /mnt base base-devel \
micro helix \
efibootmgr grub grub-btrfs btrfs-progs inotify-tools os-prober fuse3 ntfs-3g ntfsprogs \
zsh zsh-autosuggestions zsh-completions zsh-doc zsh-syntax-highlighting \
linux linux-headers linux-firmware intel-ucode mkinitcpio \
networkmanager

genfstab -L -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

arch-chroot /mnt


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
