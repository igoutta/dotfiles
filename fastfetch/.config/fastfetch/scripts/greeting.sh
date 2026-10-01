#!/usr/bin/env bash
# fastfetch: saludo según la hora y la fecha, con los nombres del idioma del sistema (es_EC), sin
# procesos: printf de bash usa strftime con LC_TIME. fastfetch lanza sus comandos con LANG=C.UTF-8
# (para que su salida no cambie con el idioma), así que el idioma se lee de locale.conf; asignar
# LC_ALL dentro de bash vuelve a cargar el idioma. Ubuntu: /etc/default/locale; Fedora: igual.
for f in "${XDG_CONFIG_HOME:-$HOME/.config}/locale.conf" /etc/locale.conf; do
  [[ -r $f ]] && { . "$f"; break; }
done
LC_ALL=${LC_TIME:-${LANG:-C.UTF-8}}
printf -v h '%(%H)T' -1
h=$((10#$h))
if (( h < 12 )); then s="Buenos días"; elif (( h < 19 )); then s="Buenas tardes"; else s="Buenas noches"; fi
printf '%s · %(%A %-d de %B, %H:%M)T\n' "$s" -1
