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
  nix build .#nvim                         # Build default package
  nix build .#packages.x86_64-linux.nvim   # Build for specific system
  
Test build:
  ./result/bin/nvim --version              # Verify build
  ./result/bin/nvim test.lua               # Test with a file

Quick validation:
  nix flake check                          # Validate flake syntax
  stylua --check lua/                      # Check Lua formatting
  alejandra --check flake.nix nix/         # Check Nix formatting

═══════════════════════════════════════════════════════════════════════════════

2. FORMATTING AND LINTING

Lua files:
  stylua <path>                            # Format Lua (project uses TABS)
  stylua --check lua/                      # Check without modifying

Nix files:
  alejandra <file.nix>                     # Format Nix file
  alejandra flake.nix nix/                 # Format all Nix files

Other languages (via conform.nvim):
  prettier --write <file>                  # JS/TS/JSON
  ruff format <path>                       # Python
  gofmt -w <path>                          # Go

In-editor:
  <leader>ff                               # Format current buffer in Neovim

Format-on-save: Enabled via conform.nvim (see lua/plugin/format.lua)

═══════════════════════════════════════════════════════════════════════════════

3. TESTING

Current state: No test suite exists yet

Recommended setup (if adding tests):
  Framework: busted (Lua unit test framework)
  Location: spec/ directory
  
Commands (once busted is added):
  busted                                   # Run all tests
  busted spec/path/to/test_spec.lua        # Run single file
  busted --filter 'pattern' spec/file.lua  # Run specific test by name

Alternative: luatest (document if you use this instead)

Manual testing:
  ./result/bin/nvim --headless +"lua require('lsp')" +quit   # Test module loads
  ./result/bin/nvim test.lua               # Interactive test

═══════════════════════════════════════════════════════════════════════════════

4. REPOSITORY STRUCTURE

lua/
├── core/                    # Core Neovim settings (remap, set)
├── lsp/                     # LSP configuration (modular)
│   ├── init.lua             # Main orchestrator (loads all modules)
│   ├── capabilities.lua     # LSP capabilities + blink.cmp integration
│   ├── diagnostics.lua      # Diagnostic display configuration
│   ├── util.lua             # Helpers (Python path detection, filetype fallback)
│   └── servers/             # Individual LSP server configs
│       ├── init.lua         # Server aggregator
│       ├── lua_ls.lua       # Lua LSP
│       ├── basedpyright.lua # Python LSP
│       ├── gopls.lua        # Go LSP
│       ├── nixd.lua         # Nix LSP
│       └── ... (11 servers total)
├── plugin/                  # Plugin specifications (loaded by lze)
│   ├── lsp.lua              # LSP loader (minimal, loads lua/lsp/)
│   ├── on_attach.lua        # LSP keybindings + features
│   ├── format.lua           # Format-on-save configuration
│   ├── completions.lua      # blink.cmp setup
│   ├── copilot.lua          # GitHub Copilot integration
│   └── general/             # UI plugins, themes, etc.
└── init.lua                 # Entry point

nix/
├── categoryDefinitions.nix  # Plugin and tool categories
└── packageDefinitions.nix   # Package definitions

═══════════════════════════════════════════════════════════════════════════════

5. LSP-SPECIFIC GUIDELINES (lua/lsp/)

The LSP configuration uses a modular architecture. When working with LSP:

Adding a new LSP server:
  1. Create lua/lsp/servers/my_server.lua:
     return {
         "my_server",
         enabled = nixCats("lsps.my_lang") or false,
         lsp = {
             filetypes = { "mylang" },
             settings = { ... },
         },
     }
  2. Add to lua/lsp/servers/init.lua:
     require("lsp.servers.my_server"),

Modifying global LSP behavior:
  - Capabilities: lua/lsp/capabilities.lua
  - Diagnostics: lua/lsp/diagnostics.lua
  - Keybindings: lua/plugin/on_attach.lua
  - Utilities: lua/lsp/util.lua

Important patterns:
  - Use pcall for optional dependencies: pcall(require, "blink.cmp")
  - Check server capabilities before using features: client.server_capabilities.X
  - Cache expensive operations (see get_python_path in util.lua)

Documentation:
  - LSP_REFACTOR.md: Full refactor details
  - LSP_QUICK_REFERENCE.md: Quick reference for common tasks
  - LSP_FIXES.md: Known issues and troubleshooting

═══════════════════════════════════════════════════════════════════════════════

6. CODING STYLE GUIDELINES (LUA)

General:
  - Keep modules small and focused: one primary responsibility per file
  - Prefer `local` for all variables and functions unless exporting a module API
  - Files in lua/ should return tables or functions only when intended as modules

Formatting:
  - Use TABS for indentation (existing style)
  - Line length: aim for 100 columns (soft limit)
  - Use stylua to format Lua files

Imports / requires:
  - Use `local mod = require("path.to.module")` for imports
  - Wrap in pcall if require may fail: `local ok, mod = pcall(require, "optional")`
  - Check for optional tools: `vim.fn.executable("tool") == 1`

Naming conventions:
  - snake_case: local functions and variables (get_python_path, venv_paths)
  - CamelCase/PascalCase: module-level singletons (nixCats)
  - UPPER_SNAKE_CASE: constants exposed across modules

Module structure:
  - One module per file under lua/
  - Return a table of public functions when exposing an API
  - Keep internal helpers local

Types and annotations:
  - Use EmmyLua-style annotations for complex functions:
    ---@param client lsp.Client
    ---@param bufnr number
    ---@return boolean
  - Helps lua_ls and other readers

Error handling:
  - Use pcall for external requires or runtime calls that may fail
  - Use assert for programmer invariant checks only
  - Return nil, err for expected runtime errors in library functions
  - Use vim.notify or vim.api.nvim_err_writeln for user-facing errors

Logging / diagnostics:
  - Use vim.notify(msg, vim.log.levels.WARN) for notable issues
  - Avoid noisy logging in normal code paths
  - Use debug/trace guards for verbose output

Concurrency / async:
  - Respect Neovim event loop
  - Use vim.defer_fn, coroutines, or plugin async APIs

Tests:
  - Add tests under spec/ or tests/
  - Make tests deterministic (use nix develop for reproducibility)
  - Document test runner in this file and README

═══════════════════════════════════════════════════════════════════════════════

7. PLUGIN SYSTEM (lze)

This config uses lze (lazy plugin loader) instead of lazy.nvim.

Plugin spec structure:
  {
      "plugin-name",
      for_cat = "category",          # Category from nix/categoryDefinitions.nix
      enabled = nixCats("cat") or false,
      event = "DeferredUIEnter",     # Trigger event
      ft = { "lua", "python" },      # Filetypes
      cmd = { "Command" },           # Commands
      keys = { "<leader>x" },        # Keybindings
      on_require = { "module" },     # Load on require
      dep_of = { "other-plugin" },   # Dependency
      after = function(plugin)       # Callback after load (NOT a dependency!)
          require("plugin").setup({})
      end,
      lsp = { ... },                 # LSP config (for lsp handler)
  }

CRITICAL: `after` is a callback function, NOT a dependency declaration
  - ❌ WRONG: after = "blink.cmp"
  - ✅ RIGHT: after = function(_) require("plugin").setup() end
  - Use dep_of or on_plugin for dependencies

═══════════════════════════════════════════════════════════════════════════════

8. GIT / COMMIT GUIDANCE

- Do NOT create commits unless explicitly requested
- If asked to commit:
  - Use short imperative summary (e.g., "Add Rust LSP support")
  - Include 1-2 sentence body describing why
  - Follow existing commit style
- NEVER force-push or amend pushed commits unless user explicitly instructs

═══════════════════════════════════════════════════════════════════════════════

9. SAFETY AND REVIEW EXPECTATIONS

- Generated code is allowed but must be reviewed by a human when touching:
  - flake.nix or nix/*.nix files
  - Plugin lists in nix/categoryDefinitions.nix
  - Core LSP orchestration (lua/lsp/init.lua)

- When adding dependencies:
  - Add to devShells first in flake.nix
  - Test in `nix develop` environment
  - Verify build with `nix build .#nvim`

═══════════════════════════════════════════════════════════════════════════════

10. COMMON PATTERNS AND ANTI-PATTERNS

✅ DO:
  - Use pcall for optional requires
  - Check capabilities before using LSP features
  - Cache expensive operations (filesystem, external calls)
  - Keep modules focused and single-purpose
  - Use vim.notify for user-facing messages
  - Format code with stylua before committing

❌ DON'T:
  - Use after = "string" in lze plugin specs (it expects a function)
  - Require modules without checking if they exist
  - Add noisy logging to normal code paths
  - Create commits without being asked
  - Modify flake.nix without testing in nix develop
  - Use deprecated Neovim APIs (check :help api-changes)

═══════════════════════════════════════════════════════════════════════════════

APPENDIX: Quick Reference

Language: Lua (Neovim config)
Plugin manager: lze (lazy plugin loader)
Tooling: Nix flake, stylua, alejandra, prettier, ruff, gofmt
LSP servers: lua_ls, basedpyright, gopls, nixd, rust_analyzer, ts_ls, bashls, yamlls, zls, qmlls, qmlls
Plugins: conform.nvim (formatting), blink.cmp (completion), copilot.lua, nvim-lspconfig, telescope, treesitter
Cursor rules: none found
Copilot instructions: none found

Recent changes:
  - LSP configuration refactored into modular structure (lua/lsp/)
  - Document highlighting, inlay hints, codelens support added
  - Python path detection now cached per-directory
  - Format-on-save unified (conform → LSP fallback)
