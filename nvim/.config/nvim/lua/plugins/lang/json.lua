-- JSON language configuration
--
-- Handled by extra: lazyvim.plugins.extras.lang.json
--   LSP: jsonls with SchemaStore (auto-schemas for tsconfig, package.json, etc.)
--   Formatter: LSP built-in (json formatting enabled)
--   Validation: LSP built-in
--   Treesitter: json5

-- Override: use prettierd instead of jsonls formatter (jsonls defaults to 4-space indent)
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettierd" },
        jsonc = { "prettierd" },
      },
    },
  },
}
