# LSP Quick Reference

## File Location Guide

```
lua/lsp/
├── init.lua              → Main entry point (orchestrates everything)
├── capabilities.lua      → LSP capabilities (completion, folding, etc.)
├── diagnostics.lua       → Error/warning display config & signs
├── util.lua              → Helper functions (Python path, filetype fallback)
└── servers/
    ├── init.lua          → Server list aggregator
    └── <server>.lua      → Individual LSP configurations
```

## Common Tasks

### View Current Config
```vim
:e lua/lsp/init.lua              " See how everything connects
:e lua/lsp/servers/init.lua      " See all enabled servers
:e lua/lsp/servers/lua_ls.lua    " See specific server config
```

### Add New LSP Server
1. Create `lua/lsp/servers/my_server.lua`:
   ```lua
   return {
       "my_server",
       enabled = nixCats("lsps.my_lang") or false,
       lsp = {
           filetypes = { "mylang" },
           settings = { ... },
       },
   }
   ```

2. Register in `lua/lsp/servers/init.lua`:
   ```lua
   require("lsp.servers.my_server"),
   ```

### Modify Global Settings
- **Capabilities:** `lua/lsp/capabilities.lua:9`
- **Diagnostics:** `lua/lsp/diagnostics.lua:6`
- **Keybindings:** `lua/plugin/on_attach.lua:5`

### Debug LSP Issues
```vim
:lua vim.print(vim.lsp.get_clients())                 " Active LSP clients
:lua vim.print(require("lsp.capabilities").make())    " Check capabilities
:LspInfo                                              " Built-in LSP info
:LspLog                                               " View LSP logs
```

## New Keybindings

| Key | Action | Added In |
|-----|--------|----------|
| `<leader>ih` | Toggle inlay hints | on_attach.lua:91 |
| `<leader>cl` | Run codelens | on_attach.lua:103 |
| `:Format` | Format with conform/LSP | on_attach.lua:65 |

## Files Changed Summary

| File | Before | After | Change |
|------|--------|-------|--------|
| `lua/plugin/lsp.lua` | 265 lines | 4 lines | Refactored into modules |
| `lua/plugin/on_attach.lua` | 66 lines | 111 lines | Added document highlight, inlay hints, codelens |
| `lua/plugin/format.lua` | 39 lines | 41 lines | Added explicit `lsp_fallback` and timeout |

**New files:** 14 (lua/lsp/ directory)

## Build & Test

```bash
# Build the configuration
nix build .#nvim

# Enter dev environment
nix develop

# Format Lua files
stylua lua/

# Format Nix files
alejandra flake.nix nix/
```

## Feature Summary

### Fixed Issues
- ✅ Added LSP capabilities for blink.cmp integration
- ✅ Removed redundant basedpyright config
- ✅ Fixed ts_ls filetypes (javascript, typescript, etc.)
- ✅ Fixed bashls to trigger on 'sh' filetype
- ✅ Added explicit blink.cmp dependency
- ✅ Cached Python path lookups for performance
- ✅ Unified format-on-save strategy

### New Features
- ✅ Document highlighting (highlights symbol under cursor)
- ✅ Inlay hints support (shows types, parameter names inline)
- ✅ CodeLens support (actionable code annotations)
- ✅ Modular architecture for easy maintenance

### Architecture Improvements
- ✅ Split 265-line file into 15 focused modules
- ✅ Each LSP server in its own file
- ✅ Utilities reusable across config
- ✅ Clear separation of concerns
- ✅ Easy to navigate and modify

## Rollback (If Needed)

The original `lua/plugin/lsp.lua` is replaced. To rollback:

```bash
git restore lua/plugin/lsp.lua
rm -rf lua/lsp/
```

Or keep both temporarily:
```bash
mv lua/plugin/lsp.lua lua/plugin/lsp.lua.new
git restore lua/plugin/lsp.lua
# Test original, then swap back when ready
```

## Support

- Full refactor details: `LSP_REFACTOR.md`
- Repository guidelines: `AGENTS.md`
- Neovim LSP docs: `:help lsp`
- nixCats docs: https://github.com/BirdeeHub/nixCats-nvim
