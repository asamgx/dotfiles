-- Shell/Bash language configuration
--
-- Handled by extra: lazyvim.plugins.extras.util.dot
--   Enables dotfile-related language support
--
-- Not covered by any extra — explicit config below:
--   LSP: bashls
--   Formatter: shfmt (conform)
--   Linter: shellcheck (nvim-lint)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "bash-language-server", "shfmt", "shellcheck" } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },
}
