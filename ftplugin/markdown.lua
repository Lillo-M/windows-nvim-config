if vim.bo.buftype ~= "" then
  return
end
require("otter").activate()
require("quarto").activate()
vim.treesitter.start()
