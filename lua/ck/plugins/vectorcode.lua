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
          "uv tool install --python 3.13 'vectorcode[lsp,mcp]'",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
      }
    end,
    setup = function()
      ---@type VectorCode.Opts
      return {
        async_opts = {
          run_on_register = true,
          notify = nvim.lsp.ai.debug,
        },
        async_backend = "lsp",
        notify = true,
        on_setup = {
          update = false,
          lsp = true,
        },
      }
    end,
    on_setup = function(opts)
      require("vectorcode").setup(opts)
    end,
    -- autocmds = function()
    --   if nvim.lsp.ai.vectorcode.enabled == false then
    --     return {}
    --   end
    --
    --   ---@type Autocmds
    --   return {
    --     {
    --       event = { "LspAttach" },
    --       group = "__completion",
    --       callback = function(event)
    --         local client = vim.lsp.get_client_by_id(event.data.client_id)
    --         if not client or client.name ~= "vectorcode_server" then
    --           return
    --         end
    --
    --         local cacher = require("vectorcode.config").get_cacher_backend()
    --         cacher.async_check("config", function()
    --           cacher.register_buffer(event.buf)
    --         end, nil)
    --       end,
    --     },
    --   }
    -- end,
  })
end

return M
