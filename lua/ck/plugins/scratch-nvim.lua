-- https://github.com/cenk1cenk2/scratch.nvim
local M = {}

M.name = "cenk1cenk2/scratch.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/scratch.nvim",
        dir = "~/development/scratch.nvim",
      }
    end,
    setup = function()
      return {
        log_level = require("ck.log"):to_nvim_level(),
      }
    end,
    on_setup = function(c)
      require("scratch").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "s" }),
          function()
            require("scratch").create_scratch_buffer()
          end,
          desc = "create scratch buffer",
        },
        {
          fn.wk_keystroke({ categories.RUN, "S" }),
          function()
            require("scratch").execute_scratch_buffer(function(opts)
              local Terminal = require("ck.plugins.toggleterm-nvim")

              local terminal = Terminal.create_terminal(Terminal.generate_defaults_float_terminal({
                cmd = ("%s -c '%s %s'"):format(vim.o.shell, opts.command, opts.path),
                close_on_exit = false,
                dir = require("ck.utils.fs").get_cwd(),
              }))

              terminal:open()
            end)
          end,
          desc = "execute current scratch buffer",
        },
      }
    end,
  })
end

return M
