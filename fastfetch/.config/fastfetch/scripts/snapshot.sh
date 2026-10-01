#!/usr/bin/env bash
# fastfetch: la última instantánea de snapper de la raíz, sin sudo ni snapperd (~2 ms). Lee
# /.snapshots/<n>/info.xml, que ga puede leer por la ACL de snapper (ALLOW_USERS en
# etc/snapper/configs/root). La fecha del XML va en UTC. Ubuntu/Fedora: igual, con snapper.
d=/.snapshots n=0
for x in "$d"/*/; do x=${x%/}; x=${x##*/}; [[ $x =~ ^[0-9]+$ ]] && (( x > n )) && n=$x; done
(( n )) && [[ -r $d/$n/info.xml ]] || exit 0
t='' s='' k=''
while IFS= read -r l; do
  case $l in
    *'<type>'*) k=${l#*<type>}; k=${k%</type>*} ;;
    *'<date>'*) t=${l#*<date>}; t=${t%</date>*} ;;
    *'<description>'*) s=${l#*<description>}; s=${s%</description>*} ;;
  esac
done <"$d/$n/info.xml"
printf -v ahora '%(%s)T' -1
m=$(( (ahora - $(date -ud "$t" +%s)) / 60 ))
if (( m < 60 )); then h="$m min"; elif (( m < 1440 )); then h="$(( m / 60 )) h"; else h="$(( m / 1440 )) d"; fi
echo "#$n ${s:-$k} · hace $h"
