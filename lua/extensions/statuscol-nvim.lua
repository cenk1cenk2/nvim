-- https://github.com/luukvbaal/statuscol.nvim
local M = {}

local extension_name = "statuscol_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "luukvbaal/statuscol.nvim",
        branch = "0.10",
        event = "BufReadPost",
      }
    end,
    inject_to_configure = function()
      return {
        builtin = require("statuscol.builtin"),
      }
    end,
    setup = function(config)
      local builtin = config.inject.builtin

      return {
        setopt = true, -- Whether to set the 'statuscolumn' option, may be set to false for those who
        -- want to use the click handlers in their own 'statuscolumn': _G.Sc[SFL]a().
        -- Although I recommend just using the segments field below to build your
        -- statuscolumn to benefit from the performance optimizations in this plugin.
        -- builtin.lnumfunc number string options
        thousands = false, -- or line number thousands separator string ("." / ",")
        relculright = true, -- whether to right-align the cursor line number with 'relativenumber' set
        -- Builtin 'statuscolumn' options
        ft_ignore = lvim.disabled_filetypes, -- lua table with filetypes for which 'statuscolumn' will be unset
        bt_ignore = lvim.disabled_buffer_types, -- lua table with 'buftype' values for which 'statuscolumn' will be unset
        -- Default segments (fold -> sign -> line number + separator), explained below
        segments = {
          -- { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          {
            sign = { namespace = { "gitsign.*" }, maxwidth = 1, colwidth = 1, auto = false },
            click = "v:lua.ScSa",
          },
          {
            sign = { name = { "Dap*" }, auto = true },
            click = "v:lua.ScSa",
          },
          {
            sign = { name = { "Diagnostic" }, colwidth = 1, maxwidth = 1, auto = false },
            click = "v:lua.ScSa",
          },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
      }
    end,
    on_setup = function(config)
      require("statuscol").setup(config.setup)
    end,
  })
end

return M
