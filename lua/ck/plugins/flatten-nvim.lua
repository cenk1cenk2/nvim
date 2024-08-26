-- https://github.com/willothy/flatten.nvim
local M = {}

M.name = "willothy/flatten.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "willothy/flatten.nvim",
        lazy = false,
        priority = 1001,
      }
    end,
    setup = function()
      return {
        callbacks = {
          should_block = function(argv)
            return vim.tbl_contains(argv, "-b")
          end,
          pre_open = function()
            -- Close toggleterm when an external open request is received
            -- require("toggleterm").toggle(0)
          end,
          post_open = function(bufnr, winnr, ft, is_blocking)
            if is_blocking then
              -- If the file is a git commit, create one-shot autocmd to delete it on write
              -- If you just want the toggleable terminal integration, ignore this bit and only use the
              -- code in the else block
              vim.api.nvim_create_autocmd("BufWritePost", {
                buffer = bufnr,
                once = true,
                callback = function()
                  -- This is a bit of a hack, but if you run bufdelete immediately
                  -- the shell can occasionally freeze
                  -- if vim.tbl_contains(fts, ft) then
                  vim.defer_fn(function()
                    vim.api.nvim_buf_delete(bufnr, {})
                  end, 50)
                  -- end
                end,
              })
              -- else
              -- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
              -- This gives the appearance of the window opening independently of the terminal
              -- require("toggleterm").toggle(0)
              -- vim.api.nvim_set_current_win(winnr)
            end
          end,
          block_end = function()
            -- After blocking ends (for a git commit, etc), reopen the terminal
            -- require("toggleterm").toggle(0)
          end,
        },
        block_for = {
          gitcommit = true,
          [""] = true,
        },
        -- Window options
        window = {
          -- Options:
          -- current        -> open in current window (default)
          -- alternate      -> open in alternate window (recommended)
          -- tab            -> open in new tab
          -- split          -> open in split
          -- vsplit         -> open in vsplit
          -- func(new_bufs, argv) -> only open the files, allowing you to handle window opening yourself.
          -- Argument is an array of buffer numbers representing the newly opened files.
          -- open = "alternate",
          open = "alternate",
          -- Affects which file gets focused when opening multiple at once
          -- Options:
          -- "first"        -> open first file of new files (default)
          -- "last"         -> open last file of new files
          focus = "first",
        },
        -- Override this function to use a different socket to connect to the host
        -- On the host side this can return nil or the socket address.
        -- On the guest side this should return the socket address
        -- or a non-zero channel id from `sockconnect`
        -- flatten.nvim will detect if the address refers to this instance of nvim, to determine if this is a host or a guest
        pipe_path = require("flatten").default_pipe_path,
        -- The `default_pipe_path` will treat the first nvim instance within a single kitty/wezterm session as the host
        -- You can configure this behaviour using the following:
        one_per = {
          kitty = false, -- Flatten all instance in the current Kitty session
          wezterm = false, -- Flatten all instance in the current Wezterm session
        },
      }
    end,
    on_setup = function(c)
      require("flatten").setup(c)
    end,
  })
end

return M
