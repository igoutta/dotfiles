-- ~/.config/yazi/init.lua — arranque de los plugins que lo necesitan. Los plugins los
-- instala `ya pkg install` desde package.toml (versiones fijadas) en plugins/, fuera del repo.

-- tipo de archivo por la extensión (yazi.toml); lo que no está en su tabla, con file(1).
-- Modelos 3D añadidos: sin esto un STEP sale como text/plain (es texto por dentro) y un STL
-- binario como application/octet-stream, y yazi los abría con Helix o con nada.
require("mime-ext.local"):setup {
	fallback_file1 = true,
	with_exts = { stl = "model/stl", stp = "model/step", step = "model/step" },
}

-- Paneles según el ancho de la ventana, en columnas. Con una terminal angosta (los monitores en
-- vertical) el reparto fijo de 1:4:3 deja todo apretado. Ancha (>= 100): los tres paneles;
-- mediana (60-99): sin la carpeta de arriba; angosta (< 60): solo la lista. Si un panel está
-- agrandado o encogido a mano (T, toggle-pane), se respeta tal cual. Es una copia de Tab:layout
-- del preset de yazi 26.9.1 con el reparto cambiado: si una versión nueva lo cambia, comparar.
local WIDE, MEDIUM = 100, 60
function Tab:layout()
	local r, w = rt.mgr.ratio, self._area.w
	local base = { r[1], r[2], r[3] }
	local manual = r[1] >= 9999 or r[2] >= 9999 or r[3] >= 9999
	if not manual and w < MEDIUM then
		base = { 0, r[2], 0 }
	elseif not manual and w < WIDE then
		base = { 0, r[2], r[3] }
	end
	local all = base[1] + base[2] + base[3]
	self._chunks = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Ratio(base[1], all),
			ui.Constraint.Ratio(base[2], all),
			ui.Constraint.Ratio(base[3], all),
		})
		:split(self._area)
end

-- bordes alrededor de los paneles
require("full-border"):setup()

-- estado de git junto al nombre (M, A, ?, …) al entrar en un repo, como ~/dotfiles
require("git"):setup { order = 1500 }
