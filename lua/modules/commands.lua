local M = {}
local log = require("lvim.log")

function M.setup()
  require("utils.setup").init({
    name = "commands",
    commands = {
      {
        name = "QuickFixToggle",
        fn = function()
          local qf = vim.tbl_filter(function(win)
            if win.quickfix == 1 then
              return true
            end

            return false
          end, vim.fn.getwininfo())

          if vim.tbl_isempty(qf) then
            vim.cmd("botright copen")
          else
            vim.cmd("cclose")
          end
        end,
      },
      {
        name = "LvimToggleFormatOnSave",
        fn = function()
          require("lvim.lsp.format").toggle_format_on_save()
        end,
      },
      {
        name = "LvimCacheReset",
        fn = function()
          require("lvim.loader").reset_cache()
        end,
      },
      {
        name = "LvimReload",
        fn = function()
          require("lvim.config"):reload()
        end,
      },
      {
        name = "LvimUpdate",
        fn = function()
          require("lvim"):update()
        end,
      },
      {
        name = "LvimVersion",
        fn = function()
          print(require("lvim.version").get_lvim_version())
        end,
      },
      {
        name = "LvimOpenlog",
        fn = function()
          vim.fn.execute("edit " .. require("lvim.log").get_path())
        end,
      },
    },
  })
end

return M
