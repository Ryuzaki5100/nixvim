-- Omarchy-aware colorscheme engine for the "system" theme.
--
-- Reads the active Omarchy palette from the current theme and feeds it to
-- aether.nvim -- the same engine Omarchy generates its Neovim theme from --
-- so every highlight group (syntax, treesitter, LSP, and the plugin
-- integrations: neo-tree, noice, gitsigns, indent-blankline, telescope,
-- which-key, ...) matches the desktop theme instead of falling back to
-- Neovim's stock colours.
--
-- Newer (Aether) themes expose a flat
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

-- first(palette, "key", "alias", fallback) -> first present value wins.
local function first(palette, keys, fallback)
  for _, key in ipairs(keys) do
    if palette[key] then
      return palette[key]
    end
  end
  return fallback
end

-- Translate the Omarchy palette into the exact colour keys aether expects.
local function build_colors(p)
  local bg = first(p, { "background", "bg" }, "#1e1e1e")
  local fg = first(p, { "foreground", "fg" }, "#d4d4d4")
  local red = first(p, { "red", "color1" }, "#ff5555")
  local green = first(p, { "green", "color2" }, "#50fa7b")
  local yellow = first(p, { "yellow", "color3" }, "#f1fa8c")
  local blue = first(p, { "blue", "color4" }, "#61afef")
  local magenta = first(p, { "magenta", "purple", "color5" }, "#c678dd")
  local cyan = first(p, { "cyan", "color6" }, "#56b6c2")
  local orange = first(p, { "orange" }, yellow)
  local brown = first(p, { "brown" }, yellow)
  local bright_fg = first(p, { "bright_foreground", "light_foreground" }, fg)

  return {
    bg = bg,
    dark_bg = first(p, { "dark_background", "darker_background" }, bg),
    darker_bg = first(p, { "darker_background", "dark_background" }, bg),
    lighter_bg = first(p, { "lighter_background", "selection" }, bg),

    fg = fg,
    dark_fg = first(p, { "dark_foreground", "muted" }, fg),
    light_fg = first(p, { "light_foreground", "bright_foreground" }, fg),
    bright_fg = bright_fg,
    muted = first(p, { "muted", "dark_foreground" }, fg),

    red = red,
    yellow = yellow,
    orange = orange,
    green = green,
    cyan = cyan,
    blue = blue,
    magenta = magenta,
    purple = magenta,
    brown = brown,

    bright_red = first(p, { "bright_red" }, red),
    bright_yellow = first(p, { "bright_yellow" }, yellow),
    bright_green = first(p, { "bright_green" }, green),
    bright_cyan = first(p, { "bright_cyan" }, cyan),
    bright_blue = first(p, { "bright_blue" }, blue),
    bright_magenta = first(p, { "bright_magenta", "bright_purple" }, magenta),
    bright_purple = first(p, { "bright_magenta", "bright_purple" }, magenta),

    accent = first(p, { "accent", "blue" }, blue),
    cursor = bright_fg,
    selection = first(p, { "selection", "lighter_background" }, bg),
    selection_foreground = first(p, { "selection_foreground" }, bg),
    selection_background = first(p, { "selection_background", "selection" }, bg),
    background = bg,
    foreground = fg,
  }
end

-- Groups Omarchy clears to transparent in plugin/after/transparency.lua, so
-- the terminal background/wallpaper shows through.
local transparent_groups = {
  "Normal",
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "Terminal",
  "EndOfBuffer",
  "FoldColumn",
  "Folded",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "NormalNC",
  "WhichKeyFloat",
  "TelescopeBorder",
  "TelescopeNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeVertSplit",
  "NeoTreeWinSeparator",
  "NeoTreeEndOfBuffer",
  "NvimTreeNormal",
  "NvimTreeVertSplit",
  "NvimTreeEndOfBuffer",
  "NotifyINFOBody",
  "NotifyERRORBody",
  "NotifyWARNBody",
  "NotifyTRACEBody",
  "NotifyDEBUGBody",
  "NotifyINFOTitle",
  "NotifyERRORTitle",
  "NotifyWARNTitle",
  "NotifyTRACETitle",
  "NotifyDEBUGTitle",
  "NotifyINFOBorder",
  "NotifyERRORBorder",
  "NotifyWARNBorder",
  "NotifyTRACEBorder",
  "NotifyDEBUGBorder",
}

local function make_transparent()
  for _, name in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok then
      hl.bg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

local function apply()
  local palette = read_palette()
  local colors = build_colors(palette)

  vim.o.background = palette.mode == "light" and "light" or "dark"

  -- Configure aether directly (skipping its own hotreload watcher; we run our
  -- own) and apply it under the "system" name.
  require("aether.config").setup({
    name = "system",
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "dark",
      floats = "dark",
    },
    colors = colors,
  })
  require("aether.theme").setup(require("aether.config").extend())

  make_transparent()

  -- Normal is transparent, so nvim-notify's `NotifyBackground -> Normal` link
  -- resolves to no background. Give the opacity backdrop an explicit colour.
  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = colors.bg })

  M.palette = colors
  return colors
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
