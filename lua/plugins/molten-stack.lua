vim.keymap.set("n", "<leader>ip", function()
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv ~= nil then
    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
    venv = string.match(venv, "/.+/(.+)")
    vim.cmd(("MoltenInit %s"):format(venv))
  else
    vim.cmd("MoltenInit python3")
  end
end, { desc = "Initialize Molten for python3", silent = true })

-- automatically export output chunks to a jupyter notebook on write
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.ipynb" },
  callback = function()
    if require("molten.status").initialized() == "Molten" then
      vim.cmd("MoltenExportOutput!")
    end
  end,
})

local imb = function(e) -- init molten buffer
  vim.schedule(function()
    local kernels = vim.fn.MoltenAvailableKernels()
    local try_kernel_name = function()
      local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
      return metadata.kernelspec.name
    end
    local ok, kernel_name = pcall(try_kernel_name)
    if not ok or not vim.tbl_contains(kernels, kernel_name) then
      kernel_name = nil
      local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
      if venv ~= nil then
        kernel_name = string.match(venv, "/.+/(.+)")
      end
    end
    if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
      vim.cmd(("MoltenInit %s"):format(kernel_name))
    end
    vim.cmd("MoltenImportOutput")
  end)
end

-- automatically import output chunks from a jupyter notebook
vim.api.nvim_create_autocmd("BufAdd", {
  pattern = { "*.ipynb" },
  callback = imb,
})

-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ipynb" },
  callback = function(e)
    if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
      imb(e)
    end
  end,
})

return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
    },
    ft = "python", -- Load when opening Python files
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>" }, -- Open picker on keymap
    },
    opts = { -- this can be an empty lua table - just showing below for clarity.
      search = {}, -- if you add your own searches, they go here.
      options = {}, -- if you add plugin options, they go here.
    },
    {
      "benlubas/molten-nvim",
      version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
      dependencies = { "3rd/image.nvim" },
      build = ":UpdateRemotePlugins",
      init = function()
        -- these are examples, not defaults. Please see the readme
        vim.g.molten_image_provider = "image.nvim"
        vim.g.molten_output_win_max_height = 20
        vim.g.molten_auto_open_output = false
        vim.g.molten_wrap_output = true
        vim.g.molten_virt_text_output = true
        vim.g.molten_virt_lines_off_by_1 = true

        vim.keymap.set(
          "n",
          "<localleader>e",
          ":MoltenEvaluateOperator<CR>",
          { desc = "evaluate operator", silent = true }
        )
        vim.keymap.set(
          "n",
          "<localleader>om",
          ":MoltenImagePopup<CR>",
          { desc = "pop up image", silent = true }
        )
        vim.keymap.set(
          "n",
          "<localleader>os",
          ":noautocmd MoltenEnterOutput<CR>",
          { desc = "open output window", silent = true }
        )
        vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
        vim.keymap.set(
          "v",
          "<localleader>r",
          ":<C-u>MoltenEvaluateVisual<CR>gv",
          { desc = "execute visual selection", silent = true }
        )
        vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
        vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
        -- if you work with html outputs:
        vim.keymap.set(
          "n",
          "<localleader>mx",
          ":MoltenOpenInBrowser<CR>",
          { desc = "open output in browser", silent = true }
        )
        vim.keymap.set(
          "n",
          "<localleader>mi",
          ":MoltenImagePopup<CR>",
          { desc = "open output in browser", silent = true }
        )
      end,
    },
    {
      -- see the image.nvim readme for more information about configuring this plugin
      "3rd/image.nvim",
      opts = {
        backend = "kitty", -- whatever backend you would like to use
        max_width = 100,
        max_height = 12,
        max_height_window_percentage = math.huge,
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })
    end,
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
  },
  {
    "quarto-dev/quarto-nvim",
    dev = false,
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown" },
    config = function()
      local quarto = require("quarto")
      quarto.setup({
        lspFeatures = {
          -- NOTE: put whatever languages you want here:
          languages = { "r", "python", "rust" },
          chunks = "all",
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          -- NOTE: setup your own keymaps:
          hover = "<leader>H",
          definition = "gd",
          rename = "<leader>rn",
          references = "gr",
          format = "<leader>f",
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      })
      local runner = require("quarto.runner")
      vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
      vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
      vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
      vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
      vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
      vim.keymap.set("n", "<localleader>RA", function()
        runner.run_all(true)
      end, { desc = "run all cells of all languages", silent = true })
    end,
  },
}
