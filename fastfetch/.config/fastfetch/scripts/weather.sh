#!/usr/bin/env bash
# fastfetch: el tiempo de la caché de noctalia (~/.cache/noctalia/weather.json, Open-Meteo, que
# noctalia refresca cada 15 min), sin red (~3 ms, jq). Con la caché de más de 2 h (noctalia
# cerrado, sin red) no imprime nada y fastfetch oculta la línea. Códigos de tiempo WMO, con
# iconos de Nerd Font (Material Design: de día y de noche) y la puesta de sol.
f=${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/weather.json
[[ -r $f ]] || exit 0
printf -v ahora '%(%s)T' -1
jq -r --argjson ahora "$ahora" '
  # código WMO → [icono de día, icono de noche, texto]
  def wmo: {"0":["󰖙","󰖔","despejado"],"1":["󰖕","󰼱","casi despejado"],
    "2":["󰖕","󰼱","algo nublado"],"3":["󰖐","󰖐","nublado"],"45":["󰖑","󰖑","niebla"],
    "48":["󰖑","󰖑","niebla"],"51":["󰖗","󰖗","llovizna débil"],"53":["󰖗","󰖗","llovizna"],
    "55":["󰖗","󰖗","llovizna densa"],"56":["󰙿","󰙿","llovizna helada"],"57":["󰙿","󰙿","llovizna helada"],
    "61":["󰖗","󰖗","lluvia débil"],"63":["󰖗","󰖗","lluvia"],"65":["󰖖","󰖖","lluvia fuerte"],
    "66":["󰙿","󰙿","lluvia helada"],"67":["󰙿","󰙿","lluvia helada"],"71":["󰖘","󰖘","nieve débil"],
    "73":["󰖘","󰖘","nieve"],"75":["󰖘","󰖘","nieve fuerte"],"77":["󰖘","󰖘","granizo fino"],
    "80":["󰖖","󰖖","chubascos"],"81":["󰖖","󰖖","chubascos"],"82":["󰖖","󰖖","chubascos fuertes"],
    "85":["󰖘","󰖘","chubascos de nieve"],"86":["󰖘","󰖘","chubascos de nieve"],"95":["󰙾","󰙾","tormenta"],
    "96":["󰖒","󰖒","tormenta con granizo"],"99":["󰖒","󰖒","tormenta con granizo"]}[tostring] // ["󰖐","󰖐","?"];
  .snapshot | select(($ahora - .fetched_at) < 7200)
  | (.location_name // "" | split(",")[0]) as $sitio | .forecast_days[0] as $d
  | (.current.weather_code | wmo) as $w | (if .current.is_day then $w[0] else $w[1] end) as $icono
  | "\(if $sitio != "" then $sitio + " · " else "" end)\($icono) \(.current.temperature_c | round)°C \($w[2]) · \($d.temperature_min_c | round)–\($d.temperature_max_c | round)°C · 󰖛 \($d.sunset_iso[11:16])"
' "$f" 2>/dev/null
