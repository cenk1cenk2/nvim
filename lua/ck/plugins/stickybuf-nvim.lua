-- https://github.com/stevearc/stickybuf.nvim
local M = {}

M.name = "stevearc/stickybuf.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "stevearc/stickybuf.nvim",
        event = "BufWinEnter",
      }
    end,
    setup = function()
      return {
        get_auto_pin = function(bufnr)
          local buftype = vim.bo[bufnr].buftype
          local filetype = vim.bo[bufnr].filetype
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if buftype == "help" or buftype == "quickfix" then
            return "buftype"
          elseif buftype == "prompt" then
            return "bufnr"
          elseif vim.tbl_contains({ "aerial", "nerdtree", "neotest-summary", "DiffviewFiles" }, filetype) then
            -- "neo-tree",
            return "filetype"
          elseif bufname:match("Neogit.*Popup") then
            return "bufnr"
          elseif filetype == "defx" and (vim.wo.winfixwidth or vim.wo.winfixheight) then
            -- Only pin defx if it was opened as a split (has fixed height/width)
            return "filetype"
          elseif filetype == "fern" and (vim.wo.winfixwidth or vim.wo.winfixheight) then
            -- Only pin fern if it was opened as a split (has fixed height/width)
            return "filetype"
          elseif vim.tbl_contains({ "NeogitStatus", "NeogitLog", "NeogitGitCommandHistory" }, filetype) then
            if vim.fn.winnr("$") > 1 then
              return "filetype"
            end
          end
        end,
      }
    end,
    on_setup = function(c)
      require("stickybuf").setup(c)
    end,
  })
end

return M
