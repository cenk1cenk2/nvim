-- https://github.com/Davidyz/VectorCode
local M = {}

M.name = "vectorcode"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.vectorcode.enabled, {
    plugin = function()
      ---@type Plugin
      return {
        "Davidyz/VectorCode",
        version = "*",
        build = {
          "uv tool install --python 3.13 vectorcode[lsp,mcp]",
        },
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
          update = false,
          lsp = true,
        },
        sync_log_env_var = false,
      }
    end,
    on_setup = function(opts)
      require("vectorcode").setup(opts)
    end,
    autocmds = function()
      if nvim.lsp.ai.vectorcode.enabled == false then
        return {}
      end

      ---@type Autocmds
      return {
        {
          event = { "LspAttach" },
          group = "__completion",
          callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if not client or client.name ~= "vectorcode_server" then
              return
            end

            local cacher = require("vectorcode.config").get_cacher_backend()
            cacher.async_check("config", function()
              cacher.register_buffer(event.buf, {
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
