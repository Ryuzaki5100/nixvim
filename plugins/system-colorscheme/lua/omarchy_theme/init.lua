-- Omarchy-aware colorscheme engine for the "system" theme.
--
-- Reads the active Omarchy palette from the current theme and maps it onto
-- Neovim highlight groups. Newer (Aether) themes expose a flat
--   ~/.local/state/omarchy/current/theme/colors.toml
-- while older themes only ship an Alacritty palette
--   ~/.local/state/omarchy/current/theme/alacritty.toml
-- Both are supported, so any theme you add is picked up. A lightweight watcher
-- re-applies the palette when the desktop theme changes, so a running Neovim
-- follows `omarchy theme set` without a restart.
--
-- Falls back to a neutral dark palette when no Omarchy theme file is present.

local M = {}

local function uv()
  return vim.uv or vim.loop
end

local function state_dir()
  local xdg = vim.env.XDG_STATE_HOME
  if xdg and xdg ~= "" then
    return xdg
  end
  return (vim.env.HOME or "~") .. "/.local/state"
end

local function theme_dir()
  return state_dir() .. "/omarchy/current/theme"
end

local function colors_path()
  return theme_dir() .. "/colors.toml"
end

local function alacritty_path()
  return theme_dir() .. "/alacritty.toml"
end

-- Flat `key = "#hex"` / `mode = "dark"` reader used by Aether-generated
-- colors.toml. Returns nil when the file is missing.
local function parse_colors_toml(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end

  local out = {}
  for line in fd:lines() do
    local key, value = line:match('^%s*([%w_]+)%s*=%s*"(#%x%x%x%x%x%x%x?%x?)"')
    if key then
      out[key:lower()] = value
    end
    local mode = line:match('^%s*mode%s*=%s*"(%a+)"')
    if mode then
      out.mode = mode:lower()
    end
  end
  fd:close()

  return out
end

-- Sectioned TOML reader for the older Alacritty themes, whose palette lives
-- under [colors.primary], [colors.normal], [colors.bright], [colors.selection].
local function parse_alacritty_toml(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end

  local out = {}
  local section = ""
  local section_map = {
    ["colors.primary"] = "",
    ["colors.normal"] = "",
    ["colors.bright"] = "bright_",
    ["colors.selection"] = "selection_",
  }

  for line in fd:lines() do
    local header = line:match("^%s*%[([%w_.%-]+)%]")
    if header then
      -- nil for unknown sections ("" is truthy in Lua, so primary still maps)
      section = section_map[header]
    else
      local key, value = line:match('^%s*([%w_]+)%s*=%s*"(#%x%x%x%x%x%x%x?%x?)"')
      if key and section then
        out[(section .. key:lower())] = value
      end
    end
  end
  fd:close()

  -- Normalise to the same vocabulary the Aether palette uses.
  return {
    mode = "dark",
    background = out.background,
    foreground = out.foreground,
    muted = out.dim_foreground,
    selection = out.selection_background,
    red = out.red,
    bright_red = out.bright_red,
    green = out.green,
    bright_green = out.bright_green,
    yellow = out.yellow,
    bright_yellow = out.bright_yellow,
    blue = out.blue,
    bright_blue = out.bright_blue,
    magenta = out.magenta,
    bright_magenta = out.bright_magenta,
    cyan = out.cyan,
    bright_cyan = out.bright_cyan,
  }
end

-- Return the active palette, preferring the modern colors.toml and falling
-- back to an Alacritty theme. Returns an empty table when neither exists.
local function read_palette()
  local modern = parse_colors_toml(colors_path())
  if modern and next(modern) then
    return modern
  end
  return parse_alacritty_toml(alacritty_path()) or {}
end

-- get(palette, "primary", "fallback_key", "#literal") -> first match wins.
-- A literal starting with "#" short-circuits; keys are looked up in the
-- palette; the foreground is the last resort.
local function get(palette, ...)
  local keys = { ... }
  for _, key in ipairs(keys) do
    if key:sub(1, 1) == "#" then
      return key
    end
    if palette[key] then
      return palette[key]
    end
  end
  return palette.foreground or "#d4d4d4"
end

local function hex_to_rgb(hex)
  local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)")
  if not r then
    return 0, 0, 0
  end
  return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

local function mix(base, overlay, amount)
  local br, bg, bb = hex_to_rgb(base)
  local or_, og, ob = hex_to_rgb(overlay)
  local function channel(a, b)
    return math.floor(a + (b - a) * amount + 0.5)
  end
  return string.format("#%02x%02x%02x", channel(br, or_), channel(bg, og), channel(bb, ob))
end

local function build_palette(palette)
  local bg = get(palette, "background", "#1e1e1e")
  local fg = get(palette, "foreground", "#d4d4d4")

  local red = get(palette, "red", "color1", "#ff5555")
  local green = get(palette, "green", "color2", "#50fa7b")
  local yellow = get(palette, "yellow", "color3", "#f1fa8c")
  local blue = get(palette, "blue", "color4", "accent", "#61afef")
  local magenta = get(palette, "magenta", "color5", "accent", "#c678dd")
  local cyan = get(palette, "cyan", "color6", "blue", blue)

  return {
    mode = palette.mode or "dark",
    bg = bg,
    dark_bg = get(palette, "dark_background", "darker_background", bg),
    darker_bg = get(palette, "darker_background", "dark_background", bg),
    lighter_bg = get(palette, "lighter_background", "selection", "dark_background", bg),
    fg = fg,
    bright_fg = get(palette, "bright_foreground", "foreground", "color15", fg),
    muted = get(palette, "muted", "dark_foreground", "color8", "#9e9e9e"),
    selection = get(palette, "selection", "lighter_background", "dark_background", bg),
    accent = get(palette, "accent", "blue", "color4", fg),

    red = red,
    bright_red = get(palette, "bright_red", "red", "color9", red),
    green = green,
    bright_green = get(palette, "bright_green", "green", "color10", green),
    yellow = yellow,
    bright_yellow = get(palette, "bright_yellow", "yellow", "color11", yellow),
    orange = get(palette, "orange", "yellow", "color3", yellow),
    blue = blue,
    bright_blue = get(palette, "bright_blue", "blue", "color12", blue),
    magenta = magenta,
    bright_magenta = get(palette, "bright_magenta", "magenta", "color13", magenta),
    cyan = cyan,
    bright_cyan = get(palette, "bright_cyan", "cyan", "color14", cyan),
    brown = get(palette, "brown", "orange", yellow),
  }
end

local function apply_highlights(c)
  local hl = function(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- Editor chrome (transparent Normal so the Omarchy terminal bg shows through)
  hl("Normal", { fg = c.fg, bg = "NONE" })
  hl("NormalFloat", { fg = c.fg, bg = c.lighter_bg })
  hl("NormalSB", { fg = c.fg, bg = c.dark_bg })
  hl("FloatBorder", { fg = c.muted, bg = c.lighter_bg })
  hl("FloatTitle", { fg = c.accent, bg = c.lighter_bg, bold = true })
  hl("SignColumn", { fg = c.muted, bg = "NONE" })
  hl("FoldColumn", { fg = c.muted, bg = "NONE" })
  hl("CursorLine", { bg = c.lighter_bg })
  hl("CursorLineNr", { fg = c.accent, bold = true })
  hl("CursorColumn", { bg = c.lighter_bg })
  hl("LineNr", { fg = c.muted })
  hl("ColorColumn", { bg = c.dark_bg })
  hl("Visual", { bg = c.selection })
  hl("VisualNOS", { bg = c.lighter_bg })
  hl("MatchParen", { fg = c.accent, bold = true })
  hl("Search", { fg = c.bg, bg = c.yellow })
  hl("IncSearch", { fg = c.bg, bg = c.accent })
  hl("CurSearch", { fg = c.bg, bg = c.accent })
  hl("Substitute", { fg = c.bg, bg = c.red })
  hl("Folded", { fg = c.muted, bg = c.dark_bg })
  hl("FoldColumn", { fg = c.muted, bg = "NONE" })
  hl("EndOfBuffer", { fg = c.darker_bg })
  hl("NonText", { fg = c.darker_bg })
  hl("Whitespace", { fg = c.darker_bg })
  hl("SpecialKey", { fg = c.muted })
  hl("Conceal", { fg = c.muted })

  -- Status / tab line
  hl("StatusLine", { fg = c.fg, bg = c.lighter_bg })
  hl("StatusLineNC", { fg = c.muted, bg = c.dark_bg })
  hl("WinSeparator", { fg = c.lighter_bg })
  hl("VertSplit", { fg = c.lighter_bg })
  hl("TabLine", { fg = c.muted, bg = c.dark_bg })
  hl("TabLineFill", { fg = c.muted, bg = c.dark_bg })
  hl("TabLineSel", { fg = c.fg, bg = c.lighter_bg })
  hl("Title", { fg = c.accent, bold = true })
  hl("WinBar", { fg = c.fg, bg = "NONE" })
  hl("WinBarNC", { fg = c.muted, bg = "NONE" })

  -- Popup menu
  hl("Pmenu", { fg = c.fg, bg = c.dark_bg })
  hl("PmenuSel", { fg = c.bg, bg = c.accent })
  hl("PmenuSbar", { bg = c.darker_bg })
  hl("PmenuThumb", { bg = c.lighter_bg })
  hl("PmenuMatch", { fg = c.accent, bg = c.dark_bg })
  hl("PmenuMatchSel", { fg = c.bg, bg = c.accent })
  hl("PmenuExtra", { fg = c.muted, bg = c.dark_bg })
  hl("PmenuExtraSel", { fg = c.bg, bg = c.accent })

  -- Cursor
  hl("Cursor", { fg = c.bg, bg = c.bright_fg })
  hl("CursorIM", { fg = c.bg, bg = c.bright_fg })
  hl("TermCursor", { fg = c.bg, bg = c.bright_fg })

  -- Syntax
  hl("Comment", { fg = c.muted, italic = true })
  hl("SpecialComment", { fg = c.muted, italic = true })
  hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })
  hl("Debug", { fg = c.red })

  hl("Constant", { fg = c.orange })
  hl("String", { fg = c.green })
  hl("Character", { fg = c.green })
  hl("Number", { fg = c.orange })
  hl("Boolean", { fg = c.orange })
  hl("Float", { fg = c.orange })
  hl("Identifier", { fg = c.fg })
  hl("Function", { fg = c.blue })
  hl("Statement", { fg = c.magenta })
  hl("Conditional", { fg = c.magenta })
  hl("Repeat", { fg = c.magenta })
  hl("Label", { fg = c.magenta })
  hl("Operator", { fg = c.cyan })
  hl("Keyword", { fg = c.magenta })
  hl("Exception", { fg = c.magenta })
  hl("PreProc", { fg = c.magenta })
  hl("Include", { fg = c.magenta })
  hl("Define", { fg = c.magenta })
  hl("Macro", { fg = c.magenta })
  hl("PreCondit", { fg = c.magenta })
  hl("Type", { fg = c.cyan })
  hl("StorageClass", { fg = c.magenta })
  hl("Structure", { fg = c.cyan })
  hl("Typedef", { fg = c.cyan })
  hl("Special", { fg = c.magenta })
  hl("SpecialChar", { fg = c.cyan })
  hl("Tag", { fg = c.blue })
  hl("Delimiter", { fg = c.fg })
  hl("CommentTitle", { fg = c.accent, bold = true })

  -- Messages
  hl("Error", { fg = c.red })
  hl("ErrorMsg", { fg = c.red })
  hl("WarningMsg", { fg = c.yellow })
  hl("ModeMsg", { fg = c.accent })
  hl("MoreMsg", { fg = c.accent })
  hl("Question", { fg = c.accent })
  hl("Directory", { fg = c.blue })
  hl("WildMenu", { fg = c.bg, bg = c.accent })

  -- nvim-notify. Its defaults link NotifyBackground to Normal, which is
  -- transparent here, so it would warn and fall back to pure black. Derive the
  -- whole family from the palette so it is rebuilt on every theme change.
  hl("NotifyBackground", { bg = c.lighter_bg })
  hl("NotifyERRORBorder", { fg = c.red })
  hl("NotifyWARNBorder", { fg = c.yellow })
  hl("NotifyINFOBorder", { fg = c.green })
  hl("NotifyDEBUGBorder", { fg = c.muted })
  hl("NotifyTRACEBorder", { fg = c.magenta })
  hl("NotifyERRORIcon", { fg = c.red })
  hl("NotifyWARNIcon", { fg = c.yellow })
  hl("NotifyINFOIcon", { fg = c.green })
  hl("NotifyDEBUGIcon", { fg = c.muted })
  hl("NotifyTRACEIcon", { fg = c.magenta })
  hl("NotifyERRORTitle", { fg = c.red, bold = true })
  hl("NotifyWARNTitle", { fg = c.yellow, bold = true })
  hl("NotifyINFOTitle", { fg = c.green, bold = true })
  hl("NotifyDEBUGTitle", { fg = c.muted, bold = true })
  hl("NotifyTRACETitle", { fg = c.magenta, bold = true })
  hl("NotifyERRORBody", { fg = c.fg })
  hl("NotifyWARNBody", { fg = c.fg })
  hl("NotifyINFOBody", { fg = c.fg })
  hl("NotifyDEBUGBody", { fg = c.fg })
  hl("NotifyTRACEBody", { fg = c.fg })
  hl("NotifyLogTime", { fg = c.muted, italic = true })
  hl("NotifyLogTitle", { fg = c.accent, bold = true })

  -- Diagnostics
  hl("DiagnosticError", { fg = c.red })
  hl("DiagnosticWarn", { fg = c.yellow })
  hl("DiagnosticInfo", { fg = c.cyan })
  hl("DiagnosticHint", { fg = c.muted })
  hl("DiagnosticUnnecessary", { fg = c.muted })
  hl("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
  hl("DiagnosticUnderlineWarn", { sp = c.yellow, undercurl = true })
  hl("DiagnosticUnderlineInfo", { sp = c.cyan, undercurl = true })
  hl("DiagnosticUnderlineHint", { sp = c.muted, undercurl = true })
  hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.dark_bg })
  hl("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.dark_bg })
  hl("DiagnosticVirtualTextInfo", { fg = c.cyan, bg = c.dark_bg })
  hl("DiagnosticVirtualTextHint", { fg = c.muted, bg = c.dark_bg })
  hl("DiagnosticFloatingError", { fg = c.red, bg = c.lighter_bg })
  hl("DiagnosticFloatingWarn", { fg = c.yellow, bg = c.lighter_bg })
  hl("DiagnosticFloatingInfo", { fg = c.cyan, bg = c.lighter_bg })
  hl("DiagnosticFloatingHint", { fg = c.muted, bg = c.lighter_bg })

  -- Spelling
  hl("SpellBad", { sp = c.red, undercurl = true })
  hl("SpellCap", { sp = c.blue, undercurl = true })
  hl("SpellLocal", { sp = c.cyan, undercurl = true })
  hl("SpellRare", { sp = c.magenta, undercurl = true })

  -- LSP
  hl("LspReferenceText", { bg = c.lighter_bg })
  hl("LspReferenceRead", { bg = c.lighter_bg })
  hl("LspReferenceWrite", { bg = c.lighter_bg })
  hl("LspSignatureActiveParameter", { fg = c.orange, bold = true })

  -- Diffs / git
  hl("GitSignsAdd", { fg = c.green })
  hl("GitSignsChange", { fg = c.yellow })
  hl("GitSignsDelete", { fg = c.red })
  hl("DiffAdd", { fg = c.green, bg = mix(c.bg, c.green, 0.15) })
  hl("DiffChange", { fg = c.yellow, bg = mix(c.bg, c.yellow, 0.15) })
  hl("DiffDelete", { fg = c.red, bg = mix(c.bg, c.red, 0.15) })
  hl("DiffText", { fg = c.bright_fg, bg = mix(c.bg, c.blue, 0.25), bold = true })
  hl("Added", { fg = c.green })
  hl("Changed", { fg = c.yellow })
  hl("Removed", { fg = c.red })

  -- Indent guides
  hl("IblIndent", { fg = c.darker_bg })
  hl("IblScope", { fg = c.lighter_bg })

  -- Markdown / links
  hl("LinkText", { fg = c.blue })
  hl("LinkURL", { fg = c.cyan })
  hl("MarkdownLinkText", { fg = c.blue })
  hl("MarkdownLink", { fg = c.cyan })
  hl("MarkdownHeading", { fg = c.accent, bold = true })
  hl("MarkdownCode", { fg = c.green })
  hl("MarkdownCodeBlock", { fg = c.green })
  hl("MarkdownBlockquote", { fg = c.muted })
  hl("MarkdownEmph", { fg = c.orange, italic = true })
  hl("MarkdownStrong", { fg = c.yellow, bold = true })
  hl("MarkdownListItem", { fg = c.accent })
  hl("MarkdownListEnumeration", { fg = c.cyan })
  hl("MarkdownHorizontalRule", { fg = c.muted })
  hl("MarkdownImage", { fg = c.blue })
  hl("MarkdownImageText", { fg = c.cyan })
  hl("MarkdownBoldItalic", { fg = c.orange, bold = true, italic = true })

  -- Tests
  hl("UnitTestPassed", { fg = c.green })
  hl("UnitTestFailed", { fg = c.red, bold = true })
end

local function apply()
  local c = build_palette(read_palette())

  vim.o.background = c.mode == "light" and "light" or "dark"
  apply_highlights(c)

  M.palette = c
  return c
end

local watcher = nil
local last_signature = nil

local function file_signature(path)
  local stat = uv().fs_stat(path)
  if not stat then
    return "-"
  end
  local mtime = stat.mtime or {}
  return table.concat({ mtime.sec or 0, mtime.nsec or 0, stat.size or 0 }, ":")
end

-- Fingerprint both supported palette files; a change in either triggers a
-- reload. `theme.name` is included so an empty/identical palette still counts.
local function signature()
  return table.concat({
    file_signature(colors_path()),
    file_signature(alacritty_path()),
    file_signature(theme_dir() .. "/../theme.name"),
  }, "|")
end

local function watch()
  if watcher then
    return
  end

  last_signature = signature()
  watcher = uv().new_timer()
  watcher:start(
    2000,
    2000,
    vim.schedule_wrap(function()
      -- Only follow the system theme while it is the active colorscheme.
      if vim.g.colors_name ~= "system" then
        last_signature = signature()
        return
      end

      local current = signature()
      if current and current ~= last_signature then
        last_signature = current
        apply()
        vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
      end
    end)
  )
end

function M.load()
  apply()
  watch()
end

function M.apply()
  apply()
end

return M
