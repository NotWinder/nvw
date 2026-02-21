# LSP Refactor - Known Issues & Fixes

## Issue: "attempt to call a string value" Error

### Cause
The original refactor included `after = "blink.cmp"` in the nvim-lspconfig spec (lua/lsp/init.lua:21). 

In lze, the `after` parameter expects a **function** (callback after plugin loads), not a string (plugin name for dependency).

### Fix Applied
**File:** `lua/lsp/init.lua:16-34`

**Before:**
```lua
{
    "nvim-lspconfig",
    for_cat = "general.core",
    on_require = { "lspconfig" },
    after = "blink.cmp",  -- ❌ WRONG: lze interprets this as a function
    ...
}
```

**After:**
```lua
{
    "nvim-lspconfig",
    for_cat = "general.core",
    on_require = { "lspconfig" },
    -- Removed `after` dependency - capabilities.make() handles blink.cmp with pcall
    ...
}
```

### Why This Works
The `lua/lsp/capabilities.lua:10` module already uses `pcall(require, "blink.cmp")` to safely handle cases where blink.cmp isn't loaded yet:

```lua
function M.make()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    
    -- Safe: uses pcall to check if blink.cmp is available
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
        local blink_caps = blink.get_lsp_capabilities()
        if blink_caps then
            capabilities = vim.tbl_deep_extend("force", capabilities, blink_caps)
        end
    end
    
    return capabilities
end
```

This means:
- ✅ If blink.cmp loads first → capabilities include completion metadata
- ✅ If LSP loads first → capabilities use defaults, blink.cmp still works
- ✅ No race condition errors

## Issue: Codelens Deprecation Warning

### Cause
Neovim 0.12 deprecated the `vim.lsp.codelens.refresh({ bufnr = bufnr })` API in favor of `vim.lsp.codelens.refresh()` without arguments.

### Fix Applied
**File:** `lua/plugin/on_attach.lua:98-113`

**Before:**
```lua
if client.server_capabilities.codeLensProvider then
    vim.lsp.codelens.refresh({ bufnr = bufnr })  -- ❌ Deprecated
    ...
end
```

**After:**
```lua
if client.server_capabilities.codeLensProvider and vim.lsp.codelens then
    vim.lsp.codelens.refresh()  -- ✅ Modern API (no arguments)
    
    local codelens_group = vim.api.nvim_create_augroup("lsp_codelens_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = bufnr,
        group = codelens_group,
        callback = function()
            vim.lsp.codelens.refresh()  -- ✅ No bufnr argument
        end,
    })
    ...
end
```

## Testing

### Verify the Fix
```bash
# Rebuild
nix build .#nvim

# Test with a Lua file
echo 'print("hello")' > /tmp/test.lua
./result/bin/nvim /tmp/test.lua
```

### Expected Behavior
- ✅ No "attempt to call a string value" error
- ✅ No codelens deprecation warnings
- ✅ LSP attaches successfully (check with `:LspInfo`)
- ✅ Completions work (start typing and trigger `<C-space>`)
- ✅ Inlay hints appear (if supported by LSP)

### Debug Commands
```vim
:LspInfo                                           " Check active LSPs
:lua vim.print(vim.lsp.get_clients())             " List all clients
:lua vim.print(require("lsp.capabilities").make()) " Verify capabilities
:messages                                          " Check for errors
```

## Rollback Instructions

If issues persist:

```bash
# Restore original monolithic file
git restore lua/plugin/lsp.lua lua/plugin/on_attach.lua

# Remove new modular structure
rm -rf lua/lsp/

# Rebuild
nix build .#nvim
```

## Additional Notes

### blink.cmp Integration
The refactor ensures blink.cmp capabilities are properly integrated:
- Completion items receive full LSP metadata
- Snippets are properly expanded
- Documentation appears in completion menu

### Performance
- Python path detection is now cached per-directory
- Modular loading reduces initial parse time
- No race conditions with lazy-loaded plugins

## Report Issues

If you encounter other errors:
1. Check `:messages` for full error trace
2. Run `:LspInfo` to see which servers are active
3. Test with minimal config: `nvim --clean -u lua/plugin/lsp.lua`
4. Share the full error message including stack trace
