-- Python language configuration
--
-- Handled by extra: lazyvim.plugins.extras.lang.python
--   LSP: pyright + ruff (ruff hover disabled, defers to pyright)
--   Formatter: ruff via LSP (no conform entry by default)
--   DAP: debugpy via nvim-dap-python
--   Plugins: venv-selector.nvim (<leader>cv)
--   Mason: pyright, ruff, debugpy
--   Treesitter: ninja, rst

-- Overrides:
--   - Swap pyright for pyrefly
--   - Explicit conform formatters (ruff_organize_imports + ruff_format)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = false,
        pyrefly = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "pyrefly" } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },
}
