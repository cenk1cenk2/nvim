-- https://github.com/gbprod/yanky.nvim
local M = {}

local extension_name = "yanky_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "gbprod/yanky.nvim",
        event = "VeryLazy",
      }
    end,
    register = "+",
    inject_to_configure = function()
      return {
        mapping = require("yanky.telescope.mapping"),
        default_register = require("yanky.utils").get_default_register(),
        telescope = require("telescope"),
      }
    end,
    setup = function(config)
      local mapping = config.inject.mapping
      local register = config.register

      return {
        ring = {
          history_length = 10,
          storage = "shada",
          sync_with_numbered_registers = true,
        },
        system_clipboard = {
          sync_with_ring = true,
        },
        highlight = {
          on_put = true,
          on_yank = true,
          timer = 500,
        },
        preserve_cursor_position = {
          enabled = true,
        },
        picker = {
          telescope = {
            mappings = {
              default = mapping.set_register(register),
              i = {
                ["<c-p>"] = mapping.put("p"),
                ["<c-P>"] = mapping.put("P"),
                ["<c-d>"] = mapping.delete(),
                ["<c-r>"] = mapping.set_register(register),
              },
              n = {
                ["p"] = mapping.put("p"),
                ["P"] = mapping.put("P"),
                ["d"] = mapping.delete(),
                ["r"] = mapping.set_register(register),
              },
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("yanky").setup(config.setup)
    end,
    on_done = function(config)
      config.inject.telescope.load_extension("yank_history")
    end,
    keymaps = function()
      local defaults = {
        ["gq"] = {
          function()
            local yanky = require("yanky")
            yanky.cycle(yanky.direction.forward)
          end,
          desc = "yank cycle forward",
        },
        ["gQ"] = {
          function()
            local yanky = require("yanky")
            yanky.cycle(yanky.direction.backward)
          end,
          desc = "yank cycle backward",
        },
        ["y"] = {
          "<Plug>(YankyYank)",
          desc = "yanky put before",
        },
      }

      local normal = {
        ["p"] = {
          function()
            local yanky = require("yanky")

            yanky.put(yanky.type.PUT_AFTER, false)
          end,
          desc = "yanky put after",
        },
        ["P"] = {
          function()
            local yanky = require("yanky")

            yanky.put(yanky.type.PUT_BEFORE, false)
          end,
          desc = "yanky put before",
        },
      }

      local cb = function(state)
        if state.is_visual then
          vim.cmd([[execute "normal! \<esc>"]])
        end

        local command = string.format('silent normal! %s"%s%s"_d%s', state.is_visual and "gv" or "", state.register, state.count, state.type)

        local ok, val = pcall(vim.cmd, command)

        if not ok then
          vim.notify(val, vim.log.levels.WARN)
          return
        end

        require("yanky.highlight").highlight_put(state)
      end

      local visual = {
        ["P"] = {
          function()
            local yanky = require("yanky")

            yanky.put(yanky.type.PUT_AFTER, true, cb)
          end,
          desc = "yanky put after",
        },
        ["p"] = {
          function()
            local yanky = require("yanky")

            yanky.put(yanky.type.PUT_BEFORE, true, cb)
          end,
          desc = "yanky put before",
        },
      }

      return {
        n = vim.tbl_extend("force", vim.deepcopy(defaults), normal),
        v = vim.tbl_extend("force", vim.deepcopy(defaults), visual),
        vb = vim.tbl_extend("force", vim.deepcopy(defaults), visual),
      }
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["y"] = { ":Telescope yank_history<CR>", "list yanky.nvim registers" },
        },
      }
    end,
  })
end

return M
