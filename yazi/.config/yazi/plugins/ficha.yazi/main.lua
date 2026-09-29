--- @since 26.9.1
-- ficha.yazi — vista previa con la imagen arriba y los datos del archivo abajo.
--   vídeo: el fotograma de la vista previa de fábrica (J/K lo mueven, como siempre)
--   foto:  la imagen (la caché de la vista previa de fábrica, o el archivo)
--   audio: la portada, si el archivo la trae
-- Datos con ffprobe; en fotos, los de cámara (EXIF) con exiftool si está instalado.
-- Plugin propio del repo (paquete stow yazi/), no de `ya pkg`: no lo actualiza nadie más.
-- Escrito sobre la API de yazi 26.9.1 (ya.file_cache, ya.image_show, ya.preview_widget);
-- si una versión nueva lo rompe, comparar con preset/plugins/video.lua de esa versión.
-- En yazi.toml: run = "ficha video" | "ficha image" | "ficha audio".

local M = {}

-- Cachés propias (datos y portada): yazi corre todas las precargas que coinciden, y las de
-- fábrica escriben en ya.file_cache(job). Otro valor de skip da otro archivo, que también se
-- invalida cuando el original cambia. NOIMG marca «sin portada» en su propio archivo, para
-- no pisar nunca una imagen buena.
local IMG, TXT, NOIMG = 90000, 90001, 90002

local function cache(job, n) return ya.file_cache { file = job.file, skip = n } end

local function exists(url)
	local cha = url and fs.cha(url)
	return cha ~= nil, cha and cha.len or 0
end

-- ---------- formato

local function comma(x, d) return (string.format("%." .. d .. "f", x):gsub("%.", ",")) end

-- De a 1024, como la columna de tamaño de yazi, para que los dos números coincidan
local function size(bytes)
	local n = tonumber(bytes)
	if not n then return nil end
	for _, u in ipairs { "B", "KB", "MB", "GB" } do
		if n < 1024 or u == "GB" then return (u == "B" and tostring(math.floor(n)) or comma(n, 1)) .. " " .. u end
		n = n / 1024
	end
end

local function rate(bits)
	local n = tonumber(bits)
	if not n or n <= 0 then return nil end
	return n >= 1e6 and comma(n / 1e6, 1) .. " Mb/s" or math.floor(n / 1e3) .. " kb/s"
end

local function duration(secs)
	local s = math.floor(tonumber(secs) or 0)
	if s <= 0 then return nil end
	local h, m = s // 3600, (s % 3600) // 60
	return h > 0 and string.format("%d:%02d:%02d", h, m, s % 60) or string.format("%d:%02d", m, s % 60)
end

local function fps(r)
	local a, b = tostring(r or ""):match("^(%d+)/(%d+)$")
	a, b = tonumber(a), tonumber(b)
	if not a or not b or b == 0 or a == 0 then return nil end
	local f = a / b
	return (math.abs(f - math.floor(f + 0.5)) < 0.01 and tostring(math.floor(f + 0.5)) or comma(f, 2)) .. " fps"
end

local function join(t)
	local out = {}
	for _, v in ipairs(t) do
		if v and v ~= "" then out[#out + 1] = v end
	end
	return table.concat(out, " · ")
end

local function tag(tags, key)
	for k, v in pairs(tags or {}) do
		if k:lower() == key then return v end
	end
end

-- ---------- datos

local function probe(path)
	local out = Command("ffprobe")
		:arg({ "-v", "quiet", "-show_format", "-show_streams", "-of", "json", tostring(path) })
		:output()
	if not out or not out.status.success then return nil end
	local t = ya.json_decode(out.stdout)
	return type(t) == "table" and t or nil
end

local function exif(path)
	local out = Command("exiftool")
		:arg({ "-json", "-Make", "-Model", "-LensModel", "-DateTimeOriginal", "-ExposureTime",
			"-FNumber", "-ISO", "-FocalLength", "-GPSPosition", tostring(path) })
		:output()
	if not out or not out.status.success then return nil end
	local t = ya.json_decode(out.stdout)
	return type(t) == "table" and t[1] or nil
end

local function rows_video(p)
	local f, rows = p.format or {}, {}
	rows[#rows + 1] = { "Título", tag(f.tags, "title") }
	rows[#rows + 1] = { "Duración", duration(f.duration) }
	rows[#rows + 1] = { "Archivo", join { size(f.size), rate(f.bit_rate) } }
	for _, s in ipairs(p.streams or {}) do
		local pic = s.disposition and s.disposition.attached_pic == 1
		local lang = tag(s.tags, "language")
		lang = lang ~= "und" and lang or nil
		if s.codec_type == "video" and not pic then
			rows[#rows + 1] = { "Vídeo", join { s.codec_name, s.width and (s.width .. "×" .. s.height), fps(s.avg_frame_rate) } }
		elseif s.codec_type == "audio" then
			rows[#rows + 1] = { "Audio", join {
				s.codec_name, s.channels and (s.channels .. " canales"),
				s.sample_rate and (comma(tonumber(s.sample_rate) / 1000, 1) .. " kHz"), lang,
			} }
		elseif s.codec_type == "subtitle" then
			rows[#rows + 1] = { "Subtítulos", join { s.codec_name, lang } }
		end
	end
	return rows
end

local function rows_audio(p)
	local f, rows = p.format or {}, {}
	for _, kv in ipairs {
		{ "Título", "title" }, { "Artista", "artist" }, { "Álbum", "album" },
		{ "Año", "date" }, { "Género", "genre" }, { "Pista", "track" },
	} do
		rows[#rows + 1] = { kv[1], tag(f.tags, kv[2]) }
	end
	rows[#rows + 1] = { "Duración", duration(f.duration) }
	for _, s in ipairs(p.streams or {}) do
		if s.codec_type == "audio" then
			rows[#rows + 1] = { "Calidad", join {
				s.codec_name, rate(s.bit_rate or f.bit_rate),
				s.sample_rate and (comma(tonumber(s.sample_rate) / 1000, 1) .. " kHz"),
				s.channels and (s.channels .. " canales"),
			} }
			break
		end
	end
	rows[#rows + 1] = { "Archivo", size(f.size) }
	return rows
end

local function rows_image(p, path)
	local f, s, rows = p.format or {}, (p.streams or {})[1] or {}, {}
	local fmt = ({ mjpeg = "JPEG", png = "PNG", webp = "WebP", gif = "GIF", tiff = "TIFF", bmp = "BMP" })[s.codec_name or ""]
	rows[#rows + 1] = { "Formato", fmt or s.codec_name }
	rows[#rows + 1] = { "Tamaño", join { s.width and (s.width .. "×" .. s.height), size(f.size) } }
	local e = exif(path)
	if e then
		rows[#rows + 1] = { "Cámara", join { e.Make, e.Model } }
		rows[#rows + 1] = { "Lente", e.LensModel }
		rows[#rows + 1] = { "Fecha", e.DateTimeOriginal }
		rows[#rows + 1] = { "Exposición", join {
			e.ExposureTime and (e.ExposureTime .. " s"), e.FNumber and ("f/" .. e.FNumber),
			e.ISO and ("ISO " .. e.ISO), e.FocalLength,
		} }
		rows[#rows + 1] = { "GPS", e.GPSPosition }
	end
	return rows
end

-- Filas como texto «etiqueta<TAB>valor», sin las vacías (lo que se guarda en caché)
local function rows_text(kind, path)
	local p = probe(path)
	if not p then return "" end
	local rows = kind == "video" and rows_video(p) or kind == "audio" and rows_audio(p) or rows_image(p, path)
	local out = {}
	for _, r in ipairs(rows) do
		if r[2] and tostring(r[2]) ~= "" then out[#out + 1] = r[1] .. "\t" .. tostring(r[2]) end
	end
	return table.concat(out, "\n")
end

-- ---------- imagen

local function cover(job, out)
	return Command("ffmpeg"):stderr(Command.PIPED):arg({
		"-v", "error", "-i", tostring(job.file.path), "-an", "-map", "disp:attached_pic", "-frames:v", 1,
		"-vf", string.format("scale='min(%d,iw)':'min(%d,ih)':force_original_aspect_ratio=decrease", rt.preview.max_width, rt.preview.max_height),
		"-q:v", 31 - math.floor(rt.preview.image_quality * 0.3), "-f", "image2", "-update", 1, "-y", tostring(out),
	}):output()
end

-- ---------- entradas de yazi

function M:preload(job)
	local kind = job.args[1]
	local txt = cache(job, TXT)
	if txt and not exists(txt) then
		fs.write(txt, rows_text(kind, job.file.path))
	end
	-- La imagen de fotos y vídeos la precargan los plugins image y video de fábrica
	if kind ~= "audio" then return true end

	local img, none = cache(job, IMG), cache(job, NOIMG)
	if not img or exists(img) or exists(none) then return true end
	-- La precarga y la vista previa pueden sacar la misma portada a la vez: cada una escribe
	-- en su temporal y lo mueve al final, así ninguna deja a medias el archivo de la otra.
	local tmp = Url(string.format("%s.%d.tmp", tostring(img), math.random(1, 1000000000)))
	local out = cover(job, tmp)
	local _, len = exists(tmp)
	if out and out.status.success and len > 0 then
		fs.rename(tmp, img)
	else
		-- al registro (YAZI_LOG=debug yazi, ~/.local/state/yazi/yazi.log)
		ya.dbg(string.format("ficha: sin portada en %s: %s", tostring(job.file.path), out and out.stderr or "ffmpeg no arrancó"))
		fs.remove("file", tmp)
		if not exists(img) then fs.write(none, "") end -- no reintentar en cada vistazo
	end
	return true
end

function M:peek(job)
	local start, kind = os.clock(), job.args[1]
	self:preload(job)
	-- Vídeo: el fotograma lo saca el plugin de fábrica (por la Intel, ~0,1 s) para este job.skip
	if kind == "video" then require("video"):preload(job) end

	local txt, data = cache(job, TXT), nil
	if txt then
		local f = io.open(tostring(txt), "r")
		if f then data = f:read("a"); f:close() end
	end
	data = data or rows_text(kind, job.file.path)

	local lines = {}
	for label, value in data:gmatch("([^\t\n]+)\t([^\n]*)") do
		-- relleno por caracteres, no bytes: «Duración» o «Álbum» llevan tildes
		local pad = string.rep(" ", math.max(1, 11 - (utf8.len(label) or #label)))
		lines[#lines + 1] = ui.Line { ui.Span(label .. pad):fg("red"), ui.Span(value) }
	end

	local img
	if kind == "image" then
		img = ya.file_cache(job)
		if not img or not exists(img) then img = Url(job.file.path) end
	elseif kind == "video" then
		local c = ya.file_cache(job)
		local ok, len = exists(c)
		img = ok and len > 0 and c or nil
	else
		local c = cache(job, IMG)
		img = exists(c) and c or nil
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	local a, used = job.area, 0
	if img then
		local rect = ya.image_show(img, ui.Rect { x = a.x, y = a.y, w = a.w, h = math.max(1, a.h - #lines - 1) })
		used = rect and rect.h and rect.h + 1 or 0
	end
	ya.preview_widget(job, {
		ui.Text(lines):area(ui.Rect { x = a.x, y = a.y + used, w = a.w, h = math.max(0, a.h - used) }),
	})
end

-- J/K: en vídeo avanzan o retroceden el fotograma, como la vista previa de fábrica
function M:seek(job) require("video"):seek(job) end

return M
