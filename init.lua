vim.cmd 'filetype plugin on'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.g.tabstop = 2
vim.g.shiftwidth = 2
vim.g.expandtab = true

vim.g.netrw_preview = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_alto = 0
vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim/bin/python3'

vim.o.number = true
vim.o.relativenumber = true

vim.o.mouse = 'a'

vim.o.showmode = false

vim.o.breakindent = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

vim.o.updatetime = 250

vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = Red })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = Yellow })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = Blue })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = White })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineOk', { undercurl = true, sp = Green })

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.shell = 'zsh'

vim.o.inccommand = 'split'

vim.o.cursorline = true

vim.o.scrolloff = 10

vim.o.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>gb', '<cmd>BlameToggle<CR>')

vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set('x', '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>pv', vim.cmd.Oil)
vim.keymap.set('x', '<leader>c', [["_di]])
vim.keymap.set('x', '<leader>d', [["_d]])
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('v', '<Tab>', '>gv')
vim.keymap.set('v', '<S-Tab>', '<gv')
vim.keymap.set('n', '<leader>mk', vim.cmd.MarkdownPreviewToggle)

vim.keymap.set('n', '<leader><leader>', function()
  vim.cmd 'so'
end)

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>f', function()
  require('conform').format { lsp_format = 'fallback' }
  local ft = vim.bo.filetype
  local bufnr = vim.api.nvim_get_current_buf()

  -- Call organize imports if it's a TypeScript or TSX file
  if ft == 'typescript' or ft == 'typescriptreact' then
    local params = {
      command = '_typescript.organizeImports',
      arguments = { vim.api.nvim_buf_get_name(bufnr) },
      title = '',
    }
    vim.lsp.buf_request_sync(bufnr, 'workspace/executeCommand', params, 500)
  end
end, { desc = 'Formatting file...' })

function OrganizeTSImports()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = {
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
    title = '',
  }
  vim.lsp.buf_request_sync(bufnr, 'workspace/executeCommand', params, 500)
end

vim.keymap.set('n', 'gd', vim.lsp.buf.definition)

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  float = {
    border = 'rounded',
    source = true,
  },
  severity_sort = true,
}

vim.keymap.set('n', '<leader>ip', function()
  local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
  if venv ~= nil then
    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
    venv = string.match(venv, '/.+/(.+)')
    vim.cmd(('MoltenInit %s'):format(venv))
  else
    vim.cmd 'MoltenInit python3'
  end
end, { desc = 'Initialize Molten for python3', silent = true })

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- automatically export output chunks to a jupyter notebook on write
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*.ipynb' },
  callback = function()
    if require('molten.status').initialized() == 'Molten' then
      vim.cmd 'MoltenExportOutput!'
    end
  end,
})

local imb = function(e) -- init molten buffer
  vim.schedule(function()
    local kernels = vim.fn.MoltenAvailableKernels()
    local try_kernel_name = function()
      local metadata = vim.json.decode(io.open(e.file, 'r'):read 'a')['metadata']
      return metadata.kernelspec.name
    end
    local ok, kernel_name = pcall(try_kernel_name)
    if not ok or not vim.tbl_contains(kernels, kernel_name) then
      kernel_name = nil
      local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
      if venv ~= nil then
        kernel_name = string.match(venv, '/.+/(.+)')
      end
    end
    if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
      vim.cmd(('MoltenInit %s'):format(kernel_name))
    end
    vim.cmd 'MoltenImportOutput'
  end)
end

-- automatically import output chunks from a jupyter notebook
vim.api.nvim_create_autocmd('BufAdd', {
  pattern = { '*.ipynb' },
  callback = imb,
})

-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.ipynb' },
  callback = function(e)
    if vim.api.nvim_get_vvar 'vim_did_enter' ~= 1 then
      imb(e)
    end
  end,
})

require 'plugins/theme'

require('lazy').setup {
  spec = {
    { import = 'plugins' },
    { -- Fuzzy Finder (files, lsp, etc)
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { -- If encountering errors, see telescope-fzf-native README for installation instructions
          'nvim-telescope/telescope-fzf-native.nvim',

          -- `build` is used to run some command when the plugin is installed/updated.
          -- This is only run then, not every time Neovim starts up.
          build = 'make',

          -- `cond` is a condition used to determine whether this plugin should be
          -- installed and loaded.
          cond = function()
            return vim.fn.executable 'make' == 1
          end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
      },
      config = function()
        -- Telescope is a fuzzy finder that comes with a lot of different things that
        -- it can fuzzy find! It's more than just a "file finder", it can search
        -- many different aspects of Neovim, your workspace, LSP, and more!
        --
        -- The easiest way to use Telescope, is to start by doing something like:
        --  :Telescope help_tags
        --
        -- After running this command, a window will open up and you're able to
        -- type in the prompt window. You'll see a list of `help_tags` options and
        -- a corresponding preview of the help.
        --
        -- Two important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?
        --
        -- This opens a window that shows you all of the keymaps for the current
        -- Telescope picker. This is really useful to discover what Telescope can
        -- do as well as how to actually do it!

        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`

        -- See `:help telescope.builtin`
        local builtin = require 'telescope.builtin'
        local action_state = require 'telescope.actions.state'
        local actions = require 'telescope.actions'
        require('telescope').setup {
          -- You can put your default mappings / updates / etc. in here
          --  All the info you're looking for is in `:help telescope.setup()`
          --

          defaults = {
            file_ignore_patterns = { 'node_modules', '.git/', 'build/', 'out/' },
            mappings = {
              i = {
                ['<C-c>'] = false,
              },
              n = {
                ['<C-c>'] = actions.close,
              },
            },
          },
          -- pickers = {}
          extensions = {
            ['ui-select'] = {
              require('telescope.themes').get_dropdown(),
            },
          },
        }

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = '[P]search [F]iles' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = '[P]search by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('i', '<C-c>', '<Esc>')
        vim.keymap.set('n', '<leader>pb', function()
          builtin.buffers({
            initial_mode = 'insert',
            attach_mappings = function(prompt_bufnr, map)
              local delete_buf = function()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:delete_selection(function(selection)
                  vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                end)
              end

              map('n', '<c-x>', delete_buf)

              return true
            end,
          }, { desc = '[P]search [B]uffers', sort_lastused = true, sort_mru = true, theme = 'dropdown' })
        end)

        -- Slightly advanced example of overriding default behavior and theme
        vim.keymap.set('n', '<leader>/', function()
          -- You can pass additional configuration to Telescope to change the theme, layout, etc.
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end, { desc = '[/] Fuzzily search in current buffer' })

        -- It's also possible to pass additional configuration options.
        --  See `:help telescope.builtin.live_grep()` for information about particular keys
        vim.keymap.set('n', '<leader>s/', function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end, { desc = '[S]earch [/] in Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
          builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })
      end,
    },

    {
      'stevearc/conform.nvim',
      config = function()
        require('conform').setup {
          log_level = vim.log.levels.DEBUG,
          formatters_by_ft = {
            lua = { 'stylua' },
            -- Conform will run multiple formatters sequentially
            python = { 'isort', 'ruff' },
            -- You can customize some of the format options for the filetype (:help conform.format)
            rust = { 'rustfmt', lsp_format = 'fallback' },
            -- Conform will run the first available formatter
            javascript = { 'prettierd', 'prettier', stop_after_first = true },
            typescript = { 'prettierd', 'prettier', stop_after_first = true },
            html = { 'prettierd', 'prettier', stop_after_first = true },
            css = { 'prettierd', 'prettier', stop_after_first = true },
            scss = { 'prettierd', 'prettier', stop_after_first = true },
            htmlangular = { 'prettierd', 'prettier', stop_after_first = true },
            vhdl = { 'vsg' },
          },
        }
      end,
    },

    {
      'mfussenegger/nvim-lint',
      event = {
        'BufReadPre',
        'BufNewFile',
      },
      config = function()
        local lint = require 'lint'

        vim.env.ESLINT_D_PPID = vim.fn.getpid()
        lint.linters_by_ft = {
          javascript = { 'eslint_d' },
          typescript = { 'eslint_d' },
          javascriptreact = { 'eslint_d' },
          typescriptreact = { 'eslint_d' },
          vhdl = { 'vsg' },
        }

        local lint_group = vim.api.nvim_create_augroup('lint', { clear = true })

        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
          group = lint_group,
          callback = function()
            lint.try_lint()
          end,
        })
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      dev = false,
      branch = 'main',

      dependencies = {
        {
          'nvim-treesitter/nvim-treesitter-textobjects',
          branch = 'main',
          init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
          end,
          config = function()
            require('nvim-treesitter-textobjects').setup {
              select = {
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
              },
            }

            -- select
            vim.keymap.set({ 'x', 'o' }, 'am', function()
              require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
            end)
            vim.keymap.set({ 'x', 'o' }, 'im', function()
              require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
            end)
            vim.keymap.set({ 'x', 'o' }, 'ac', function()
              require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
            end)
            vim.keymap.set({ 'x', 'o' }, 'ic', function()
              require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
            end)
            -- You can also use captures from other query groups like `locals.scm`
            vim.keymap.set({ 'x', 'o' }, 'as', function()
              require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
            end)

            -- move
            vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
            end)
            vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@class.inner', 'textobjects')
            end)
            -- You can also pass a list to group multiple queries.
            vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
              require('nvim-treesitter-textobjects.move').goto_next_start({ '@loop.inner', '@loop.outer' }, 'textobjects')
            end)
            -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
            vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@local.scope', 'locals')
            end)
            vim.keymap.set({ 'n', 'x', 'o' }, ']z', function()
              require('nvim-treesitter-textobjects.move').goto_next_start('@fold', 'folds')
            end)

            vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
              require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
            end)
            vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
              require('nvim-treesitter-textobjects.move').goto_next_end('@class.inner', 'textobjects')
            end)

            vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
              require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
            end)
            vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
              require('nvim-treesitter-textobjects.move').goto_previous_start('@class.inner', 'textobjects')
            end)

            vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
              require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
            end)
            vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
              require('nvim-treesitter-textobjects.move').goto_previous_end('@class.inner', 'textobjects')
            end)
          end,
        },
      },

      run = ':TSUpdate',
      config = function()
        local ts = require 'nvim-treesitter'
        ---@diagnostic disable-next-line: missing-fields
        ts.setup {}
        ts.install {
          'r',
          'python',
          'markdown',
          'markdown_inline',
          'julia',
          'bash',
          'yaml',
          'lua',
          'vim',
          'query',
          'vimdoc',
          'latex', -- requires tree-sitter-cli (installed automatically via Mason)
          'html',
          'css',
          'dot',
          'javascript',
          'mermaid',
          'typescript',
        }
      end,
    },
    {
      'jiaoshijie/undotree',
      dependencies = 'nvim-lua/plenary.nvim',
      config = true,
      keys = { -- load the plugin only when using it's keybinding:
        { '<leader>u', "<cmd>lua require('undotree').toggle()<cr>" },
      },
    },

    -- Mason, for installing LSPs
    {
      'mason-org/mason.nvim',
      opts = {},
    },

    -- This plugin is the bridge between mason.nvim and nvim-lspconfig
    {
      'mason-org/mason-lspconfig.nvim',
      dependencies = { 'mason.nvim' },
      -- This config function is the main change.
      -- It configures mason-lspconfig to automatically set up LSPs.
      config = function()
        -- Get the capabilities for nvim-cmp
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        require('mason-lspconfig').setup {
          -- A list of LSPs to ensure are installed.
          -- Example: ensure_installed = { "lua_ls", "tsserver" }
          ensure_installed = {
            'lua_ls',
            'html',
            'pyright',
            'texlab',
            'ts_ls',
            'yamlls',
            'clangd',
          },

          -- This is the key part.
          -- This handler is called for each language server that is installed.
          -- It will be passed the server name and the capabilities.
          handlers = {
            -- This is the default handler. It will be used for any server that doesn't have a specific handler.
            function(server_name)
              require('lspconfig')[server_name].setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                  client.server_capabilities.semanticTokensProvider = nil
                end,
              }
            end,

            --
            vim.lsp.config('lua_ls', {
              cmd = { 'lua-language-server' },
              filetypes = { 'lua' },
              root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
              settings = {
                Lua = {
                  runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                  },
                  diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = {
                      'vim',
                      'require',
                    },
                  },
                  workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file('', true),
                  },
                  -- Do not send telemetry data containing a randomized but unique identifier
                  telemetry = {
                    enable = false,
                  },
                },
              },
            }),
            --
            vim.lsp.config('angularls', {
              root_markers = { 'angular.json', 'nx.json' },
              filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx', 'htmlangular' },
              cmd = {
                'ngserver',
                '--stdio',
                '--tsProbeLocations',
                'C:/Users/murilo.pereira/AppData/Roaming/npm/node_modules/typescript/lib',
                '--ngProbeLocations',
                'C:/Users/murilo.pereira/AppData/Roaming/npm/node_modules/@angular/language-server/bin/',
              },
            }),
            --
            -- vim.lsp.config('tailwindcss', {
            --   settings = {
            --     tailwindCSS = {
            --       classAttributes = {
            --         'class',
            --         'className',
            --         'class:list',
            --         'classList',
            --         'ngClass',
            --         'styleClass',
            --       },
            --     },
            --   },
            -- }),
            vim.lsp.config('pyright', {
              capabilities = capabilities,
              filetypes = { 'python', 'quarto', 'markdown' },
              settings = {
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = 'workspace',
                  },
                },
              },
              root_markers = { '.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt' },
            }),
            --
          },
        }

        vim.schedule(function()
          local existing = vim.lsp.config['tailwindcss'] or {}
          vim.lsp.config(
            'tailwindcss',
            vim.tbl_deep_extend('force', existing, {
              settings = {
                tailwindCSS = {
                  classAttributes = {
                    'class',
                    'className',
                    'class:list',
                    'classList',
                    'ngClass',
                    'styleClass',
                  },
                },
              },
            })
          )
        end)
      end,
    },

    -- nvim-cmp for autocompletion
    {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = { 'hrsh7th/cmp-nvim-lsp' },
      config = function()
        local cmp = require 'cmp'

        cmp.setup {
          sources = {
            { name = 'nvim_lsp' },
            { name = 'path' },
          },
          mapping = cmp.mapping.preset.insert {
            ['<C-y>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<C-Space>'] = cmp.mapping.confirm { select = true },
            ['<Tab>'] = cmp.mapping.confirm { select = true },
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
          },
          snippet = {
            expand = function(args)
              -- You need a snippet engine for this to work.
              -- Example using luasnip: require('luasnip').lsp_expand(args.body)
              vim.snippet.expand(args.body)
            end,
          },
        }
      end,
    },

    -- nvim-lspconfig
    {
      'neovim/nvim-lspconfig',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'mason-org/mason-lspconfig.nvim', -- Crucial dependency
      },
      config = function()
        -- The setup call for mason-lspconfig is REMOVED from here.
        -- This config block is now only for LSP-related keymaps and autocmds.

        vim.opt.signcolumn = 'yes' -- Keep this for a stable UI

        -- This autocmd defines your keymaps for when an LSP attaches to a buffer.
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', '<leader>H', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<leader>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          end,
        })
      end,
    },
    {
      'FabijanZulj/blame.nvim',
      lazy = false,
      config = function()
        require('blame').setup {}
      end,
    },
    {
      'stevearc/oil.nvim',
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {},
      -- Optional dependencies
      dependencies = { { 'nvim-mini/mini.icons', opts = {} } },
      -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
      -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
      lazy = false,
      config = function()
        require('oil').setup {
          -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
          -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
          default_file_explorer = true,
          -- Id is automatically added at the beginning, and name at the end
          -- See :help oil-columns
          columns = {
            'icon',
            'permissions',
            'size',
            'mtime',
          },
          -- Buffer-local options to use for oil buffers
          buf_options = {
            buflisted = false,
            bufhidden = 'hide',
          },
          -- Window-local options to use for oil buffers
          win_options = {
            wrap = false,
            signcolumn = 'no',
            cursorcolumn = false,
            foldcolumn = '0',
            spell = false,
            list = false,
            conceallevel = 3,
            concealcursor = 'nvic',
          },
          -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
          delete_to_trash = false,
          -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
          skip_confirm_for_simple_edits = false,
          -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
          -- (:help prompt_save_on_select_new_entry)
          prompt_save_on_select_new_entry = true,
          -- Oil will automatically delete hidden buffers after this delay
          -- You can set the delay to false to disable cleanup entirely
          -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
          cleanup_delay_ms = 2000,
          lsp_file_methods = {
            -- Enable or disable LSP file operations
            enabled = true,
            -- Time to wait for LSP file operations to complete before skipping
            timeout_ms = 1000,
            -- Set to true to autosave buffers that are updated with LSP willRenameFiles
            -- Set to "unmodified" to only save unmodified buffers
            autosave_changes = 'unmodified',
          },
          -- Constrain the cursor to the editable parts of the oil buffer
          -- Set to `false` to disable, or "name" to keep it on the file names
          constrain_cursor = 'editable',
          -- Set to true to watch the filesystem for changes and reload oil
          watch_for_changes = false,
          -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
          -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
          -- Additionally, if it is a string that matches "actions.<name>",
          -- it will use the mapping at require("oil.actions").<name>
          -- Set to `false` to remove a keymap
          -- See :help oil-actions for a list of all available actions
          keymaps = {
            ['g?'] = { 'actions.show_help', mode = 'n' },
            ['<CR>'] = 'actions.select',
            ['<C-Space>'] = 'actions.select',
            ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
            ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
            ['<C-t>'] = { 'actions.select', opts = { tab = true } },
            ['<C-p>'] = 'actions.preview',
            ['<C-c>'] = { 'actions.close', mode = 'n' },
            ['<C-l>'] = 'actions.refresh',
            ['-'] = { 'actions.parent', mode = 'n' },
            ['<C-x>'] = { 'actions.parent', mode = 'n' },
            ['_'] = { 'actions.open_cwd', mode = 'n' },
            ['`'] = { 'actions.cd', mode = 'n' },
            ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
            ['gs'] = { 'actions.change_sort', mode = 'n' },
            ['gx'] = 'actions.open_external',
            ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
            ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
          },
          -- Set to false to disable all of the above keymaps
          use_default_keymaps = true,
          view_options = {
            -- Show files and directories that start with "."
            show_hidden = false,
            -- This function defines what is considered a "hidden" file
            is_hidden_file = function(name, bufnr)
              local m = name:match '^%.'
              return m ~= nil
            end,
            -- This function defines what will never be shown, even when `show_hidden` is set
            is_always_hidden = function(name, bufnr)
              return false
            end,
            -- Sort file names with numbers in a more intuitive order for humans.
            -- Can be "fast", true, or false. "fast" will turn it off for large directories.
            natural_order = 'fast',
            -- Sort file and directory names case insensitive
            case_insensitive = false,
            sort = {
              -- sort order can be "asc" or "desc"
              -- see :help oil-columns to see which columns are sortable
              { 'type', 'asc' },
              { 'name', 'asc' },
            },
            -- Customize the highlight group for the file name
            highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
              return nil
            end,
          },
          -- Extra arguments to pass to SCP when moving/copying files over SSH
          extra_scp_args = {},
          -- EXPERIMENTAL support for performing file operations with git
          git = {
            -- Return true to automatically git add/mv/rm files
            add = function(path)
              return false
            end,
            mv = function(src_path, dest_path)
              return false
            end,
            rm = function(path)
              return false
            end,
          },
          -- Configuration for the floating window in oil.open_float
          float = {
            -- Padding around the floating window
            padding = 2,
            -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            max_width = 0,
            max_height = 0,
            border = nil,
            win_options = {
              winblend = 0,
            },
            -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
            get_win_title = nil,
            -- preview_split: Split direction: "auto", "left", "right", "above", "below".
            preview_split = 'auto',
            -- This is the config that will be passed to nvim_open_win.
            -- Change values here to customize the layout
            override = function(conf)
              return conf
            end,
          },
          -- Configuration for the file preview window
          preview_win = {
            -- Whether the preview window is automatically updated when the cursor is moved
            update_on_cursor_moved = true,
            -- How to open the preview window "load"|"scratch"|"fast_scratch"
            preview_method = 'fast_scratch',
            -- A function that returns true to disable preview on a file e.g. to avoid lag
            disable_preview = function(filename)
              return false
            end,
            -- Window-local options to use for preview window buffers
            win_options = {},
          },
          -- Configuration for the floating action confirmation window
          confirmation = {
            -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a single value or a list of mixed integer/float types.
            -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
            max_width = 0.9,
            -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
            min_width = { 40, 0.4 },
            -- optionally define an integer/float for the exact width of the preview window
            width = nil,
            -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_height and max_height can be a single value or a list of mixed integer/float types.
            -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
            max_height = 0.9,
            -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
            min_height = { 5, 0.1 },
            -- optionally define an integer/float for the exact height of the preview window
            height = nil,
            border = nil,
            win_options = {
              winblend = 0,
            },
          },
          -- Configuration for the floating progress window
          progress = {
            max_width = 0.9,
            min_width = { 40, 0.4 },
            width = nil,
            max_height = { 10, 0.9 },
            min_height = { 5, 0.1 },
            height = nil,
            border = nil,
            minimized_border = 'none',
            win_options = {
              winblend = 0,
            },
          },
          -- Configuration for the floating SSH window
          ssh = {
            border = nil,
          },
          -- Configuration for the floating keymaps help window
          keymaps_help = {
            border = nil,
          },
        }
      end,
    },
    {
      'lukas-reineke/indent-blankline.nvim',
      main = 'ibl',
      ---@module "ibl"
      ---@type ibl.config
      opts = {},
    },
    {
      'iamcco/markdown-preview.nvim',
      cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
      build = 'cd app && npm install',
      init = function()
        vim.g.mkdp_filetypes = { 'markdown' }
      end,
      ft = { 'markdown' },
    },
    {
      'mfussenegger/nvim-dap',
      config = function()
        local dap = require 'dap'
        local dap_widgets = require 'dap.ui.widgets'
        vim.keymap.set('n', '<F5>', function()
          dap.continue()
        end)
        vim.keymap.set('n', '<F10>', function()
          dap.step_over()
        end)
        vim.keymap.set('n', '<F11>', function()
          dap.step_into()
        end)
        vim.keymap.set('n', '<F12>', function()
          dap.step_out()
        end)
        vim.keymap.set('n', '<Leader>b', function()
          dap.toggle_breakpoint()
        end)
        vim.keymap.set('n', '<Leader>B', function()
          dap.set_breakpoint()
        end)
        vim.keymap.set('n', '<Leader>lp', function()
          dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
        end)
        vim.keymap.set('n', '<Leader>dr', function()
          dap.repl.open()
        end)
        vim.keymap.set('n', '<Leader>dl', function()
          dap.run_last()
        end)
        vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
          dap_widgets.hover()
        end)
        vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
          dap_widgets.preview()
        end)
        vim.keymap.set('n', '<Leader>df', function()
          local widgets = require 'dap.ui.widgets'
          widgets.centered_float(widgets.frames)
        end)
        vim.keymap.set('n', '<Leader>ds', function()
          local widgets = require 'dap.ui.widgets'
          widgets.centered_float(widgets.scopes)
        end)
      end,
    },
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
      config = function()
        local dap, dapui = require 'dap', require 'dapui'
        dapui.setup()
        dapui.elements.watches.add(vim.fn.expand '<cword>')
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
      'mfussenegger/nvim-dap-python',
      config = function()
        require('dap-python').setup 'python'
      end,
    },
    {
      'https://gitlab.com/itaranto/plantuml.nvim',
      version = '*',
      config = function()
        local M = require 'plantuml.image'
        function M.Renderer:new(options)
          options = vim.tbl_deep_extend('force', {
            prog = 'feh',
            dark_mode = false, -- 👈 your fix here
          }, options or {})

          self.__index = self

          return setmetatable({
            prog = options.prog,
            dark_mode = options.dark_mode,
            format = options.format,
            tmp_file = vim.fn.tempname() .. '.' .. options.format,
            started = false,
          }, self)
        end
        require('plantuml').setup {
          renderer = {
            type = 'image',
            options = {
              prog = 'sumatraPDF',
              dark_mode = false,
              format = 'png', -- Allowed values: nil, 'png', 'svg'.
            },
          },
          render_on_write = true,
        }
      end,
    },
    {
      'sindrets/diffview.nvim',
      dependencies = {
        { 'nvim-tree/nvim-web-devicons', opts = {} },
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
              local pickers = require 'telescope.pickers'
              local finders = require 'telescope.finders'
              local conf = require('telescope.config').values
              local actions = require 'telescope.actions'
              local action_state = require 'telescope.actions.state'
              pickers
                .new({}, {
                  prompt_title = 'Choose an Option',
                  finder = finders.new_table {
                    results = {
                      {
                        display = '1 - Current branch',
                        action = function()
                          vim.cmd.DiffviewOpen()
                        end,
                      },
                      {
                        display = '2 - Current file',
                        action = function()
                          vim.cmd.DiffviewOpen '%'
                        end,
                      },
                      {
                        display = '3 - Current branch with custom index (HEAD~, <commit_id>, etc...)',
                        action = function()
                          vim.api.nvim_feedkeys(':DiffviewOpen ', 'n', true)
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
                  },
                  sorter = conf.generic_sorter {},
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
        vim.keymap.set('n', '<leader>dd', toggle())
      end,
    },
    {
      'linux-cultist/venv-selector.nvim',
      dependencies = {
        'neovim/nvim-lspconfig',
        { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
      },
      ft = 'python', -- Load when opening Python files
      keys = {
        { '<leader>vs', '<cmd>VenvSelect<cr>' }, -- Open picker on keymap
      },
      opts = { -- this can be an empty lua table - just showing below for clarity.
        search = {}, -- if you add your own searches, they go here.
        options = {}, -- if you add plugin options, they go here.
      },
      {
        'benlubas/molten-nvim',
        version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
        dependencies = { '3rd/image.nvim' },
        build = ':UpdateRemotePlugins',
        init = function()
          -- these are examples, not defaults. Please see the readme
          vim.g.molten_image_provider = 'image.nvim'
          vim.g.molten_output_win_max_height = 20
          vim.g.molten_auto_open_output = false
          vim.g.molten_wrap_output = true
          vim.g.molten_virt_text_output = true
          vim.g.molten_virt_lines_off_by_1 = true

          vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { desc = 'evaluate operator', silent = true })
          vim.keymap.set('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', { desc = 'open output window', silent = true })
          vim.keymap.set('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', { desc = 're-eval cell', silent = true })
          vim.keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { desc = 'execute visual selection', silent = true })
          vim.keymap.set('n', '<localleader>oh', ':MoltenHideOutput<CR>', { desc = 'close output window', silent = true })
          vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { desc = 'delete Molten cell', silent = true })
          -- if you work with html outputs:
          vim.keymap.set('n', '<localleader>mx', ':MoltenOpenInBrowser<CR>', { desc = 'open output in browser', silent = true })
          vim.keymap.set('n', '<localleader>mi', ':MoltenImagePopup<CR>', { desc = 'open output in browser', silent = true })
        end,
      },
      {
        -- see the image.nvim readme for more information about configuring this plugin
        '3rd/image.nvim',
        opts = {
          backend = 'kitty', -- whatever backend you would like to use
          max_width = 100,
          max_height = 12,
          max_height_window_percentage = math.huge,
          max_width_window_percentage = math.huge,
          window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
          window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
        },
      },
    },
    {
      'GCBallesteros/jupytext.nvim',
      config = function()
        require('jupytext').setup {
          style = 'markdown',
          output_extension = 'md',
          force_ft = 'markdown',
        }
      end,
      -- Depending on your nvim distro or config you may need to make the loading not lazy
      -- lazy=false,
    },
    {
      'quarto-dev/quarto-nvim',
      dev = false,
      dependencies = {
        -- for language features in code cells
        -- configured in lua/plugins/lsp.lua
        'jmbuhr/otter.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
      ft = { 'markdown' },
      config = function()
        local quarto = require 'quarto'
        quarto.setup {
          lspFeatures = {
            -- NOTE: put whatever languages you want here:
            languages = { 'r', 'python', 'rust' },
            chunks = 'all',
            diagnostics = {
              enabled = true,
              triggers = { 'BufWritePost' },
            },
            completion = {
              enabled = true,
            },
          },
          keymap = {
            -- NOTE: setup your own keymaps:
            hover = '<leader>H',
            definition = 'gd',
            rename = '<leader>rn',
            references = 'gr',
            format = '<leader>f',
          },
          codeRunner = {
            enabled = true,
            default_method = 'molten',
          },
        }
        local runner = require 'quarto.runner'
        vim.keymap.set('n', '<localleader>rc', runner.run_cell, { desc = 'run cell', silent = true })
        vim.keymap.set('n', '<localleader>ra', runner.run_above, { desc = 'run cell and above', silent = true })
        vim.keymap.set('n', '<localleader>rA', runner.run_all, { desc = 'run all cells', silent = true })
        vim.keymap.set('n', '<localleader>rl', runner.run_line, { desc = 'run line', silent = true })
        vim.keymap.set('v', '<localleader>r', runner.run_range, { desc = 'run visual range', silent = true })
        vim.keymap.set('n', '<localleader>RA', function()
          runner.run_all(true)
        end, { desc = 'run all cells of all languages', silent = true })
      end,
    },
    -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- place them in the correct locations.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
    -- require 'kickstart.plugins.autopairs',
    -- require 'kickstart.plugins.neo-tree',
    -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    -- { import = 'custom.plugins' },
    --
    -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
    -- Or use telescope!
    -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
    -- you can continue same window with `<space>sr` which resumes last telescope search
  },
  {
    ui = {
      -- If you are using a Nerd Font: set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
    },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
