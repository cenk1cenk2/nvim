-- https://github.com/neoclide/coc.nvim
local M = {}

local extension_name = "coc"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "neoclide/coc.nvim",
        branch = "release",
        cmd = { "CocList", "CocCommand" },
        keys = { "<Space-G>" },
        enabled = config.active,
      }
    end,
    legacy_setup = {
      coc_start_at_startup = true,
      coc_suggest_disable = 1,
      coc_global_extensions = {
        "coc-lists",
        "coc-marketplace",
        "coc-gitignore",
        "coc-gist",
      },
    },
    wk = function(_, categories)
      return {
        [categories.GIST] = {
          f = { ":CocList gist<CR>", "list gists" },
          i = { ":CocList gitignore<CR>", "generate git ignore" },
          p = { ":CocCommand gist.create<CR>", "post new gist" },
          U = { ":CocCommand gist.update<CR>", "update current gist" },
        },
      }
    end,
  })
end

return M
