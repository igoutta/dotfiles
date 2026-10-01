-- fastfetch (ssh.jsonc): el estado de un servicio en color, a partir de «Nombre|active» de
-- scripts/service.sh: activo en verde, fallado en rojo, cualquier otro (inactive) en amarillo.
-- Colores por índice de la paleta, que siguen a noctalia. Se carga con general.preload.lua.
function estado_servicio(r)
  local nombre, estado = r.result:match('^(.-)|(.*)$')
  if not nombre then return r.result end
  local color = estado == 'active' and '32' or (estado == 'failed' and '31' or '33')
  return nombre .. ' \27[' .. color .. 'm' .. estado .. '\27[39m'
end
