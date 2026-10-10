-- Ghostty-aware colorscheme engine for the "ghostty" theme.
--
-- When Neovim runs inside Ghostty this colorscheme mirrors the terminal
-- exactly: the background, foreground and full 16-colour ANSI palette are read
-- from `ghostty +show-config` (falling back to the config/theme files on disk)
-- and fed to aether.nvim -- the same engine the "system" theme uses -- so
-- syntax, treesitter, LSP and the plugin integrations all use the terminal's
-- own colours instead of Neovim's stock palette.
--
-- The background is deliberately transparent (see make_transparent): Ghostty
-- already applies `background-opacity` / `background-blur` to the window, so
-- leaving Neovim's background clear makes the editor inherit the terminal's
-- exact transparency level rather than painting an opaque rectangle over it.
--
-- A lightweight watcher re-reads the palette whenever the Ghostty theme or
-- config changes, so `ghostty-set-theme` (or tweaking background-opacity) is
-- reflected in a running Neovim without a restart.

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

local function config_dir()
  local xdg = vim.env.XDG_CONFIG_HOME
  if xdg and xdg ~= "" then
    return xdg .. "/ghostty"
  end
  return (vim.env.HOME or "~") .. "/.config/ghostty"
end

local function config_path()
  return config_dir() .. "/config"
end

local function theme_override_path()
  -- Written by `ghostty-set-theme`; takes precedence over the managed config.
  return state_dir() .. "/ghostty/theme.ghostty"
end

local function resources_dir()
  local r = vim.env.GHOSTTY_RESOURCES_DIR
  if r and r ~= "" then
    return r
  end
  return nil
end

-- Locate the ghostty CLI: PATH first, then the well-known bundle locations.
local function find_bin()
  local exe = vim.fn.exepath("ghostty")
  if exe and exe ~= "" then
    return exe
  end

  local candidates = {}
  if vim.env.GHOSTTY_BIN_DIR and vim.env.GHOSTTY_BIN_DIR ~= "" then
    table.insert(candidates, vim.env.GHOSTTY_BIN_DIR .. "/ghostty")
  end
  table.insert(candidates, "/Applications/Ghostty.app/Contents/MacOS/ghostty")
  table.insert(
    candidates,
    (vim.env.HOME or "") .. "/Applications/Home Manager Apps/Ghostty.app/Contents/MacOS/ghostty"
  )
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

local function norm(color)
  if not color then
    return nil
  end
  color = vim.trim(color)
  if color == "" then
    return nil
  end
  if color:sub(1, 1) ~= "#" then
    color = "#" .. color
  end
  return color
end

-- `ghostty +show-config` (and theme files) share a flat `key = value` shape:
--   background = #000000
--   foreground = #c1c1c1
--   palette = 0=#000000
--   background-opacity = 0.7
local function parse_kv(text)
  local out = { ansi = {} }
  for line in text:gmatch("[^\r\n]+") do
    local key, value = line:match("^%s*([%w_%-]+)%s*=%s*(.-)%s*$")
    if key then
      if key == "background" then
        out.bg = value
      elseif key == "foreground" then
        out.fg = value
      elseif key == "theme" then
        out.theme = value
      elseif key == "background-opacity" then
        out.opacity = tonumber(value)
      elseif key == "palette" then
        local idx, color = value:match("^(%d+)=(.+)$")
        idx = tonumber(idx)
        if idx and idx >= 0 and idx <= 15 then
          out.ansi[idx] = color
        end
      end
    end
  end
  return out
end

-- Resolved palette straight from the running Ghostty (handles every layer of
-- config precedence for us). Returns nil when the CLI is unavailable/failing.
local function read_cli()
  local bin = find_bin()
  if not bin then
    return nil
  end

  if vim.system then
    local ok, res = pcall(function()
      return vim.system({ bin, "+show-config" }, { text = true }):wait()
    end)
    if ok and res and res.code == 0 and res.stdout and res.stdout ~= "" then
      return parse_kv(res.stdout)
    end
  end

  local out = vim.fn.system({ bin, "+show-config" })
  if vim.v.shell_error == 0 and out and out ~= "" then
    return parse_kv(out)
  end
  return nil
end

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local data = fd:read("*a")
  fd:close()
  return data
end

local function theme_file_path(name)
  if not name or name == "" then
    return nil
  end
  local candidates = { config_dir() .. "/themes/" .. name }
  local res = resources_dir()
  if res then
    table.insert(candidates, res .. "/themes/" .. name)
  end
  for _, candidate in ipairs(candidates) do
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

-- Fallback: reconstruct the active palette from the on-disk config, the
-- runtime theme override, and the selected theme's colour file.
local function read_files()
  local out = { ansi = {} }

  local function merge(t)
    if not t then
      return
    end
    out.bg = t.bg or out.bg
    out.fg = t.fg or out.fg
    out.opacity = t.opacity or out.opacity
    out.theme = t.theme or out.theme
    for idx, color in pairs(t.ansi) do
      out.ansi[idx] = color
    end
  end

  merge(parse_kv(read_file(config_path()) or ""))
  merge(parse_kv(read_file(theme_override_path()) or ""))
  local theme_file = theme_file_path(out.theme)
  if theme_file then
    merge(parse_kv(read_file(theme_file) or ""))
  end

  if not out.bg and next(out.ansi) == nil then
    return nil
  end
  return out
end

local function read_palette()
  local palette = read_cli()
  if not palette or (not palette.bg and next(palette.ansi or {}) == nil) then
    palette = read_files()
  end
  return palette or { ansi = {} }
end

-- Perceived luminance, used to decide whether the terminal theme is light or
-- dark (Ghostty's resolved config does not report a mode).
local function luminance(hex)
  hex = (hex or "#000000"):gsub("#", "")
  local r = (tonumber(hex:sub(1, 2), 16) or 0) / 255
  local g = (tonumber(hex:sub(3, 4), 16) or 0) / 255
  local b = (tonumber(hex:sub(5, 6), 16) or 0) / 255
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

-- Translate the Ghostty palette into the exact colour keys aether expects.
local function build_colors(p)
  local bg = norm(p.bg) or "#1e1e1e"
  local fg = norm(p.fg) or "#d4d4d4"

  local function ansi(idx, fallback)
    return norm(p.ansi[idx]) or fallback
  end

  local red = ansi(1, "#ff5555")
  local green = ansi(2, "#50fa7b")
  local yellow = ansi(3, "#f1fa8c")
  local blue = ansi(4, "#61afef")
  local magenta = ansi(5, "#c678dd")
  local cyan = ansi(6, "#56b6c2")
  local muted = ansi(8, fg)

  return {
    bg = bg,
    dark_bg = bg,
    darker_bg = bg,
    lighter_bg = ansi(8, bg),

    fg = fg,
    dark_fg = muted,
    light_fg = fg,
    bright_fg = fg,
    muted = muted,

    red = red,
    yellow = yellow,
    orange = yellow,
    green = green,
    cyan = cyan,
    blue = blue,
    magenta = magenta,
    purple = magenta,
    brown = yellow,

    bright_red = ansi(9, red),
    bright_yellow = ansi(11, yellow),
    bright_green = ansi(10, green),
    bright_cyan = ansi(14, cyan),
    bright_blue = ansi(12, blue),
    bright_magenta = ansi(13, magenta),
    bright_purple = ansi(13, magenta),

    accent = blue,
    cursor = fg,
    selection = muted,
    selection_foreground = bg,
    selection_background = muted,
    background = bg,
    foreground = fg,
  }
end

-- Groups cleared so the terminal background/blur shows through. Identical to
-- the "system" engine's list, so both themes are transparent in the same way.
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

  vim.o.background = luminance(palette.bg or colors.bg) > 0.5 and "light" or "dark"

  require("aether.config").setup({
    name = "ghostty",
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
  M.theme_name = palette.theme
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

-- Fingerprint the main config, the runtime theme override and the resolved
-- theme file; a change in any of them re-reads the palette. fs_stat follows
-- symlinks, so a `home-manager switch` that repoints the config is caught too.
local function signature()
  return table.concat({
    file_signature(config_path()),
    file_signature(theme_override_path()),
    file_signature(theme_file_path(M.theme_name) or ""),
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
      -- Only follow the terminal while "ghostty" is the active colorscheme.
      if vim.g.colors_name ~= "ghostty" then
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

function M.in_ghostty()
  return vim.env.TERM_PROGRAM == "ghostty" or (vim.env.GHOSTTY_RESOURCES_DIR or "") ~= ""
end

-- Pick the default colorscheme at startup: mirror Ghostty when running inside
-- it, otherwise fall back to the build-time theme. Set NVIM_GHOSTTY_MATCH=0 to
-- opt out (e.g. to keep the Omarchy `system` theme in a Ghostty terminal).
function M.setup_default(default)
  if M.in_ghostty() and vim.env.NVIM_GHOSTTY_MATCH ~= "0" then
    if pcall(vim.cmd.colorscheme, "ghostty") then
      return
    end
  end
  pcall(vim.cmd.colorscheme, default)
end

function M.load()
  apply()
  watch()
end

function M.apply()
  apply()
end

return M
