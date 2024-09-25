-- https://github.com/jellydn/hurl.nvim
local M = {}

M.name = "jellydn/hurl.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "jellydn/hurl.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = {
          "HurlRunner",
          "HurlRunnerAt",
          "HurlRunnerToEntry",
          "HurlToggleMode",
          "HurlSetEnvFile",
          "HurlVerbose",
          "HurlManageVariables",
          "HurlShowLastResponse",
        },
        ft = { "hurl" },
      }
    end,
    setup = function()
      return {
        -- Show debugging info
        debug = false,
        auto_close = true,
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
        mappings = {
          close = "q", -- Close the response popup or split view
          next_panel = "<C-n>", -- Move to the next response popup window
          prev_panel = "<C-p>", -- Move to the previous response popup window
        },
      }
    end,
    on_setup = function(c)
      require("hurl").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "r" }),
          group = "hurl",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "e" }),
          function()
            local log = require("ck.log")
            local store_key = "HURL_ENVIRONMENT"
            local shada = require("ck.modules.shada")
            local stored_value = shada.get(store_key)

            vim.ui.input({
              prompt = "Select hurl environment: ",
              default = stored_value,
            }, function(env)
              if env == nil then
                log:warn("Nothing to select.")

                return
              end

              log:info(("Hurl environment file switched: %s"):format(env))
              shada.set(store_key, env)

              vim.cmd(":HurlSetEnvFile " .. env)
            end)
          end,
          desc = "select hurl environment",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "t" }),
          function()
            vim.cmd([[HurlRunnerToEntry]])
          end,
          desc = "run hurl to entry",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "r" }),
          function()
            vim.cmd([[HurlRunnerAt]])
          end,
          desc = "run hurl under cursor",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "f" }),
          function()
            vim.cmd([[HurlRunner]])
          end,
          desc = "run hurl for file",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "m" }),
          function()
            vim.cmd([[HurlToggleMode]])
          end,
          desc = "toggle hurl mode",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "v" }),
          function()
            vim.cmd([[HurlVerbose]])
          end,
          desc = "run hurl for file with verbose mode",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "m" }),
          function()
            vim.cmd([[HurlManageVariables]])
          end,
          desc = "manage hurl variables",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "o" }),
          function()
            vim.cmd([[HurlShowLastResponse]])
          end,
          desc = "show last response",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "c" }),
          function()
            local log = require("ck.log")
            local job = require("ck.utils.job")

            job
              .create({
                command = join_paths(get_config_dir(), "utils", "scripts", "curl-to-hurl.sh"),
                -- writer = vim.fn.getreg(vim.v.register or nvim.system_register),
                on_success = function(j)
                  local generated = table.concat(j:result(), "\n")

                  log:info("Copied generated hurl to clipboard.")
                  vim.fn.setreg(vim.v.register or nvim.system_register, generated)
                end,
              })
              :start()
          end,
          desc = "curl to hurl",
        },
        {
          fn.wk_keystroke({ categories.RUN, "r", "q" }),
          function()
            local log = require("ck.log")
            local job = require("ck.utils.job")

            job
              .create({
                command = "pkill",
                args = { "hurl" },
                on_success = function()
                  log:info("Killed running hurl instance.")
                end,
              })
              :start()
          end,
          desc = "kill running hurl instance",
        },
      }
    end,
  })
end

return M
