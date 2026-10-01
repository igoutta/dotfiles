-- fastfetch: la línea de la batería, con el tope de carga marcado dentro de la barra (┃).
-- La carga y la barra las da el módulo battery (en la variable bat, ver config.jsonc); el tope,
-- el estado, la salud y el perfil, scripts/battery.sh, con el formato «80|salud 70% · equilibrado»
-- (tope, barra vertical, resto). Se carga con general.preload.lua. El Lua de fastfetch no tiene
-- io, os ni utf8: la barra se recorre a mano, separando los códigos de color de los caracteres.
function barra_bateria(r)
  local tope, texto = r.result:match('^(%d*)|(.*)$')
  texto = texto or r.result
  if not bat then return texto end
  local barra = bat.capacityBar
  if tope and tope ~= '' then
    -- trozos: códigos de color (ESC[…m) y caracteres UTF-8 visibles
    local trozos, i = {}, 1
    while i <= #barra do
      local esc = barra:match('^\27%[[%d;]*m', i)
      local trozo = esc or barra:match('^[%z\1-\127\194-\244][\128-\191]*', i)
      trozos[#trozos + 1] = { texto = trozo, color = esc ~= nil }
      i = i + #trozo
    end
    local visibles = {}
    for k, t in ipairs(trozos) do
      if not t.color then visibles[#visibles + 1] = k end
    end
    -- sin contar los corchetes; la marca va justo después de lo que llenaría el tope
    local dentro = #visibles - 2
    local pos = math.floor(tonumber(tope) / 100 * dentro + 0.5) + 2
    if pos > #visibles - 1 then pos = #visibles - 1 end
    local con_color = barra:find('\27', 1, true) ~= nil
    local salida, ultimo = {}, ''
    for k, t in ipairs(trozos) do
      if t.color then
        ultimo = t.texto
        salida[#salida + 1] = t.texto
      elseif k == visibles[pos] then
        -- en color normal y luego el color que tocaba; sin colores (--pipe), solo la raya
        salida[#salida + 1] = con_color and ('\27[39m┃' .. ultimo) or '┃'
      else
        salida[#salida + 1] = t.texto
      end
    end
    barra = table.concat(salida)
  end
  return barra .. ' ' .. bat.capacity .. ' · ' .. texto
end
