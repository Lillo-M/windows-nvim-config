return {
  "hrsh7th/nvim-cmp",
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      sources = {
        { name = "nvim_lsp" },
        { name = "path" },
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-y>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-Space>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
      }),
      snippet = {
        expand = function(args)
          -- You need a snippet engine for this to work.
          -- Example using luasnip: require('luasnip').lsp_expand(args.body)
          vim.snippet.expand(args.body)
        end,
      },
    })
  end,
}
