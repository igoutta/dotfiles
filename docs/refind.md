# Alternativa: arrancar con rEFInd

Notas de una instalación anterior con rEFInd en lugar de GRUB. **No se usan en la
instalación actual** (ver `INSTALL.md`, sección GRUB); se conservan para poder cambiar
de gestor de arranque otro día. Sustituir `/dev/part_UEFI` y `/dev/part_ROOT` por las
particiones reales (`/dev/disk/by-partlabel/EFI` y el dispositivo raíz).

~~~sh
pacman -S refind
refind-install --usedefault /dev/part_UEFI --alldrivers
mkrlconf                                    # genera /boot/refind_linux.conf con las opciones actuales
helix /boot/refind_linux.conf               # borrar las dos primeras líneas (entradas de arranque de la ISO)
blkid -s PARTUUID -o value /dev/part_UEFI >> /boot/EFI/BOOT/refind.conf
blkid -s PARTUUID -o value /dev/part_ROOT   # anotar para la línea `options`
helix /boot/EFI/BOOT/refind.conf
~~~

Línea `options` de la entrada de Linux en `refind.conf`, con el PARTUUID de la raíz:

~~~text
options "rw root=PARTUUID=<PARTUUID de part_ROOT> initrd=\intel-ucode.img"
~~~

Con raíz cifrada (LUKS) y btrfs hay que añadir lo mismo que lleva GRUB en
`GRUB_CMDLINE_LINUX_DEFAULT`: `cryptdevice=UUID=<uuid>:system:allow-discards
root=/dev/mapper/system rootflags=subvol=@`. rEFInd no lo añade solo, a diferencia de
`grub-mkconfig`.
