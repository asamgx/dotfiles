-- Terraform/HCL language configuration
--
-- Handled by extra: lazyvim.plugins.extras.lang.terraform
--   LSP: terraformls (HashiCorp's official terraform-ls)
--   Formatter: terraform_fmt (tf), packer_fmt (hcl) via conform
--   Linter: terraform_validate (nvim-lint)
--   Mason: tflint
--   Plugins: telescope-terraform-doc, telescope-terraform (state browser)
--   Treesitter: terraform, hcl

-- Override: wire tflint into nvim-lint (extra installs it but doesn't enable it)
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        terraform = { "tflint" },
        tf = { "tflint" },
      },
    },
  },
}
