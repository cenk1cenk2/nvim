-- https://github.com/phaazon/mind.nvim
local M = {}

local extension_name = "mind_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "phaazon/mind.nvim",
        cmd = { "MindOpenSmartProject", "MindOpenMain", "MindOpenProject" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "mind",
      })
    end,
    setup = function()
      return {
        keymaps = {
          normal = {
            ["<cr>"] = "open_data",
            ["<s-cr>"] = "open_data_index",
            ["l"] = "toggle_node",
            ["/"] = "select_path",
            a = "add_inside_end_index",
            I = "add_inside_start",
            i = "add_inside_end",
            L = "copy_node_link",
            -- L = "copy_node_link_index",
            d = "delete",
            D = "delete_file",
            O = "add_above",
            o = "add_below",
            q = "quit",
            r = "rename",
            R = "change_icon_menu",
            u = "make_url",
            x = "select",
          },
          selection = {
            ["<cr>"] = "open_data",
            ["<s-tab>"] = "toggle_node",
            ["/"] = "select_path",
            I = "move_inside_start",
            i = "move_inside_end",
            O = "move_above",
            o = "move_below",
            q = "quit",
            x = "select",
          },
        },
      }
    end,
    on_setup = function(config)
      require("mind").setup(config.setup)
    end,
    wk = function()
      return {
        ["N"] = {
          function()
            require("mind").open_project()
          end,
          "open project notes",
        },
      }
    end,
  })
end

return M
