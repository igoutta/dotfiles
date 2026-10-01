#!/usr/bin/env bash
# fastfetch (ssh.jsonc): el acceso SSH número N (1 = el último antes de este), de `last` (wtmp).
# Solo los que traen IP de origen: fuera las sesiones locales (tty, greeter) y las de tmux, que
# salen con 0.0.0.0. Se salta la sesión en la que se acaba de entrar. Sin ese acceso, no imprime
# nada y fastfetch oculta la línea. Ubuntu/Fedora: igual (util-linux).
quiero=${1:-1}
yo=$(tty 2>/dev/null); yo=${yo#/dev/}
n=0
# Campos de `last -i --time-format iso`: usuario, terminal, origen, inicio y, detrás, «- fin
# (duración)», «still logged in» (sesión abierta) o «gone - no logout».
while read -r _ terminal origen inicio sep fin resto; do
  [[ $origen == 0.0.0.0 || -z $origen ]] && continue
  [[ $terminal == "$yo" && $sep == still ]] && continue
  (( ++n == quiero )) || continue
  if [[ $sep == still ]]; then dur="sigue dentro"
  elif [[ $sep != - || $resto != *'('*')'* ]]; then dur="sin cierre"
  else
    dur=${resto##*(}; dur=${dur%)}; d=0
    [[ $dur == *+* ]] && { d=${dur%%+*}; dur=${dur#*+}; }
    h=$((10#${dur%%:*})) m=$((10#${dur##*:}))
    if (( d )); then dur="$d d $h h"; elif (( h )); then dur="$h h $m min"; else dur="$m min"; fi
  fi
  # IPv6 larga: los dos primeros grupos y el último (2800:440:…:640b), para que quepa a media pantalla.
  if [[ $origen == *:*:*:* ]]; then IFS=: read -ra g <<<"$origen"; origen="${g[0]}:${g[1]}:…:${g[-1]}"; fi
  echo "${inicio:0:10} ${inicio:11:5} · $origen · $dur"
  exit 0
done < <(last -i -w --time-format iso "${USER:-$(id -un)}" 2>/dev/null)
