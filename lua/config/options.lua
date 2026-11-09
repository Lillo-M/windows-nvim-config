vim.cmd("filetype plugin on")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.spelllang = { "en", "pt_br" }

vim.opt.clipboard = ""

vim.g.have_nerd_font = true

vim.g.tabstop = 2
vim.g.shiftwidth = 2
vim.g.expandtab = true

vim.g.netrw_preview = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_alto = 0
vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")

vim.o.number = true
vim.o.relativenumber = true

vim.o.mouse = "a"

vim.o.showmode = false

vim.o.breakindent = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 250

vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = Red })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = Yellow })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = Blue })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = White })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineOk", { undercurl = true, sp = Green })

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.shell = "zsh"

vim.o.inccommand = "split"

vim.o.cursorline = true

vim.o.scrolloff = 10

vim.o.confirm = true

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    source = true,
  },
  severity_sort = true,
})
