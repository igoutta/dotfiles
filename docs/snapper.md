# Instantáneas Btrfs con snapper

Análisis y plan para esta máquina, hecho el 2026-09-24 contrastando la guía
[sysguides-snapper-fedora](https://github.com/SysGuides/sysguides-snapper-fedora) con la
instalación real. Los archivos viven en `etc/` y los pasos, con sudo, en la fase
«Mantenimiento» de `INSTALL.md`.

## Punto de partida

| Dato | Valor |
| --- | --- |
| Disco | `nvme1n1p3`, LUKS2 → `/dev/mapper/system`, Btrfs de 914 G con 44 G usados |
| Raíz | subvolumen `@` en `/`, montado por ruta (`subvol=/@`), no por id |
| Aparte de la raíz | `@home`, `@snapshots` (en `/.snapshots`), `@log`, `@cache`, `@tmp`, `@opt`, `@srv`, `@spool`, `@containers`, `@libvirt` |
| `/boot` | partición vfat de 2 G, **fuera de Btrfs**: kernel, initramfs, microcode y GRUB |
| Swap | partición LUKS con clave aleatoria, sin `resume=` |
| GRUB | `grub-btrfs` instalado desde agosto, `grub-btrfsd` apagado, ninguna instantánea |
| `~/.cache` | 13 G, dentro de `@home` |

Que casi todo lo mutable esté en subvolúmenes propios es la mejor parte: una instantánea de
`@` no arrastra logs, cachés, contenedores ni `/home`, y una vuelta atrás de la raíz no toca
los datos del usuario.

## Qué hace SysGuides en Fedora y qué equivale aquí

| SysGuides (Fedora) | Aquí (Arch) |
| --- | --- |
| Configs `root` y `home` con `create-config` | Las mismas dos, pero como archivos de `etc/`: `create-config` quiere crear él `.snapshots` y `@snapshots` ya está montado |
| `ALLOW_USERS=$USER SYNC_ACL=yes` | `ALLOW_GROUPS="wheel"` y `SYNC_ACL="yes"`: `snapper list` sin sudo |
| Plugin `libdnf5-plugin-actions` con scripts pre/post y descripción del comando | `snap-pac`: hooks de pacman, descripción = comando y paquetes, `important_packages` |
| `snapper-wal-checkpoint.sh` (vacía el WAL de la base rpm antes de la instantánea) | No aplica: la base de pacman son archivos, no SQLite |
| `grub-btrfs` con `rd.live.overlay.overlayfs=1` (dracut) para arrancar instantáneas de solo lectura | `grub-btrfs` con el hook `grub-btrfs-overlayfs` de mkinitcpio |
| `restorecon` de `/.snapshots` (SELinux) | No aplica |
| `PRUNENAMES=.snapshots` en `updatedb.conf` | plocate no está instalado; si vuelve, misma línea |
| `btrfs-assistant` (GUI Qt) | Opcional; aquí todo por `snapper` en terminal |
| Vuelta atrás con `snapper undochange` y Btrfs Assistant | `undochange` sirve para archivos sueltos; para la raíz entera, ver «Vuelta atrás» |
| Timeline en `root` sí, en `home` no | Al revés (abajo el porqué) |

## Decisiones

**Raíz (`root`).** Lo que salva de una actualización rota son las instantáneas de pacman:
una antes y otra después de cada transacción (`snap-pac`), máximo 20, y 5 más de las
marcadas importantes (kernel, systemd, grub, mkinitcpio, cryptsetup, mesa, NVIDIA). Además
una diaria durante 7 días (`TIMELINE` con solo `DAILY=7`), por los cambios a mano en `/etc`
que no pasan por pacman. Comparación en segundo plano activada: `/` es pequeña.

**Home (`home`).** Aquí no hay pacman; lo que importa es el borrado accidental. Timeline:
12 horas, 7 días, 4 semanas. SysGuides desactiva la timeline de home; con 870 G libres y
copia en escritura, el coste es el de lo que cambia, no el del tamaño de `/home`. Sin
comparación en segundo plano: es un árbol grande.

**Lo que se saca de `/home` con subvolúmenes anidados**, porque una instantánea nunca
incluye los subvolúmenes de dentro: `~/.cache` (13 G que se regeneran solos) y
`~/.local/share/containers` (imágenes de podman rootless, grandes y cambiantes). Podman
además usa el driver btrfs cuando el almacén es un subvolumen.

**Cuotas Btrfs: no.** `SPACE_LIMIT` solo actúa con qgroups activos, y las cuotas tienen coste
de rendimiento y un historial de problemas. Bastan los límites por número, por tiempo y
`FREE_LIMIT=0.2` (con menos del 20 % libre, snapper limpia).

**`/boot` fuera de Btrfs es el punto débil.** Una instantánea de `@` guarda los módulos del
kernel de ese momento, pero no el kernel ni el initramfs, que viven en la vfat. Volver a una
instantánea anterior a una actualización del kernel deja `/boot` nuevo con módulos viejos: no
arranca bien. SysGuides lo resuelve poniendo `/boot` en Btrfs; cambiar eso aquí es rehacer el
arranque. La solución barata y estándar en Arch: un hook de pacman que copia `/boot` a
`/.bootbackup` **después** de cada transacción que toque un kernel. Así la instantánea
«post» lleva el `/boot` que casa con sus módulos, y la «pre» siguiente también. Al volver
atrás se restaura `/boot` desde esa copia.

**Arrancar una instantánea desde GRUB** exige el hook `grub-btrfs-overlayfs` en el initramfs:
la instantánea es de solo lectura y el hook le pone una capa escribible en RAM. Va como
drop-in en `mkinitcpio.conf.d/`, sin tocar el archivo de Arch, y solo añade ese hook: `resume`
(hoy inútil sin `resume=`, y mal colocado antes de `encrypt`) y `btrfs` (solo para Btrfs en
varios discos) se deciden con la hibernación, que sigue pendiente en TODO.md.

**GRUB.** `GRUB_DEFAULT=saved` con `GRUB_SAVEDEFAULT=true` guarda la última entrada elegida.
Las entradas de instantáneas de grub-btrfs no usan `savedefault`, así que arrancar una no la
convierte en predeterminada. Comprobar la primera vez.

## Vuelta atrás de la raíz

`snapper rollback` está pensado para la disposición de openSUSE (la raíz es una instantánea y
se cambia el subvolumen por defecto). Con `@` montado por ruta, el camino es renombrar:

1. Desde GRUB, arrancar la instantánea buena (submenú de instantáneas). Con el hook de
   overlayfs es un sistema vivo de solo lectura: comprobar que es la que se quiere.
2. Desde ahí, o desde el sistema normal si arranca:

   ~~~sh
   sudo mount -o subvolid=5 /dev/mapper/system /mnt        # el nivel superior del Btrfs
   sudo mv /mnt/@ /mnt/@.rota
   sudo btrfs subvolume snapshot /mnt/@snapshots/<N>/snapshot /mnt/@   # copia escribible
   sudo rsync -a --delete /mnt/@/.bootbackup/boot/ /boot/  # el kernel que casa con esos módulos
   sudo umount /mnt && reboot
   ~~~

3. Cuando todo vaya bien, `sudo btrfs subvolume delete /mnt/@.rota` (montando igual).

`snapper-rollback` (AUR) automatiza el paso 2 para esta disposición; conviene probarlo cuando
haya una instantánea con la que ensayar. Para un archivo suelto: `snapper -c home status
<a>..<b>` y `snapper -c home undochange <a>..<b> <ruta>`.

## Archivos del repo

| Archivo | Destino | Qué es |
| --- | --- | --- |
| `etc/snapper/configs/root` | `/etc/snapper/configs/root` | Config de la raíz |
| `etc/snapper/configs/home` | `/etc/snapper/configs/home` | Config de `/home` |
| `etc/conf.d/snapper` | `/etc/conf.d/snapper` | `SNAPPER_CONFIGS="root home"` |
| `etc/snap-pac.ini` | `/etc/snap-pac.ini` | Paquetes que marcan una instantánea como importante |
| `etc/pacman.d/hooks/95-bootbackup.hook` | `/etc/pacman.d/hooks/95-bootbackup.hook` | Copia de `/boot` tras cada kernel |
| `etc/mkinitcpio.conf.d/dotfiles.conf` | `/etc/mkinitcpio.conf.d/dotfiles.conf` | `HOOKS` de la guía más `grub-btrfs-overlayfs` |

## Comprobaciones al terminar

~~~sh
snapper list-configs                       # root y home
snapper -c root list                       # la instantánea «base» y, tras un pacman, un par pre/post
sudo pacman -Syu                           # snap-pac debe crear pre y post sin avisos
ls /boot/grub/grub-btrfs.cfg               # grub-btrfsd lo genera al aparecer instantáneas
sudo btrfs subvolume list / | rg -c snapshot
~~~
