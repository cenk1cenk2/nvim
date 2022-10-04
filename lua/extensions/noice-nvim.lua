-- https://github.com/folke/noice.nvim
local M = {}

local extension_name = "noice_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "folke/noice.nvim",
        event = "VimEnter",
        config = function()
          require("utils.setup").packer_config "noice_nvim"
        end,
        requires = {
          "MunifTanjim/nui.nvim",
        },
        disable = not config.active,
      }
    end,
    configure = function()
      table.insert(lvim.disabled_filetypes, "cmdline")
    end,
    setup = {
      views = {
        cmdline_popup = {
          border = {
            style = "single",
            padding = { 0, 1 },
          },
          filter_options = {},
          win_options = {
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
          },
        },
      },
      routes = {
        {
          filter = { event = "msg_show", kind = "search_count" },
          opts = { skip = true },
        },
        {
          filter = { event = "split", kind = "search_count" },
          opts = { skip = true },
        },
        -- {
        --   filter = {
        --     event = "cmdline",
        --     find = "^%s*[/?]",
        --   },
        --   view = "cmdline",
        -- },
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
      },
    },
    on_setup = function(config)
      require("noice").setup(config.setup)
    end,
    wk = {
      ["h"] = { ":Noice<CR>", "messages" },
    },
  })
end

return M
