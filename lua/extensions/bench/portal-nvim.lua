-- https://github.com/cbochs/portal.nvim
local M = {}

local extension_name = "portal_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "cbochs/portal.nvim",
        config = function()
          require("utils.setup").packer_config "portal_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      mark = {
        save_path = vim.fn.stdpath "data" .. "/" .. "portal.json",
      },

      jump = {
        --- The default queries used when searching the jumplist. An entry can
        --- be a name of a registered query item, an anonymous predicate, or
        --- a well-formed query item. See Queries section for more information.
        --- @type Portal.QueryLike[]
        query = {
          -- "marked",
          "modified",
          "different",
          "valid",
        },

        labels = {
          --- An ordered list of keys that will be used for labelling
          --- available jumps. Labels will be applied in same order as
          --- `jump.query`
          select = { "a", "s", "d", "f", "h", "j", "k", "l" },

          --- Keys which will exit portal selection
          escape = {
            ["<esc>"] = true,
            ["<C-c>"] = true,
          },
        },

        --- Keys used for jumping forward and backward
        keys = {
          forward = "<c-i>",
          backward = "<c-o>",
        },
      },

      window = {
        title = {
          --- When a portal is empty, render an default portal title
          render_empty = true,

          --- The raw window options used for the title window
          options = {
            relative = "cursor",
            width = 80,
            height = 1,
            col = 2,
            style = "minimal",
            focusable = false,
            border = "single",
            noautocmd = true,
            zindex = 98,
          },
        },

        portal = {
          -- When a portal is empty, render an empty buffer body
          render_empty = false,

          --- The raw window options used for the portal window
          options = {
            relative = "cursor",
            width = 80,
            height = 3,
            col = 2,
            focusable = false,
            border = "single",
            noautocmd = true,
            zindex = 99,
          },
        },
      },
    },
    on_setup = function(config)
      require("portal").setup(config.setup)
    end,
  })
end

return M
