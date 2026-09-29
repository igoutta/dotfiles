--!nonstrict
-- Panel de OneDrive (clic en la nube de la barra). Solo muestra y manda órdenes al servicio del
-- plugin, que es quien llama a onedrive-ctl. Textos por noctalia.tr (translations/en.json y es.json),
-- así sigue el idioma de noctalia.
-- Cambiar qué carpetas se bajan va en dos pasos: «Test changes» hace una prueba sin tocar nada y
-- enseña el resumen; solo entonces aparece «Apply», que rehace el índice. «Apply» usa exactamente
-- la selección probada: si se cambia algo después de la prueba, hay que volver a probar.

local SERVICIO = "ga/onedrive:service"
local tr = function(k, a) return noctalia.tr(k, a) end

local sel = nil          -- selección en el panel: nombre → true (se baja) / false (solo nube)
local probada = nil      -- selección de la última prueba, como texto EXCL
local abierto = false

local function orden(evento, dato)
    local args = { "noctalia", "msg", "plugin", SERVICIO, "all", evento }
    if dato ~= nil then table.insert(args, dato) end
    noctalia.runAsync(args)
end

local function tamano(b)
    local u = { "B", "KB", "MB", "GB", "TB" }
    local i = 1
    b = tonumber(b) or 0
    while b >= 1024 and i < #u do b = b / 1024; i = i + 1 end
    return (i == 1) and string.format("%d %s", b, u[i]) or string.format("%.1f %s", b, u[i])
end

local function carpetas() return noctalia.state.get("od_folders") or {} end

-- Nombres desmarcados, separados por «/» (así los recibe onedrive-ctl).
local function exclusiones()
    local ex = {}
    for _, c in ipairs(carpetas()) do
        if sel and sel[c.name] == false then table.insert(ex, c.name) end
    end
    table.sort(ex)
    return table.concat(ex, "/")
end

local function exclusionesActuales()
    local ex = {}
    for _, c in ipairs(carpetas()) do
        if not c.included then table.insert(ex, c.name) end
    end
    table.sort(ex)
    return table.concat(ex, "/")
end

local function copiarSeleccion()
    sel = {}
    for _, c in ipairs(carpetas()) do sel[c.name] = c.included end
end

local GLYPH = {
    synced = "cloud-check", syncing = "cloud-up", running = "cloud", paused = "cloud-pause",
    offline = "cloud-off", error = "cloud-exclamation", failed = "cloud-x", noauth = "cloud-question",
    noinstall = "cloud-off", unknown = "cloud",
}

local function seccion(titulo)
    return ui.label({ text = titulo, fontSize = 13, fontWeight = "bold", color = "on_surface_variant" })
end

local function cabecera(st, resumen)
    local kind = st.kind or "unknown"
    local filas = {
        ui.row({ gap = 10, align = "center" }, {
            ui.glyph({ name = GLYPH[kind] or "cloud", size = 22, color = "primary" }),
            ui.label({ text = "OneDrive", fontSize = 16, fontWeight = "bold", flexGrow = 1 }),
            ui.button({ glyph = "x", variant = "ghost", controlSize = "sm", onClick = function() panel.close() end }),
        }),
        ui.label({ text = tr("status_" .. kind, { time = st.time or "" }), fontSize = 13 }),
    }
    if resumen and resumen.size then
        table.insert(filas, ui.label({ text = tr("summary", { size = resumen.size, files = resumen.files or "?" }), fontSize = 12, color = "on_surface_variant" }))
    end
    local botones = {}
    if kind == "noauth" then
        table.insert(botones, ui.button({ text = tr("btn_sign_in"), glyph = "login", variant = "primary", onClick = function() orden("login") end }))
    elseif kind ~= "noinstall" then
        local pausado = (kind == "paused" or kind == "failed")
        table.insert(botones, ui.button({ text = pausado and tr("btn_resume") or tr("btn_pause"), glyph = pausado and "player-play" or "player-pause", variant = "outline", onClick = function() orden(pausado and "resume" or "pause") end }))
        table.insert(botones, ui.button({ text = tr("btn_open_folder"), glyph = "folder", variant = "ghost", onClick = function() noctalia.runAsync({ "sh", "-c", 'xdg-open "$HOME/OneDrive"' }); panel.close() end }))
    end
    table.insert(botones, ui.button({ text = tr("btn_web"), glyph = "world", variant = "ghost", onClick = function() noctalia.runAsync({ "xdg-open", "https://www.office.com/launch/onedrive" }); panel.close() end }))
    table.insert(filas, ui.row({ gap = 8, align = "center" }, botones))
    return ui.column({ gap = 6 }, filas)
end

local function bloqueTrabajo(job)
    local kind, fase = job.kind or "", job.phase or ""
    if kind == "" or fase == "" then return nil end
    if fase == "running" then
        return ui.label({ text = tr("job_running_" .. kind), fontSize = 13, color = "primary" })
    end
    if kind == "test" and fase ~= "running" then
        -- Cualquier error en la prueba la invalida: sin «Apply».
        if job.exit ~= "0" or (tonumber(job.errors or "0") or 0) > 0 then
            local filas = { ui.label({ text = tr("test_failed"), fontSize = 13, color = "error" }) }
            if job.error_msg and job.error_msg ~= "" then
                table.insert(filas, ui.label({ text = job.error_msg, fontSize = 12, color = "on_surface_variant" }))
            end
            return ui.column({ gap = 4 }, filas)
        end
        local borra = tonumber(job.deletes_online or "0") or 0
        local filas = {
            ui.label({ text = tr("test_result", { down = job.downloads or "0", up = job.uploads or "0", dellocal = job.deletes_local or "0" }), fontSize = 13 }),
        }
        if borra > 0 then
            table.insert(filas, ui.label({ text = tr("test_deletes_online", { n = borra }), fontSize = 13, fontWeight = "bold", color = "error" }))
        end
        if probada ~= nil and probada == exclusiones() then
            table.insert(filas, ui.row({ gap = 8 }, {
                ui.button({ text = tr("btn_apply"), glyph = "check", variant = borra > 0 and "destructive" or "primary", onClick = function() orden("apply", probada) end }),
                ui.button({ text = tr("btn_cancel"), variant = "ghost", onClick = function() probada = nil; copiarSeleccion(); render() end }),
            }))
        else
            table.insert(filas, ui.label({ text = tr("test_stale"), fontSize = 12, color = "on_surface_variant" }))
        end
        return ui.column({ gap = 6 }, filas)
    end
    if kind == "apply" then
        return ui.label({ text = tr(fase == "done" and "apply_done" or "apply_failed"), fontSize = 13, color = fase == "done" and "primary" or "error" })
    end
    if kind == "login" and fase == "failed" then
        return ui.column({ gap = 6 }, {
            ui.label({ text = tr("login_failed"), fontSize = 13, color = "error" }),
            ui.row({ gap = 8 }, {
                ui.button({ text = tr("btn_sign_in_terminal"), glyph = "terminal-2", variant = "outline", onClick = function() noctalia.runAsync({ "ghostty", "-e", "onedrive", "--display-quota" }); panel.close() end }),
                (job.consent and job.consent ~= "") and ui.button({ text = tr("btn_copy_consent"), glyph = "copy", variant = "ghost", onClick = function() noctalia.runAsync({ "noctalia", "msg", "clipboard-copy", job.consent }) end }) or ui.spacer(),
            }),
        })
    end
    return nil
end

local function listaCarpetas(job)
    local fs = carpetas()
    if #fs == 0 then return { ui.label({ text = tr("loading"), fontSize = 12, color = "on_surface_variant" }) } end
    if sel == nil then copiarSeleccion() end
    local filas = {}
    local ocupado = (job.phase == "running")
    for _, c in ipairs(fs) do
        local detalle = c.included and tamano(c.bytes) or (c.bytes > 0 and tr("cloud_only_local", { size = tamano(c.bytes) }) or tr("cloud_only"))
        local fila = {
            ui.label({ text = c.name, fontSize = 13, flexGrow = 1 }),
            ui.label({ text = detalle, fontSize = 12, color = "on_surface_variant" }),
        }
        -- Liberar espacio: solo para carpetas ya excluidas que aún tienen copia local.
        if not c.included and c.bytes > 0 and not ocupado then
            table.insert(fila, ui.button({ text = tr("btn_free_space"), variant = "ghost", controlSize = "sm", onClick = function() orden("cleanup", c.name) end }))
        end
        table.insert(fila, ui.toggle({ checked = sel[c.name] ~= false, enabled = not ocupado, onChange = function(v)
            sel[c.name] = (v == "true"); render()
        end }))
        table.insert(filas, ui.row({ gap = 8, align = "center" }, fila))
    end
    if not ocupado and exclusiones() ~= exclusionesActuales() then
        table.insert(filas, ui.row({ gap = 8 }, {
            ui.button({ text = tr("btn_test"), glyph = "flask", variant = "primary", onClick = function() probada = exclusiones(); orden("test", probada) end }),
            ui.button({ text = tr("btn_discard"), variant = "ghost", onClick = function() probada = nil; copiarSeleccion(); render() end }),
        }))
    end
    return filas
end

local OPCIONES = { "errors", "all", "none" }

local function avisos()
    local actual = noctalia.state.get("od_notify") or "errors"
    local idx = 0
    for i, o in ipairs(OPCIONES) do if o == actual then idx = i - 1 end end
    return ui.row({ gap = 10, align = "center" }, {
        ui.label({ text = tr("notifications"), fontSize = 13, flexGrow = 1 }),
        ui.select({ options = { tr("notify_errors"), tr("notify_all"), tr("notify_none") }, selectedIndex = idx, onChange = function(i)
            local v = OPCIONES[(tonumber(i) or 0) + 1]
            if v and v ~= actual then orden("notify", v) end
        end }),
    })
end

local function registro()
    local log = noctalia.state.get("od_log") or {}
    local filas = {}
    if #log == 0 then
        table.insert(filas, ui.label({ text = tr("log_empty"), fontSize = 12, color = "on_surface_variant" }))
    end
    for i = #log, 1, -1 do   -- lo más reciente arriba
        local e = log[i]
        table.insert(filas, ui.row({ gap = 8 }, {
            ui.label({ text = e.time, fontSize = 12, color = "on_surface_variant" }),
            ui.label({ text = e.msg, fontSize = 12, flexGrow = 1 }),
        }))
    end
    return ui.scroll({ key = "od-log", flexGrow = 1, gap = 4 }, filas)
end

local function dibujar()
    local st = noctalia.state.get("od_status") or {}
    local job = noctalia.state.get("od_job") or {}
    local hijos = { cabecera(st, noctalia.state.get("od_summary")) }
    if st.kind ~= "noauth" and st.kind ~= "noinstall" then
        table.insert(hijos, ui.separator({ spacing = 8 }))
        table.insert(hijos, seccion(tr("folders_title")))
        table.insert(hijos, ui.label({ text = tr("folders_hint"), fontSize = 12, color = "on_surface_variant" }))
        for _, f in ipairs(listaCarpetas(job)) do table.insert(hijos, f) end
        local bt = bloqueTrabajo(job)
        if bt then table.insert(hijos, bt) end
        table.insert(hijos, ui.separator({ spacing = 8 }))
        table.insert(hijos, avisos())
        table.insert(hijos, ui.separator({ spacing = 8 }))
        table.insert(hijos, seccion(tr("activity_title")))
        table.insert(hijos, registro())
    else
        local bt = bloqueTrabajo(job)
        if bt then table.insert(hijos, bt) end
    end
    panel.render(ui.column({ gap = 8, flexGrow = 1, align = "stretch" }, hijos))
end

-- Un error al dibujar cierra el panel sin dejar rastro: se anota en el log de noctalia.
function render()
    if not abierto then return end
    local ok, err = pcall(dibujar)
    if not ok then noctalia.log("onedrive panel: " .. tostring(err)) end
end

for _, k in ipairs({ "od_status", "od_summary", "od_log", "od_notify", "od_job" }) do
    noctalia.state.watch(k, function() render() end)
end
noctalia.state.watch("od_folders", function()
    -- Al cambiar la lista real (tras aplicar o limpiar), la selección vuelve a la real.
    if probada == nil then copiarSeleccion() end
    render()
end)

function onOpen(_ctx)
    abierto = true
    orden("refresh")
    render()
end

function onClose()
    abierto = false
end
