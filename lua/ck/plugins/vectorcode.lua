-- https://github.com/Davidyz/VectorCode
local M = {}

M.name = "vectorcode"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "Davidyz/VectorCode",
        version = "*",
        -- build = { "uv tool install -U vectorcode" },
        dependencies = { "nvim-lua/plenary.nvim" },
      }
    end,
    setup = function()
      ---@type VectorCode.Opts
      return {
        ---@type VectorCode.RegisterOpts
        async_opts = {
          debounce = 10,
          events = { "BufWritePost", "InsertEnter", "BufReadPost" },
          exclude_this = true,
          n_query = 1,
          notify = false,
          query_cb = require("vectorcode.utils").make_surrounding_lines_cb(-1),
          run_on_register = false,
        },
        async_backend = "lsp",
        exclude_this = true,
        n_query = 1,
        notify = true,
        timeout_ms = 5000,
        on_setup = {
          update = false, -- set to true to enable update when `setup` is called.
          lsp = true,
        },
        sync_log_env_var = false,
      }
    end,
    on_setup = function(opts)
      require("vectorcode").setup(opts)
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = { "LspAttach" },
          group = "__completion",
          callback = function(event)
            -- if not nvim.lsp.ai.completion.vectorcode.enabled then
            --   return
            -- end

            require("vectorcode.cacher").utils.async_check("config", function()
              require("vectorcode.cacher.lsp").register_buffer(event.buf, {
                notify = nvim.lsp.ai.debug,
                run_on_register = true,
                events = { "BufReadPost", "BufWritePost", "InsertLeave" },
                debounce = 15,
              })
            end, nil)
          end,
        },
      }
    end,
  })
end

return M
