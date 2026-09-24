" system — follows the active Omarchy desktop theme.
"
" The palette is read at runtime from
"   ~/.local/state/omarchy/current/theme/colors.toml
" and re-applied automatically when the theme changes, so a running Neovim
" tracks `omarchy theme set` without a restart. See
" lua/omarchy_theme/init.lua for the mapping and fallback palette.

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'system'

lua require('omarchy_theme').load()
