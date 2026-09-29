-- ~/.config/yazi/init.lua — arranque de los plugins que lo necesitan. Los plugins los
-- instala `ya pkg install` desde package.toml (versiones fijadas) en plugins/, fuera del repo.

-- tipo de archivo por la extensión (yazi.toml); lo que no está en su tabla, con file(1)
require("mime-ext.local"):setup { fallback_file1 = true }

-- bordes alrededor de los tres paneles
require("full-border"):setup()

-- estado de git junto al nombre (M, A, ?, …) al entrar en un repo, como ~/dotfiles
require("git"):setup { order = 1500 }
