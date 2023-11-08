-- https://github.com/rest-nvim/rest.nvim
local M = {}

local extension_name = "rest-nvim/rest.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "rest-nvim/rest.nvim",
        -- https://github.com/rest-nvim/rest.nvim/issues/246
        -- commit = "8b62563",
        requires = { "nvim-lua/plenary.nvim" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "httpResult",
      })
    end,
    setup = function()
      return {
        result_split_horizontal = false,
        result_split_in_place = true,
        result = {
          -- toggle showing URL, HTTP info, headers at top the of result window
          show_url = true,
          -- show the generated curl command in case you want to launch
          -- the same request via the terminal (can be verbose)
          show_curl_command = false,
          show_http_info = true,
          show_headers = true,
          -- executables or functions for formatting response body [optional]
          -- set them to false if you want to disable them
          formatters = {
            json = function(body)
              return vim.fn.system({ "prettierd", "response.json" }, body)
            end,
            html = function(body)
              return vim.fn.system({ "prettierd", "response.html" }, body)
            end,
          },
        },
        env_file = ".env.json",
      }
    end,
    on_setup = function(config)
      require("rest-nvim").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          r = {
            name = "rest-nvim",
            r = {
              function()
                require("rest-nvim").run()
              end,
              "run under cursor",
            },
            p = {
              function()
                require("rest-nvim").run(true)
              end,
              "run under cursor (preview)",
            },
            l = {
              function()
                require("rest-nvim").last()
              end,
              "run last",
            },
            s = {
              function()
                vim.ui.input({
                  prompt = "set rest-nvim environment",
                }, function(input)
                  require("rest-nvim").select_env(input)
                end)
              end,
              "select environment",
            },
          },
        },
      }
    end,
    autocmds = {
      require("modules.autocmds").q_close_autocmd({ "httpResult" }),
    },
  })
end

return M
