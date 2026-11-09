vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>gb", "<cmd>BlameToggle<CR>")

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("x", "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)
vim.keymap.set("x", "<leader>c", [["_di]])
vim.keymap.set("x", "<leader>d", [["_d]])
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")
vim.keymap.set("n", "<leader>mk", vim.cmd.MarkdownPreviewToggle)

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ lsp_format = "fallback" })
  local ft = vim.bo.filetype
  local bufnr = vim.api.nvim_get_current_buf()

  -- Call organize imports if it's a TypeScript or TSX file
  if ft == "typescript" or ft == "typescriptreact" then
    local params = {
      command = "_typescript.organizeImports",
      arguments = { vim.api.nvim_buf_get_name(bufnr) },
      title = "",
    }
    vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 500)
  end
end, { desc = "Formatting file..." })

vim.keymap.set("n", "gd", vim.lsp.buf.definition)

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
