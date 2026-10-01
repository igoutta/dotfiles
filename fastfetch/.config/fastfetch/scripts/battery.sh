#!/usr/bin/env bash
# fastfetch: tope de carga, estado de la batería, salud y perfil de energía, como «80|salud 70% ·
# equilibrado». La carga y su barra las pone el módulo battery, y scripts/battery.lua marca el
# tope dentro de la barra y junta el resto. Solo lee /sys, sin
# procesos (~1 ms). La salud es la capacidad actual frente a la de fábrica (cycle_count de este
# ASUS siempre dice 0). «Not charging» con la carga en el tope = retenida por el límite (etc/
# tmpfiles.d/charge-limit.conf). Ubuntu/Fedora: igual; otra marca, mirar /sys/class/power_supply.
b=/sys/class/power_supply/BAT1
[[ -r $b/capacity ]] || exit 0
read -r c <"$b/capacity"; read -r s <"$b/status"
read -r f <"$b/charge_full"; read -r d <"$b/charge_full_design"
l=; [[ -r $b/charge_control_end_threshold ]] && read -r l <"$b/charge_control_end_threshold"
p=; [[ -r /sys/firmware/acpi/platform_profile ]] && read -r p </sys/firmware/acpi/platform_profile
case $s in
  Charging) s=cargando ;;
  Discharging) s=descargando ;;
  Full) s=llena ;;
  # Retenida en el tope: no hace falta decirlo, la barra lo muestra.
  "Not charging") [[ -n $l ]] && (( c >= l - 1 )) && s= || s="sin cargar" ;;
  *) s=${s,,} ;;
esac
case $p in quiet|low-power) p=ahorro ;; balanced) p=equilibrado ;; performance) p=rendimiento ;; esac
echo "$l|${s:+$s · }salud $(( f * 100 / d ))%${p:+ · $p}"
