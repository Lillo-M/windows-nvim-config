return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dap_widgets = require("dap.ui.widgets")
      vim.keymap.set("n", "<F5>", function()
        dap.continue()
      end)
      vim.keymap.set("n", "<F10>", function()
        dap.step_over()
      end)
      vim.keymap.set("n", "<F11>", function()
        dap.step_into()
      end)
      vim.keymap.set("n", "<F12>", function()
        dap.step_out()
      end)
      vim.keymap.set("n", "<Leader>b", function()
        dap.toggle_breakpoint()
      end)
      vim.keymap.set("n", "<Leader>B", function()
        dap.set_breakpoint()
      end)
      vim.keymap.set("n", "<Leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end)
      vim.keymap.set("n", "<Leader>dr", function()
        dap.repl.open()
      end)
      vim.keymap.set("n", "<Leader>dl", function()
        dap.run_last()
      end)
      vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
        dap_widgets.hover()
      end)
      vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
        dap_widgets.preview()
      end)
      vim.keymap.set("n", "<Leader>df", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
      end)
      vim.keymap.set("n", "<Leader>ds", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dapui.elements.watches.add(vim.fn.expand("<cword>"))
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("python")
    end,
  },
}
