" ghostty — mirrors the Ghostty terminal it is running inside.
"
" The background, foreground and full 16-colour ANSI palette are read from
" `ghostty +show-config` (falling back to the on-disk config/theme files) and
" fed to aether.nvim. The background is left transparent so Neovim inherits
" Ghostty's `background-opacity`/`background-blur` instead of painting an
" opaque rectangle over it. A watcher re-applies everything whenever the
" Ghostty theme or config changes. See lua/ghostty_theme/init.lua.

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'ghostty'

lua require('ghostty_theme').load()
