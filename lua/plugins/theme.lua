local theme_file = vim.fn.expand '~/.config/omarchy/current/theme/neovim.lua'

local function is_plugin_installed(name)
  local plugins = require('lazy.core.config').plugins
  return plugins[name] ~= nil and plugins[name]._.installed
end

function trim(s)
  return (s:match '^%s*(.-)%s*$')
end

local function split(str, delimiter)
  local result = {}
  for match in (str .. delimiter):gmatch('(.-)' .. delimiter) do
    table.insert(result, match)
  end
  return result
end

local function reload_theme()
  -- unload cached module
  package.loaded['plugins/theme'] = nil

  -- source updated theme file
  local theme = dofile(theme_file)

  local repo = theme[1][1]

  ctheme = theme[2].opts.colorscheme

  local theme_plugin = theme[1]

  local theme_plugin_str = vim.inspect(theme_plugin):sub(2, -3)

  local content = string.format(
    [[
return {
  %s
}
]],
    trim(theme_plugin_str)
  )

  local file = io.open(vim.fn.expand '~/.config/nvim/lua/plugins/' .. 'colorscheme.lua', 'r')

  if file then
    -- Step 2: Read the file contents
    local fileContents = file:read '*a'

    -- Step 3: Compare the contents
    file:close()
    if fileContents ~= content then
      file = io.open(vim.fn.expand '~/.config/nvim/lua/plugins/' .. 'colorscheme.lua', 'w')

      if file then
        file:write(content)
        file:close()
      else
        print 'Failed to open file.'
        return
      end
    end
  end

  for k, _ in pairs(package.loaded) do
    if k:match '^plugins%.' or k == 'plugins' then
      package.loaded[k] = nil
    end
  end

  plugin_name = ''
  if theme_plugin.name ~= nil then
    plugin_name = theme_plugin.name
  else
    plugin_name = split(repo, '/')[2]
  end

  if is_plugin_installed(plugin_name) then
    vim.cmd('colorscheme ' .. ctheme)
  end

  -- if theme_plugin.dependencies ~= nil then
  --   for dep_repo_name in theme_plugin.dependencies do
  --     local dep_name = split(dep_repo_name, '/')[2]
  --     if not is_plugin_installed(dep_name) then
  --       require('lazy').install { plugins = { dep_name } }
  --       require('lazy').load { plugins = { dep_name } }
  --     end
  --   end
  -- end
  --
  -- require('lazy').load { plugins = { plugin_name } }
  -- vim.cmd('colorscheme ' .. ctheme)
end

last_plugin_installed = ''

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyReload',
  callback = function()
    print('LazyReload ' .. ctheme)
    package.loaded['plugins.colorscheme'] = nil

    if last_plugin_installed == plugin_name then
      return
    end

    if not is_plugin_installed(plugin_name) then
      require('lazy').sync()
    else
      require('lazy').reload { plugins = { plugin_name } }
    end
    vim.cmd('colorscheme ' .. ctheme)
    last_plugin_installed = plugin_name
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyInstall',
  callback = function()
    print 'LazyInstall'
    vim.cmd('colorscheme ' .. ctheme)
  end,
})

-- watch the file for changes
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  callback = function()
    local stat = vim.loop.fs_stat(theme_file)

    if not stat then
      return
    end

    if _G.omarchy_theme_mtime ~= stat.mtime.sec then
      _G.omarchy_theme_mtime = stat.mtime.sec
      reload_theme()
    end
  end,
})

return {}
