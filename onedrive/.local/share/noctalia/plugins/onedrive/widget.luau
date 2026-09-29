--!nonstrict
-- Nube de OneDrive en la barra (paquete stow onedrive/). El estado lo publica el servicio del
-- plugin (service.luau, od_status); aquí solo se pinta.
-- Clic: abrir el panel. Clic derecho: pausar o reanudar. Oculta si el cliente no está instalado.

local SERVICIO = "ga/onedrive:service"
local AMBAR = "#e6b450"   -- ámbar de Ayu Red: trabajando o sin sesión
local ROJO = "#d95757"    -- rojo de Ayu Red: error o parado por fallo

local ASPECTO = {
    synced    = { "cloud-check", "" },
    running   = { "cloud", "" },
    syncing   = { "cloud-up", AMBAR },
    paused    = { "cloud-pause", "" },
    offline   = { "cloud-off", AMBAR },
    error     = { "cloud-exclamation", ROJO },
    failed    = { "cloud-x", ROJO },
    noauth    = { "cloud-question", AMBAR },
    unknown   = { "cloud", "" },
}

local kind = "unknown"

local function pintar()
    local st = noctalia.state.get("od_status") or {}
    kind = st.kind or "unknown"
    if kind == "noinstall" then barWidget.setVisible(false); return end
    local a = ASPECTO[kind] or ASPECTO.unknown
    barWidget.setVisible(true)
    barWidget.setGlyph(a[1])
    barWidget.setGlyphColor(a[2])
    barWidget.setText("")
    barWidget.setTooltip(noctalia.tr("status_" .. kind, { time = st.time or "" }) .. "\n" .. noctalia.tr("tooltip_hint"))
end

noctalia.state.watch("od_status", function() pintar() end)

function onClick()
    noctalia.togglePanel("ga/onedrive:panel")
end

function onRightClick()
    if kind == "noauth" or kind == "noinstall" or kind == "unknown" then return end
    local ev = (kind == "paused" or kind == "failed") and "resume" or "pause"
    noctalia.runAsync({ "noctalia", "msg", "plugin", SERVICIO, "all", ev })
end

pintar()
