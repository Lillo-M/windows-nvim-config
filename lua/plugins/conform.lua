return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      log_level = vim.log.levels.DEBUG,
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "ruff" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        htmlangular = { "prettierd", "prettier", stop_after_first = true },
        vhdl = { "vsg" },
      },
    })
  end,
}
