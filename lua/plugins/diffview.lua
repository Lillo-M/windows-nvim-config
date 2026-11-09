return {
  "sindrets/diffview.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", opts = {} },
  },
  config = function()
    local toggle = function()
      local isOpen = false

      return function()
        if isOpen then
          isOpen = not isOpen
          vim.cmd.DiffviewClose()
        else
          isOpen = not isOpen
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          pickers
            .new({}, {
              prompt_title = "Choose an Option",
              finder = finders.new_table({
                results = {
                  {
                    display = "1 - Current branch",
                    action = function()
                      vim.cmd.DiffviewOpen()
                    end,
                  },
                  {
                    display = "2 - Current file",
                    action = function()
                      vim.cmd.DiffviewOpen("%")
                    end,
                  },
                  {
                    display = "3 - Current branch with custom index (HEAD~, <commit_id>, etc...)",
                    action = function()
                      vim.api.nvim_feedkeys(":DiffviewOpen ", "n", true)
                    end,
                  },
                },
                entry_maker = function(entry)
                  return {
                    value = entry,
                    display = entry.display,
                    ordinal = entry.display,
                  }
                end,
              }),
              sorter = conf.generic_sorter({}),
              attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)

                  local selection = action_state.get_selected_entry()
                  selection.value.action()
                end)
                return true
              end,
            })
            :find()
        end
      end
    end
    vim.keymap.set("n", "<leader>dd", toggle())
  end,
}
