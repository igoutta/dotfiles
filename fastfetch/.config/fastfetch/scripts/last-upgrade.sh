#!/usr/bin/env bash
# fastfetch: cuándo fue la última actualización completa (pacman -Syu o yay -Syu), leída del log
# de pacman, sin red (~3 ms). Contar las pendientes exigiría checkupdates (red) con un
# temporizador. Ubuntu: /var/log/apt/history.log; Fedora: dnf history.
l=$(tac /var/log/pacman.log | rg -m 1 -o '^\[\d{4}-\d{2}-\d{2}T[^]]*\] \[PACMAN\] starting full system upgrade')
[[ -n $l ]] || exit 0
printf -v hoy '%(%F)T' -1
dias=$(( ($(date -d "$hoy" +%s) - $(date -d "${l:1:10}" +%s)) / 86400 ))
case $dias in 0) echo "hoy" ;; 1) echo "ayer" ;; *) echo "hace $dias días" ;; esac
