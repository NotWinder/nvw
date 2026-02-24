AGENTS - Neovim Configuration Repository Guide

Purpose: Guidance for automated agents working in this Neovim configuration repository.
Stack: Lua (Neovim config) + Nix flake (declarative dependencies)
Size: ~1400 lines of Lua across 32 files, organized in modular structure
Version: Neovim 0.12+ (nightly), using modern APIs (vim.lsp.config, vim.lsp.enable)

═══════════════════════════════════════════════════════════════════════════════

1. BUILD / DEV / RUN COMMANDS

Development shell (recommended):
  nix develop                              # Enter shell with all tools available

Build commands:
  nix build .#nvim                         # Build default package (wrapRc=true bakes config)
  nix build .#packages.x86_64-linux.nvim   # Build for specific system

Test build:
  ./result/bin/nvim --version              # Verify build
  ./result/bin/nvim test.lua               # Interactive test

Quick validation:
  nix flake check                          # Validate flake syntax
  stylua --check lua/                      # Check Lua formatting
  alejandra --check flake.nix nix/         # Check Nix formatting

Headless dry-run (use the system nvim, not the built result):
  nvim --headless -u init.lua -c 'qa!'
  nvim --headless -u init.lua -V3/tmp/nvim_startup.log -c 'qa!'

IMPORTANT — wrapRc = true:
  The built package bakes the config into the Nix store at build time.
  When running `nvim --headless -u init.lua` from the repo root, Lua
  modules (require("plugin.on_attach") etc.) resolve via runtimepath to
  the LAST BUILT store path, not the working directory. Always rebuild
  with `nix build .#nvim` to pick up source changes in the built binary.
  Use `nvim --headless -u NORC --cmd 'set rtp+=.' ...` for testing local
  source without a rebuild.

═══════════════════════════════════════════════════════════════════════════════

2. FORMATTING AND LINTING

Lua files:
  stylua <path>                            # Format Lua (project uses TABS)
  stylua --check lua/                      # Check without modifying

Nix files:
  alejandra <file.nix>                     # Format Nix file
  alejandra flake.nix nix/                 # Format all Nix files

In-editor:
  <leader>ff                               # Format current buffer (conform → LSP fallback)

Format-on-save: Enabled via conform.nvim (see lua/plugin/format.lua)
Formatters by filetype: stylua (lua), alejandra (nix), prettier (js/ts/json),
                        ruff_format (python), gofmt (go)

═══════════════════════════════════════════════════════════════════════════════

3. TESTING

No automated test suite exists. Manual validation approaches:

  # Test a module loads without error (local source, no rebuild needed):
  nvim --headless -u NORC --cmd 'set rtp+=.' \
    -c "lua require('lsp'); print('ok')" -c 'qa!'

  # Test LSP attaches to a real file (requires a built result):
  ./result/bin/nvim --headless test.lua \
    -c 'lua vim.defer_fn(function() \
      local c = vim.lsp.get_clients({bufnr=0}); \
      print(#c, "clients"); vim.cmd("qa!") \
    end, 5000)'

  # Run checkhealth and capture output:
  nvim --headless -u init.lua \
    -c 'redir! > /tmp/health.txt | silent checkhealth | redir END' -c 'qa!'

If a test suite is added: use busted under spec/, run with:
  busted                                   # All tests
  busted spec/path/to/test_spec.lua        # Single file
  busted --filter 'pattern' spec/file.lua  # Single test by name

═══════════════════════════════════════════════════════════════════════════════

4. REPOSITORY STRUCTURE

lua/
├── core/                    # Core Neovim settings
│   ├── init.lua             # Loads remap + set
│   ├── remap.lua            # Key remaps
│   └── set.lua              # vim.opt settings
├── lsp/                     # LSP configuration (modular)
│   ├── init.lua             # Orchestrator: loads modules, builds lze specs
│   ├── capabilities.lua     # Client capabilities + blink.cmp integration
│   ├── diagnostics.lua      # Diagnostic signs and display config
│   ├── util.lua             # Python path cache, filetype fallback helper
│   └── servers/             # One file per LSP server
│       ├── init.lua         # Aggregator: returns list of all server specs
│       ├── lua_ls.lua       # Lua   · basedpyright.lua  # Python
│       ├── gopls.lua        # Go    · nixd.lua           # Nix
│       ├── rust_analyzer.lua# Rust  · ts_ls.lua          # TypeScript
│       ├── bashls.lua       # Bash  · yamlls.lua         # YAML
│       ├── zls.lua          # Zig   · qmlls.lua          # QML
│       └── (10 servers total)
├── plugin/                  # Plugin specs loaded by lze
│   ├── init.lua             # Top-level lze.load() calls
│   ├── lsp.lua              # Thin shim: require("lsp")
│   ├── on_attach.lua        # LSP keybindings, inlay hints, codelens
│   ├── completions.lua      # blink.cmp + luasnip + cmp-cmdline
│   ├── copilot.lua          # GitHub Copilot suggestions
│   ├── format.lua           # conform.nvim + format-on-save
│   ├── ai.lua               # avante.nvim (Copilot AI chat)
│   └── general/             # UI and editor plugins
│       ├── init.lua         # Loads oil eagerly, then lze.load() rest
│       ├── oil.lua          # File explorer (replaces netrw)
│       ├── always.lua       # gitsigns, nvim-surround, undotree
│       ├── theme.lua        # tokyonight, lualine, fidget, which-key
│       ├── telescope.lua    # Fuzzy finder + extensions
│       ├── treesitter.lua   # Syntax highlighting + textobjects
│       └── markdown-preview.lua
├── init.lua                 # Entry point: require("core"), require("plugin")

nix/
├── categoryDefinitions.nix  # All plugin/tool categories and their contents
└── packageDefinitions.nix   # Package definitions (nvim, nvim-cc) with enabled categories

mdfiles/                     # Reference documentation (not loaded at runtime)
  LSP_REFACTOR.md, LSP_QUICK_REFERENCE.md, LSP_FIXES.md, LSP_STATUS.md

═══════════════════════════════════════════════════════════════════════════════

5. PLUGIN SYSTEM (lze)

This config uses lze (lazy plugin loader) instead of lazy.nvim.

Plugin spec — all fields:
  {
      "plugin-name",
      for_cat = "category",          -- cosmetic only; HAS NO EFFECT in lze
      enabled = nixCats("cat") or false,  -- REQUIRED for conditional loading
      event = "DeferredUIEnter",     -- trigger: deferred UI event
      ft = { "lua" },                -- trigger: filetype
      cmd = { "Command" },           -- trigger: Ex command
      keys = { "<leader>x" },        -- trigger: keymap
      on_require = { "module" },     -- trigger: require() call
      dep_of = { "other-plugin" },   -- load before another plugin
      on_plugin = { "other-plugin" },-- load when another plugin loads
      load = function(name) ... end, -- custom packadd; wrap with pcall
      before = function(plugin) end, -- runs just before load
      after = function(plugin) end,  -- runs after load (setup goes here)
      lsp = { filetypes={}, settings={} }, -- LSP config (lzextras.lsp handler)
  }

Critical rules:
  - `for_cat` is IGNORED by lze; it documents intent but does nothing.
    Always set `enabled = nixCats("category") or false` explicitly.
  - `after` must be a function, never a string:
      ❌  after = "blink.cmp"
      ✅  after = function(_) require("blink.cmp").setup() end
  - Use `dep_of` / `on_plugin` for load-order dependencies, not `after`.
  - packadd in `load =` must use pcall to avoid "not found in packpath" noise:
      pcall(vim.cmd, "packadd " .. name)

═══════════════════════════════════════════════════════════════════════════════

6. LSP ARCHITECTURE (lua/lsp/)

Adding a new server (10 steps reduced to 2):
  1. Create lua/lsp/servers/my_server.lua:
       return {
           "my_server",
           enabled = nixCats("lsps.my_lang") or false,
           lsp = {
               filetypes = { "mylang" },
               settings = { MyServer = { ... } },
           },
       }
  2. Add require("lsp.servers.my_server") to lua/lsp/servers/init.lua.
  3. Add the language server binary to lspsAndRuntimeDeps.lsps.my_lang
     in nix/categoryDefinitions.nix, then enable it in packageDefinitions.nix.

Key files for global LSP behaviour:
  lua/lsp/capabilities.lua   -- blink.cmp + folding capabilities
  lua/lsp/diagnostics.lua    -- signs, virtual text, float borders
  lua/plugin/on_attach.lua   -- keymaps, inlay hints, codelens
  lua/lsp/util.lua           -- Python venv detection (cached), ft fallback

Neovim 0.12+ LSP APIs used (do not revert to lspconfig-style):
  vim.lsp.config("server", cfg)   -- configure a server
  vim.lsp.enable("server")        -- enable a server
  vim.lsp.codelens.enable(true, { bufnr = bufnr })  -- codelens (refresh() is DEPRECATED)
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

═══════════════════════════════════════════════════════════════════════════════

7. CODING STYLE (LUA)

Formatting:
  - Indentation: TABS (enforced by stylua; run stylua before committing)
  - Line length: 100 columns soft limit
  - Trailing whitespace: none

Naming:
  - snake_case        local variables and functions  (get_python_path)
  - PascalCase        module-level singletons        (nixCats)
  - UPPER_SNAKE_CASE  exported constants

Imports:
  - Top-level: local mod = require("path.to.module")
  - Optional:  local ok, mod = pcall(require, "optional.dep")
  - Check binaries: vim.fn.executable("tool") == 1

Module structure:
  - One responsibility per file
  - local M = {}  …  return M  pattern for API modules
  - Internal helpers stay local; never leak into the module table

EmmyLua annotations (for lua_ls):
  ---@param client lsp.Client
  ---@param bufnr integer
  ---@return boolean

Error handling:
  - pcall for any external require or runtime call that may fail
  - assert only for programmer-invariant checks
  - Return nil, err (not error()) for expected library errors
  - vim.notify(msg, vim.log.levels.WARN) for user-visible warnings
  - No noisy logging in hot paths (on_attach, autocmds)

nixCats usage:
  - nixCats("category.sub") returns the category value or nil
  - Always guard: enabled = nixCats("cat") or false
  - Use nixCats.pawsible({"allPlugins","opt","plugin-name"}) to get
    a plugin's Nix store path for dofile() / path construction

═══════════════════════════════════════════════════════════════════════════════

8. COMMON PATTERNS AND ANTI-PATTERNS

✅ DO:
  - enabled = nixCats("category") or false  on every lze plugin spec
  - pcall(vim.cmd, "packadd " .. name)       safe packadd in load =
  - pcall(require, "optional")               safe optional requires
  - client.server_capabilities.X            check before using LSP features
  - vim.lsp.codelens.enable(true, {bufnr=bufnr})  codelens (nightly API)
  - Cache expensive calls (see get_python_path caching pattern in util.lua)
  - stylua lua/ before committing

❌ DON'T:
  - Rely on for_cat alone to gate a plugin — it does nothing in lze
  - Call vim.lsp.codelens.refresh() — deprecated, removed in 0.13
  - Use after = "string" — lze expects a function
  - vim.cmd.packadd(name) bare — use pcall wrapper
  - Add autocmd-based codelens refresh loops — codelens.enable() handles it
  - Modify flake.nix / nix/*.nix without testing in nix develop
  - Commit without being explicitly asked

═══════════════════════════════════════════════════════════════════════════════

9. NIX / CATEGORY SYSTEM

packageDefinitions.nix defines packages (nvim, nvim-cc) with enabled categories:
  categories = { general = true; lsps = true; completions = true; ... }

categoryDefinitions.nix maps categories to plugins and runtime deps:
  lspsAndRuntimeDeps.lsps.lua = [ lua-language-server stylua ]
  optionalPlugins.lsps.lua    = [ lazydev-nvim ]
  optionalPlugins.completions = [ blink-cmp luasnip ... ]

nixCats resolves nested keys: nixCats("lsps.lua") walks lsps → lua.
nixCats("lua") returns nil if there is no top-level "lua" key — use the
full dotted path matching the nix attribute tree.

Review required (human must check before merge):
  flake.nix, nix/categoryDefinitions.nix, nix/packageDefinitions.nix,
  lua/lsp/init.lua (LSP orchestrator)

═══════════════════════════════════════════════════════════════════════════════

APPENDIX: Quick Reference

  Language       Lua (Neovim config, Neovim 0.12+ nightly)
  Plugin loader  lze + lzextras (not lazy.nvim)
  Formatter      stylua (Lua), alejandra (Nix)
  LSP servers    lua_ls, basedpyright, gopls, nixd, rust_analyzer,
                 ts_ls, bashls, yamlls, zls, qmlls
  Key plugins    conform.nvim, blink.cmp, copilot.lua, avante.nvim,
                 nvim-lspconfig, telescope.nvim, nvim-treesitter, oil.nvim
  Cursor rules   none
  Copilot rules  none
