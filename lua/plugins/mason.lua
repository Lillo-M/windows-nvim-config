return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    -- This config function is the main change.
    -- It configures mason-lspconfig to automatically set up LSPs.
    config = function()
      -- Get the capabilities for nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        -- A list of LSPs to ensure are installed.
        -- Example: ensure_installed = { "lua_ls", "tsserver" }
        ensure_installed = {
          "lua_ls",
          "html",
          "pyright",
          "texlab",
          "ts_ls",
          "yamlls",
          "clangd",
        },

        -- This is the key part.
        -- This handler is called for each language server that is installed.
        -- It will be passed the server name and the capabilities.
        handlers = {
          -- This is the default handler. It will be used for any server that doesn't have a specific handler.
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr)
                client.server_capabilities.semanticTokensProvider = nil
              end,
            })
          end,

          --
          vim.lsp.config("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            root_markers = {
              ".luarc.json",
              ".luarc.jsonc",
              ".luacheckrc",
              ".stylua.toml",
              "stylua.toml",
              "selene.toml",
              "selene.yml",
              ".git",
            },
            settings = {
              Lua = {
                runtime = {
                  -- Tell the language server which version of Lua you're using
                  -- (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                },
                diagnostics = {
                  -- Get the language server to recognize the `vim` global
                  globals = {
                    "vim",
                    "require",
                  },
                },
                workspace = {
                  -- Make the server aware of Neovim runtime files
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                  enable = false,
                },
              },
            },
          }),
          --
          vim.lsp.config("angularls", {
            root_markers = { "angular.json", "nx.json" },
            filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
            cmd = {
              "ngserver",
              "--stdio",
              "--tsProbeLocations",
              "C:/Users/murilo.pereira/AppData/Roaming/npm/node_modules/typescript/lib",
              "--ngProbeLocations",
              "C:/Users/murilo.pereira/AppData/Roaming/npm/node_modules/@angular/language-server/bin/",
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
          vim.lsp.config("pyright", {
            capabilities = capabilities,
            filetypes = { "python", "quarto", "markdown" },
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  diagnosticMode = "workspace",
                },
              },
            },
            root_markers = { ".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt" },
          }),
          --
        },
      })

      vim.schedule(function()
        local existing = vim.lsp.config["tailwindcss"] or {}
        vim.lsp.config(
          "tailwindcss",
          vim.tbl_deep_extend("force", existing, {
            settings = {
              tailwindCSS = {
                classAttributes = {
                  "class",
                  "className",
                  "class:list",
                  "classList",
                  "ngClass",
                  "styleClass",
                },
              },
            },
          })
        )
      end)
    end,
  },
}
