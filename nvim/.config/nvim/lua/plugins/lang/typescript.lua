-- TypeScript/JavaScript language configuration
--
-- Handled by extra: lazyvim.plugins.extras.lang.typescript
--   LSP: vtsls (inlay hints, auto-imports, move-to-file refactoring)
--   Formatter: LSP built-in
--   DAP: js-debug-adapter (node, chrome, msedge)
--   Keymaps: gD (source def), gR (file refs), <leader>cM (add imports), <leader>cD (fix all)
--
-- Handled by extra: lazyvim.plugins.extras.linting.eslint
--   Linter: eslint LSP (auto-fix on save)

-- Override: add prettierd for opinionated formatting
return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettierd" } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        javascriptreact = { "prettierd" },
      },
    },
  },
}
