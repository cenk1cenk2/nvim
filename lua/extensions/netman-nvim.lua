-- https://github.com/miversen33/netman.nvim
local M = {}

M.name = "miversen33/netman.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "miversen33/netman.nvim",
        cmd = { "Neotree source=remote" },
      }
    end,
    -- configure = function(_, fn)
    --   fn.append_to_setup("neotree_nvim", {
    --     sources = { "netman.ui.neo-tree" },
    --     source_selector = {
    --       sources = {
    --         { source = "netman.ui.neo-tree", display_name = (" %s Remote "):format(lvim.ui.icons.kind.Struct) },
    --       },
    --     },
    --   })
    -- end,
    on_setup = function()
      require("netman").setup()
    end,
  })
end

return M
