# nixvim — Portable Neovim IDE

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos&logoColor=white" alt="NixOS unstable"/>
  <img src="https://img.shields.io/badge/Neovim-0.10+-green?logo=neovim" alt="Neovim 0.10+"/>
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT License"/>
</p>

A fully self-contained, reproducible Neovim configuration built with **[nixvim](https://github.com/nix-community/nixvim)**.  
It bundles its own language servers, compilers, debuggers, and AI assistants — nothing needs to be installed on the host system.

```bash
nix run github:Ryuzaki5100/nixvim
```

---

## Features

### Language Support

| Language | LSP | Formatter | Debugger |
|----------|-----|-----------|----------|
| **C / C++** | `clangd` | `clang-format` | `gdb`, `lldb` |
| **Rust** | `rust-analyzer` | `rustfmt` | `lldb` |
| **Java** | `jdtls` | `google-java-format` | via DAP |
| **Python** | `pyright` | `ruff`, `black` | via DAP |
| **Go** | `gopls` | — | via DAP |
| **TypeScript / JavaScript** | `typescript-language-server`, `vscode-json-ls` | — | via DAP |
| **Nix** | `nil` | `nixfmt` | — |
| **Lua** | `lua-language-server` | `stylua` | — |
| **TOML** | `taplo` | — | — |
| **YAML** | `yaml-language-server` | — | — |
| **Markdown** | `marksman` | — | — |
| **Bash** | `bashls` | — | — |
| **HTML / CSS** | `html`, `cssls` | — | — |

> **Python venv**: pyright is configured to auto-detect a local `./venv/` — no need to manually set the interpreter.

### AI Assistants

- **[OpenCode](https://opencode.ai)** — inline AI coding assistant with smart prompts for ask, explain, fix, review, test, document, optimize, and implement.
- **CodeCompanion** — chat-based AI with **Gemini 2.5 Flash** and **Mistral** (local GGUF) adapters.
- **Copilot** — GitHub Copilot via `copilot.lua` with `copilot-cmp` integration.

### Plugin Highlights

- **Completion** — `nvim-cmp` with LSP, Copilot, LuaSnip (friendly-snippets), path, and buffer sources.
- **Telescope** — fuzzy finder with `fzf-native` and `ui-select` extensions.
- **Treesitter** — syntax highlighting, folding, auto-indent, context, and smart rename.
- **Debugging** — full DAP integration (breakpoints, step, REPL, UI) with `<F5>`-style controls.
- **UI** — `lualine` statusline, `neo-tree` file explorer, `which-key` popups, `noice` cmdline, `notify` notifications, `gitsigns`, `indent-blankline`, and `trouble` diagnostics.
- **Buffer Management** — `cybu` for MRU-based tab switching (`<Tab>` / `<S-Tab>`), `bufferline`.
- **Terminal** — `toggleterm` with floating window (toggle via `<M-x>`).
- **Markdown** — `render-markdown.nvim` for rendered Markdown preview, `peek` HTML preview in Firefox.

### Themes

30+ colorschemes pre-installed — switch at any time with `:colorscheme <name>`:

ayu, bamboo, base16, catppuccin, cyberdream, dracula, everforest, github-theme, gruvbox, kanagawa, melange, modus, monokai-pro, moonfly, nightfox, nord, onedark, oxocarbon, palette, poimandres, rose-pine, solarized-osaka, tokyonight, vague, vscode, and more.

Default: `base16-black-metal-gorgoroth`.

---

## Quick Start

```bash
# Run directly (no clone needed)
nix run github:Ryuzaki5100/nixvim

# Or clone and run locally
git clone git@github.com:Ryuzaki5100/nixvim.git
cd nixvim
nix run .
```

### Development Shell

```bash
nix develop
```

This drops you into a shell with Neovim and all LSP tools on `PATH`, plus convenient aliases:

```bash
vim    # → nvim
vi     # → nvim
```

---

## Project Structure

```
├── flake.nix                  # Flake entry point — Nixvim module + dev tools
├── flake.lock                 # Locked inputs (nixpkgs, nixvim, flake-parts, …)
├── config/
│   ├── default.nix            # Module aggregator (imports plugins + sub-configs)
│   ├── options.nix            # Editor options (leader, number, indent, folding, …)
│   ├── keymaps.nix            # Buffer management keybindings
│   ├── custom-key-bindings.nix# Custom keybindings (insert escapes, neo-tree, cybu)
│   └── bufferline.nix         # Bufferline tab bar
├── plugins/
│   ├── default.nix            # Plugin aggregator
│   ├── completion.nix         # nvim-cmp + luasnip + copilot-cmp
│   ├── lsp.nix                # LSP servers + lspsaga + trouble
│   ├── treesitter.nix         # Treesitter + context + refactor
│   ├── telescope.nix          # Telescope + fzf-native
│   ├── dap.nix                # Debug adapter protocol
│   ├── java.nix               # Java tooling (neotest, conform, jdtls extra)
│   ├── jdtls.nix              # Java LSP (jdtls) with multi-JDK support
│   ├── ui.nix                 # Colorschemes, lualine, neo-tree, which-key, noice, gitsigns
│   ├── terminal.nix           # Toggleterm floating terminal
│   ├── copilot.nix            # Copilot + copilot-chat
│   ├── codecompanion.nix      # AI chat (Gemini + Mistral adapters)
│   ├── opencode.nix           # OpenCode AI assistant
│   ├── cybu.nix               # MRU buffer switcher
│   ├── indentation.nix        # nvim-autopairs
│   ├── HtmlPeek.nix           # Markdown preview in Firefox
│   └── render-markdown.nix    # Rendered Markdown preview
└── README.md
```

---

## Keybindings

### General

| Key | Action |
|-----|--------|
| `<leader>c` | Close buffer |
| `<leader>x` | Save & close buffer |
| `<leader>o` | Close all other buffers |
| `<Tab>` / `<S-Tab>` | Next / previous buffer (MRU) |
| `<leader>e` | Toggle file explorer |

### Insert Mode

| Key | Action |
|-----|--------|
| `jk` | Enter normal mode |
| `kj` | Save file |
| `jl` | Enter command-line mode |

### Navigation

| Key | Action |
|-----|--------|
| `H` / `L` | First / last character of line |
| `<M-x>` | Toggle floating terminal |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Hover documentation |
| `<leader>cr` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cd` | Toggle diagnostics |
| `<leader>cs` | Toggle symbols |
| `[d` / `]d` | Previous / next diagnostic |

### Telescope

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | LSP references |
| `<leader>fs` | LSP document symbols |

### Debugging (DAP)

| Key | Action |
|-----|--------|
| `<F5>` | Continue |
| `<F9>` | Toggle breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>db` | Conditional breakpoint |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last |
| `<leader>du` | Toggle DAP UI |

### AI / OpenCode

| Key | Action |
|-----|--------|
| `<leader>oa` | Ask OpenCode about selection |
| `<leader>os` | Select OpenCode prompt |
| `go` (operator) | Append range to OpenCode |
| `goo` | Append line to OpenCode |
| `<S-C-u>` | Scroll OpenCode output up |
| `<S-C-d>` | Scroll OpenCode output down |

### Java (jdtls)

| Key | Action |
|-----|--------|
| `<leader>lj` | Restart jdtls |
| `<leader>lJ` | Refresh Java project |
| `<leader>lk` | Show jdtls root + active JDK |

---

## Customization

All configuration is declarative Nix. Add or modify files in `config/` and `plugins/`, then rebuild:

```bash
nix run .#  # rebuild and run
nix build . # build without running
```

To add a new plugin, create a file in `plugins/` and register it in `plugins/default.nix`.

---

## Requirements

- [Nix](https://nixos.org/download.html) with flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ]`)
- No host-language tooling required — Neovim, LSPs, compilers, and debuggers are all provided by the flake.

---

## License

MIT
