#!/usr/bin/env bash
# fastfetch (ssh.jsonc): el logo «usuario @ equipo». figlet dibuja las letras, lolcat pone el
# arcoíris de fondo (-i, empieza en otro color en cada entrada) y gum el borde grueso, de un
# color de la paleta elegido al azar cada vez. El dibujo se rellena a un rectángulo exacto, con
# una fila de margen arriba y abajo y una columna a cada lado, para que el arcoíris llene el
# borde parejo. Uso: ssh-logo.sh
# [fuente]; busca la fuente en fonts/ de este paquete y luego en las de figlet. Ubuntu/Fedora:
# igual (figlet, lolcat y gum).
fuente=${1:-slant}
dir=${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/fonts
[[ -f $dir/$fuente.flf ]] || dir=/usr/share/figlet/fonts
# Sin las filas vacías que figlet deja arriba y abajo (las de dentro se quedan).
dibujo=$(figlet -d "$dir" -f "$fuente" -w 300 "$(id -un) @ $(hostnamectl hostname)" |
  awk '{ l[NR] = $0 } NF && !i { i = NR } NF { f = NR } END { for (n = i; n <= f; n++) print l[n] }')
ancho=$(( $(printf '%s\n' "$dibujo" | wc -L) + 2 ))   # una columna de margen a cada lado
# Índices de la paleta de la terminal (siguen a noctalia): rojos, amarillos, verdes, azules, magentas, cianes.
borde=$(shuf -n 1 -e 1 2 3 4 5 6 9 10 11 12 13 14)
{
  printf '%*s\n' "$ancho" ''
  printf '%s\n' "$dibujo" | awk -v w="$ancho" '{ printf "%-" w "s\n", " " $0 }'
  printf '%*s\n' "$ancho" ''
} | lolcat -f -i | CLICOLOR_FORCE=1 gum style --no-strip-ansi --border thick --border-foreground "$borde"
