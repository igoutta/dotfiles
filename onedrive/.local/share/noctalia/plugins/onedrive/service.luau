--!nonstrict
-- Servicio del plugin OneDrive: la única parte que llama a onedrive-ctl. Publica el estado en
-- noctalia.state (od_status, od_summary, od_folders, od_log, od_notify, od_job) para la nube de la
-- barra y el panel, y atiende sus órdenes por IPC:
--   noctalia msg plugin ga/onedrive:service all <refresh|pause|resume|notify|test|apply|login|cleanup> [dato]
-- Estado cada 10 s; cada 2 s mientras hay un trabajo largo (prueba, aplicar, iniciar sesión).

local CTL = "onedrive-ctl"
local siguiendoTrabajo = false

local function lineas(texto)
    local t = {}
    for l in string.gmatch(texto or "", "[^\n]+") do table.insert(t, l) end
    return t
end

local function claves(texto)
    local t = {}
    for _, l in ipairs(lineas(texto)) do
        local k, v = string.match(l, "^([^\t]+)\t?(.*)$")
        if k then t[k] = v end
    end
    return t
end

local function correr(args, cb, espera)
    noctalia.runAsync(args, function(r)
        if cb then cb((r and r.stdout) or "", r) end
    end, espera or 20000)
end

local function refrescarEstado()
    correr({ CTL, "status" }, function(out)
        local k, t = string.match(out, "^(%S+)\t?(%S*)")
        noctalia.state.set("od_status", { kind = k or "unknown", time = t or "" })
    end)
end

local function refrescarDetalles()
    correr({ CTL, "summary" }, function(out) noctalia.state.set("od_summary", claves(out)) end, 60000)
    correr({ CTL, "folders" }, function(out)
        local lista = {}
        for _, l in ipairs(lineas(out)) do
            local n, inc, b = string.match(l, "^(.-)\t(%d)\t(%d+)$")
            if n then table.insert(lista, { name = n, included = inc == "1", bytes = tonumber(b) or 0 }) end
        end
        noctalia.state.set("od_folders", lista)
    end, 120000)
    correr({ CTL, "log", "40" }, function(out)
        local lista = {}
        for _, l in ipairs(lineas(out)) do
            local h, m = string.match(l, "^(%S+)\t(.*)$")
            if h then table.insert(lista, { time = h, msg = m }) end
        end
        noctalia.state.set("od_log", lista)
    end)
    correr({ CTL, "notify", "get" }, function(out)
        noctalia.state.set("od_notify", string.match(out, "%a+") or "errors")
    end)
end

local function refrescarTrabajo()
    correr({ CTL, "job" }, function(out)
        local kv = claves(out)
        noctalia.state.set("od_job", kv)
        if kv.phase == "running" then
            siguiendoTrabajo = true
        elseif siguiendoTrabajo then
            siguiendoTrabajo = false
            refrescarEstado()
            refrescarDetalles()
        end
    end)
end

function update()
    noctalia.setUpdateInterval(siguiendoTrabajo and 2000 or 10000)
    refrescarEstado()
    if siguiendoTrabajo then refrescarTrabajo() end
end

function onIpc(evento, dato)
    if evento == "refresh" then
        refrescarEstado(); refrescarDetalles(); refrescarTrabajo()
    elseif evento == "pause" or evento == "resume" then
        correr({ CTL, evento }, function() refrescarEstado() end)
    elseif evento == "notify" and dato then
        correr({ CTL, "notify", dato }, function() refrescarDetalles() end)
    elseif evento == "test" or evento == "apply" then
        correr({ CTL, evento, dato or "" }, function() siguiendoTrabajo = true; refrescarTrabajo() end)
    elseif evento == "login" then
        correr({ CTL, "login" }, function() siguiendoTrabajo = true; refrescarTrabajo() end)
    elseif evento == "cleanup" and dato then
        correr({ CTL, "cleanup", dato }, function(out)
            if string.find(out, "ok", 1, true) then
                noctalia.notify("OneDrive", noctalia.tr("cleanup_done", { name = dato }))
            else
                noctalia.notifyError("OneDrive", noctalia.tr("cleanup_failed", { name = dato }))
            end
            refrescarDetalles()
        end, 120000)
    end
end

refrescarEstado()
refrescarTrabajo()
