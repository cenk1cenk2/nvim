--
local M = {}

local extension_name = "template"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "rest-nvim/rest.nvim",
        requires = { "nvim-lua/plenary.nvim" },
      }
    end,
    setup = function()
      return {
        result_split_in_place = true,
        formatters = {
          json = "jq",
          html = function(body)
            return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
          end,
        },
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
            f = {
              function()
                require("rest-nvim").run_file()
              end,
              "run file",
            },
            s = {
              function()
                vim.ui.input({
                  prompt = "set rest-nvim environment",
                }, function(input)
                  require("rest-nvim").run(input)
                end)
              end,
              "select environment",
            },
          },
        },
      }
    end,
  })
end

return M
