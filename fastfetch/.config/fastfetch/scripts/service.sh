#!/usr/bin/env bash
# fastfetch (ssh.jsonc): estado de un servicio de systemd, como «Nombre|active». Uso:
# service.sh Nombre unidad [--user]. scripts/ssh.lua lo pinta en verde, amarillo o rojo.
# Ubuntu/Fedora: igual.
nombre=$1 unidad=$2
if [[ $3 == --user ]]; then e=$(systemctl --user is-active "$unidad" 2>/dev/null); else e=$(systemctl is-active "$unidad" 2>/dev/null); fi
echo "$nombre|${e:-unknown}"
