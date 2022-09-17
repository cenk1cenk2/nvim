local M = {}

function M.setup()
  require("utils.setup").run {
    autocmds = {
      {
        { "TermOpen" },
        {
          group = "__TERMINAL",
          pattern = "*",
          command = "nnoremap <buffer><LeftRelease> <LeftRelease>i",
        },
      },
    },
  }
end

return M
