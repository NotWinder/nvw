local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
})
require("mason-lspconfig").setup({
    ensure_installed = {},
})
require("mason-lspconfig").setup_handlers({
    lspconfig.bashls.setup({ capabilities = capabilities }),
    lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true,
            },
        },
    }),
    lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
                    return
                end
            end
        end,
    }),
    lspconfig.nixd.setup({
        capabilities = capabilities,
        cmd = { "nixd" },
        settings = {
            nixd = {
                nixpkgs = {
                    expr = "import <nixpkgs> { }",
                },
                formatting = {
                    command = { "alejandra" },
                },
                options = {
                    nixos = {
                        expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options',
                    },
                    home_manager = {
                        expr =
                        '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
                    },
                },
            },
        },
    }),
    lspconfig.pyright.setup({ capabilities = capabilities }),
    lspconfig.jdtls.setup({ capabilities = capabilities }),
    lspconfig.rust_analyzer.setup({ capabilities = capabilities }),
    lspconfig.ts_ls.setup({ capabilities = capabilities }),
    lspconfig.yamlls.setup({ capabilities = capabilities }),
    lspconfig.zls.setup({ capabilities = capabilities }),
})

local augroup = vim.api.nvim_create_augroup
local WinderGroup = augroup("winder", {})
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

autocmd("LspAttach", {
    group = WinderGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover()
        end, opts)
        vim.keymap.set("n", "<leader>vws", function()
            vim.lsp.buf.workspace_symbol()
        end, opts)
        vim.keymap.set("n", "<leader>vd", function()
            vim.diagnostic.open_float()
        end, opts)
        vim.keymap.set("n", "<leader>vca", function()
            vim.lsp.buf.code_action()
        end, opts)
        vim.keymap.set("n", "<leader>vrr", function()
            vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "<leader>vrn", function()
            vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set("i", "<C-h>", function()
            vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.goto_next()
        end, opts)
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.goto_prev()
        end, opts)
    end,
})
