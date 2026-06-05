-- https://github.com/willothy/flatten.nvim
local M = {}

local log = require("ck.log")

M.name = "willothy/flatten.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "willothy/flatten.nvim",
        lazy = false,
        priority = 1100,
        cond = not is_headless(),
        -- https://github.com/willothy/flatten.nvim/issues/106
        -- commit = "d3e3529c23740a5411da3614e1ca3f35eb968fc9",
      }
    end,
    setup = function()
      return {
        one_per = {
          kitty = false, -- Flatten all instance in the current Kitty session
          wezterm = false, -- Flatten all instance in the current Wezterm session
        },
        hooks = {
          guest_data = function()
            return require("ck.modules.flatten").guest_data()
          end,
          pre_open = function(opts)
            require("ck.modules.flatten").pre_open(opts)
          end,
          should_block = function(argv)
            if vim.tbl_contains(argv, "--headless") then
              return false
            elseif vim.tbl_contains(argv, "-b") then
              log:warn("Waiting for parent instance to return the file.")

              return true
            end

            return false
          end,
          block_end = function()
            log:info("File returned to the blocking neovim instance.")
          end,
          post_open = function(opts)
            if os.execute([[tmux popup -c $(tmux display-message -pt "$TMUX_PANE" '#{client_tty}') -C]]) then
              log:info("Closed popup windows.")
            end

            if opts.is_blocking then
              log:info("Blocking for another neovim instance...")
            end
          end,
        },
        block_for = {
          gitcommit = true,
          gitrebase = true,
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
      }
    end,
    on_setup = function(c)
      require("flatten").setup(c)
    end,
  })
end

return M
