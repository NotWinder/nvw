AGENTS - Neovim Configuration Repository Guide

Purpose: Guidance for automated agents working in this Neovim configuration repository.
Stack: Lua (Neovim config), plugin management via lazy.nvim
Size: ~800 lines of Lua across 19 files, organized in a modular structure
Version: Neovim 0.12+ (nightly), using modern APIs (vim.lsp.config, vim.lsp.enable)

═══════════════════════════════════════════════════════════════════════════════

1. BUILD / DEV / RUN COMMANDS

Quick validation:
  stylua --check lua/                      # Check Lua formatting

Headless dry-run:
  nvim --headless -u init.lua -c 'qa!'
  nvim --headless -u init.lua -V3/tmp/nvim_startup.log -c 'qa!'

Test a module loads without error:
  nvim --headless -u init.lua \
    -c "lua require('lsp.capabilities'); print('ok')" -c 'qa!'

Run checkhealth and capture output:
  nvim --headless -u init.lua \
    -c 'redir! > /tmp/health.txt | silent checkhealth | redir END' -c 'qa!'

═══════════════════════════════════════════════════════════════════════════════

2. FORMATTING AND LINTING

Lua files:
  stylua <path>                            # Format Lua (project uses TABS)
  stylua --check lua/                      # Check without modifying

In-editor:
  <leader>ff                               # Format current buffer (conform → LSP fallback)

Format-on-save: Enabled via conform.nvim (see lua/plugins/format.lua)
Formatters by filetype: stylua (lua), alejandra (nix), prettier (js/json),
                        ruff_format (python), gofmt (go)

═══════════════════════════════════════════════════════════════════════════════

3. TESTING

No automated test suite exists. Manual validation:

  # Test a module loads without error:
  nvim --headless -u init.lua \
    -c "lua require('lsp.capabilities'); print('ok')" -c 'qa!'

  # Run checkhealth and capture output:
  nvim --headless -u init.lua \
    -c 'redir! > /tmp/health.txt | silent checkhealth | redir END' -c 'qa!'

═══════════════════════════════════════════════════════════════════════════════

4. REPOSITORY STRUCTURE

lua/
├── config/                  # Core Neovim settings
│   ├── options.lua          # vim.opt settings
│   └── keymaps.lua          # Global key remaps (leader maps, etc.)
├── lsp/                     # LSP configuration (modular)
│   ├── capabilities.lua     # Client capabilities + blink.cmp integration
│   ├── diagnostics.lua      # Diagnostic signs and display config
│   ├── on_attach.lua        # LSP keybindings, inlay hints, codelens
│   └── util.lua             # Python path cache helper
└── plugins/                 # Plugin specs loaded by lazy.nvim
    ├── ai.lua               # avante.nvim (Copilot AI chat)
    ├── completions.lua      # blink.cmp + LuaSnip
    ├── copilot.lua          # GitHub Copilot suggestions
    ├── editor.lua           # nvim-surround, undotree
    ├── format.lua           # conform.nvim + format-on-save
    ├── git.lua              # gitsigns.nvim
    ├── lsp.lua              # LSP server setup (all servers in one file)
    ├── markdown.lua         # markdown-preview.nvim
    ├── oil.lua              # File explorer (replaces netrw)
    ├── telescope.lua        # Fuzzy finder + extensions
    ├── theme.lua            # tokyonight, lualine, fidget, which-key
    └── treesitter.lua       # Syntax highlighting + textobjects

init.lua                     # Entry point: bootstraps lazy.nvim, loads config + plugins
lazy-lock.json               # Locked plugin versions

═══════════════════════════════════════════════════════════════════════════════

5. PLUGIN SYSTEM (lazy.nvim)

This config uses lazy.nvim for plugin management. init.lua bootstraps it and
loads all plugin specs from lua/plugins/ via `{ import = "plugins" }`.

Each file under lua/plugins/ returns a table (or list of tables) conforming to
the lazy.nvim plugin spec.

Key lazy.nvim spec fields:
  {
      "author/plugin-name",
      lazy = true,               -- defer loading (default for most plugins)
      lazy = false,              -- eager load (e.g. colorscheme, oil)
      priority = 1000,           -- load order for eager plugins
      event = "VeryLazy",        -- trigger: deferred UI event
      event = { "BufReadPre" },  -- trigger: autocmd event
      ft = { "lua" },            -- trigger: filetype
      cmd = { "Command" },       -- trigger: Ex command
      keys = { "<leader>x" },    -- trigger: keymap
      dependencies = { ... },    -- other plugins to load first
      opts = { ... },            -- passed directly to plugin.setup()
      config = function() end,   -- custom setup (use when opts isn't enough)
      build = "make",            -- build command run after install/update
      init = function() end,     -- runs at startup regardless of lazy state
  }

Colorscheme:
  - tokyonight is the active colorscheme (lua/plugins/theme.lua)
  - It uses lazy = false and priority = 1000 to ensure it loads first

═══════════════════════════════════════════════════════════════════════════════

6. LSP ARCHITECTURE (lua/lsp/ + lua/plugins/lsp.lua)

All LSP server configuration lives in lua/plugins/lsp.lua.
Servers are enabled when their binary is present on PATH (vim.fn.executable).

Neovim 0.12+ LSP APIs used (do not revert to lspconfig-style setup()):
  vim.lsp.config("server", cfg)   -- configure a server
  vim.lsp.enable("server")        -- enable a server
  vim.lsp.config("*", { ... })    -- set global defaults for all servers
  vim.lsp.codelens.enable(true, { bufnr = bufnr })  -- codelens
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) -- inlay hints

Key files for global LSP behaviour:
  lua/lsp/capabilities.lua   -- blink.cmp + folding capabilities
  lua/lsp/diagnostics.lua    -- signs (via vim.diagnostic.config signs.text),
                                 virtual text, float borders
  lua/lsp/on_attach.lua      -- keymaps, inlay hints, codelens
  lua/lsp/util.lua           -- Python venv detection (cached)

Currently configured servers (all in lua/plugins/lsp.lua):
  lua_ls, basedpyright, gopls, nixd, rust_analyzer,
  ts_ls, bashls, yamlls, zls, qmlls

Adding a new server:
  Add a new `if has("binary-name")` block in lua/plugins/lsp.lua
  calling vim.lsp.config("server_name", { ... }) and vim.lsp.enable("server_name").

═══════════════════════════════════════════════════════════════════════════════

7. CODING STYLE (LUA)

Formatting:
  - Indentation: TABS (enforced by stylua; run stylua before committing)
  - Line length: 100 columns soft limit
  - Trailing whitespace: none

Naming:
  - snake_case        local variables and functions
  - PascalCase        module-level singletons / constructors
  - UPPER_SNAKE_CASE  exported constants

Imports:
  - Top-level: local mod = require("path.to.module")
  - Optional:  local ok, mod = pcall(require, "optional.dep")
  - Check binaries: vim.fn.executable("tool") == 1

Module structure:
  - One responsibility per file
  - local M = {}  …  return M  pattern for API modules
  - Internal helpers stay local; never leak into the module table

Error handling:
  - pcall for any external require that may fail at the call site:
      pcall(function() require("mod").method() end)   -- correct
      pcall(require("mod").method)                    -- WRONG: require runs before pcall
  - Return nil, err (not error()) for expected library errors
  - vim.notify(msg, vim.log.levels.WARN) for user-visible warnings
  - No noisy logging in hot paths (on_attach, autocmds)

═══════════════════════════════════════════════════════════════════════════════

8. COMMON PATTERNS AND ANTI-PATTERNS

DO:
  - pcall(function() require("mod").method() end)    -- safe optional call
  - local ok, mod = pcall(require, "mod")            -- safe optional require
  - client.server_capabilities.X                     -- check before using LSP features
  - vim.lsp.codelens.enable(true, {bufnr=bufnr})     -- codelens (nightly API)
  - vim.diagnostic.config({ signs = { text = { ... } } })  -- modern sign API
  - conform lsp_format = "fallback"                  -- current conform API
  - vim.fn.expand("~")                               -- safe home dir expansion
  - stylua lua/ before committing

DO NOT:
  - pcall(require("mod").method, arg)  -- require() evaluates before pcall catches it
  - vim.lsp.codelens.refresh()         -- deprecated, removed in 0.13
  - vim.fn.sign_define for diagnostic signs  -- deprecated in Neovim 0.10+
  - lsp_fallback = true in conform     -- deprecated, use lsp_format = "fallback"
  - os.getenv("HOME") without nil check -- use vim.fn.expand("~") instead
  - Commit without being explicitly asked

═══════════════════════════════════════════════════════════════════════════════

9. KEY MAPPINGS REFERENCE

Notable global maps (lua/config/keymaps.lua):
  <leader>pv        Open Oil file explorer
  <leader>y / Y     Yank to system clipboard
  <leader>D         Delete to black hole register (n/v)
  <leader>p         Paste from black hole (x mode, preserves register)
  <leader>sr        Search/replace word under cursor (:%s/...)
  <leader>x         chmod +x current file
  <leader><leader>  Source current file (:so)
  ]q / [q           Quickfix next/prev
  <leader>k / j     Loclist next/prev
  <C-f>             Open tmux sessionizer

LSP maps (lua/lsp/on_attach.lua, buffer-local):
  gd                Go to definition
  gr                References (telescope)
  gI                Implementations (telescope)
  gD                Declaration
  K                 Hover documentation
  <C-k>             Signature help
  <leader>vrn       Rename
  <leader>vca       Code action
  <leader>ds        Document symbols (telescope)
  <leader>ws        Workspace symbols (telescope)
  <leader>D         Type definition
  <leader>ih        Toggle inlay hints
  <leader>cl        Run codelens
  <leader>vd        View diagnostics for current line
  <leader>vrr       LSP references (native)
  [d / ]d           Jump to prev/next diagnostic

═══════════════════════════════════════════════════════════════════════════════

APPENDIX: Quick Reference

  Language       Lua (Neovim config, Neovim 0.12+ nightly)
  Plugin loader  lazy.nvim
  Lockfile       lazy-lock.json
  Formatter      stylua (Lua)
  Colorscheme    tokyonight (storm, transparent)
  LSP servers    lua_ls, basedpyright, gopls, nixd, rust_analyzer,
                 ts_ls, bashls, yamlls, zls, qmlls
  Key plugins    conform.nvim, blink.cmp, copilot.lua, avante.nvim,
                 nvim-lspconfig, telescope.nvim, nvim-treesitter, oil.nvim,
                 gitsigns.nvim, which-key.nvim, lualine.nvim
