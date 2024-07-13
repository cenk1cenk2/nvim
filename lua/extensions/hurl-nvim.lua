-- https://github.com/jellydn/hurl.nvim
local M = {}

local extension_name = "jellydn/hurl.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "jellydn/hurl.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = { "HurlRunner", "HurlRunnerAt", "HurlRunnerToEntry", "HurlToggleMode", "HurlSetEnvFile", "HurlVerbose" },
        ft = { "hurl" },
      }
    end,
    setup = function()
      return {
        -- Show debugging info
        debug = false,
        -- Show response in popup or split
        mode = "popup",
        -- Split settings
        split_position = "right",
        split_size = "50%",

        -- Popup settings
        popup_position = "50%",
        popup_size = {
          width = 180,
          height = 50,
        },
        -- Default environment file name
        env_file = { ".env" },
        -- Specify formatters for different response types
        formatters = {
          -- json = { "prettierd", "result.json" },
          json = { "jq" },
          html = { "prettierd", "result.html" },
        },
      }
    end,
    on_setup = function(config)
      require("hurl").setup(config.setup)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "r" }),
          group = "hurl",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "e" }),
          function()
            local Log = require("lvim.core.log")
            local store_key = "HURL_ENVIRONMENT"
            local shada = require("modules.shada")
            local stored_value = shada.get(store_key)

            vim.ui.input({
              prompt = "Select hurl environment: ",
              default = stored_value,
            }, function(env)
              if env == nil then
                Log:warn("Nothing to select.")

                return
              end

              Log:info(("Hurl environment file switched: %s"):format(env))
              shada.set(store_key, env)

              vim.cmd(":HurlSetEnvFile " .. env)
            end)
          end,
          desc = "select hurl environment",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "t" }),
          function()
            vim.cmd([[HurlRunnerToEntry]])
          end,
          desc = "run hurl to entry",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "r" }),
          function()
            vim.cmd([[HurlRunnerAt]])
          end,
          desc = "run hurl under cursor",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "f" }),
          function()
            vim.cmd([[HurlRunner]])
          end,
          desc = "run hurl for file",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "m" }),
          function()
            vim.cmd([[HurlToggleMode]])
          end,
          desc = "toggle hurl mode",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "v" }),
          function()
            vim.cmd([[HurlVerbose]])
          end,
          desc = "run hurl for file with verbose mode",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "c" }),
          function()
            local Log = require("lvim.core.log")
            local job = require("utils.job")

            job.spawn({
              command = join_paths(get_config_dir(), "utils", "scripts", "curl-to-hurl.sh"),
              -- writer = vim.fn.getreg(vim.v.register or lvim.system_register),
              on_success = function(j)
                local generated = table.concat(j:result(), "\n")

                Log:info("Copied generated hurl to clipboard.")
                vim.fn.setreg(vim.v.register or lvim.system_register, generated)
              end,
            })
          end,
          desc = "curl to hurl",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "r", "q" }),
          function()
            local Log = require("lvim.core.log")
            local job = require("utils.job")

            job.spawn({
              command = "pkill",
              args = { "hurl" },
              on_success = function()
                Log:info("Killed running hurl instance.")
              end,
            })
          end,
          desc = "kill running hurl instance",
        },
      }
    end,
  })
end

return M
