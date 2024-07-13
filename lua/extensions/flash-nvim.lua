-- https://github.com/folke/flash.nvim
local M = {}

local extension_name = "flash_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "folke/flash.nvim",
        keys = { "f", "F", "t", "T", "r", "dr", "yr" },
        -- event = "BufReadPost",
      }
    end,
    setup = function()
      return {
        -- labels = "abcdefghijklmnopqrstuvwxyz",
        labels = lvim.selection_chars,
        search = {
          -- search/jump in all windows
          multi_window = false,
          -- search direction
          forward = true,
          -- when `false`, find only matches in the given direction
          wrap = true,
          ---@type Flash.Pattern.Mode
          -- Each mode will take ignorecase and smartcase into account.
          -- * exact: exact match
          -- * search: regular search
          -- * fuzzy: fuzzy search
          -- * fun(str): custom function that returns a pattern
          --   For example, to only match at the beginning of a word:
          --   mode = function(str)
          --     return "\\<" .. str
          --   end,
          mode = "exact",
          -- behave like `incsearch`
          incremental = false,
          -- Excluded filetypes and custom window filters
          ---@type (string|fun(win:window))[]
          exclude = {
            "notify",
            "cmp_menu",
            "noice",
            "flash_prompt",
            function(win)
              -- exclude non-focusable windows
              return not vim.api.nvim_win_get_config(win).focusable
            end,
          },
          -- Optional trigger character that needs to be typed before
          -- a jump label can be used. It's NOT recommended to set this,
          -- unless you know what you're doing
          trigger = "",
          -- max pattern length. If the pattern length is equal to this
          -- labels will no longer be skipped. When it exceeds this length
          -- it will either end in a jump or terminate the search
          max_length = nil, ---@type number?
        },
        jump = {
          -- save location in the jumplist
          jumplist = true,
          -- jump position
          pos = "start", ---@type "start" | "end" | "range"
          -- add pattern to search history
          history = false,
          -- add pattern to search register
          register = false,
          -- clear highlight after jump
          nohlsearch = false,
          -- automatically jump when there is only one match
          autojump = true,
          -- You can force inclusive/exclusive jumps by setting the
          -- `inclusive` option. By default it will be automatically
          -- set based on the mode.
          inclusive = nil, ---@type boolean?
          -- jump position offset. Not used for range jumps.
          -- 0: default
          -- 1: when pos == "end" and pos < current position
          offset = nil, ---@type number
        },
        label = {
          -- allow uppercase labels
          uppercase = true,
          -- add a label for the first match in the current window.
          -- you can always jump to the first match with `<CR>`
          current = true,
          -- show the label after the match
          after = true, ---@type boolean|number[]
          -- show the label before the match
          before = false, ---@type boolean|number[]
          -- position of the label extmark
          style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
          -- flash tries to re-use labels that were already assigned to a position,
          -- when typing more characters. By default only lower-case labels are re-used.
          reuse = "lowercase", ---@type "lowercase" | "all"
          -- for the current window, label targets closer to the cursor first
          distance = true,
        },
        highlight = {
          -- show a backdrop with hl FlashBackdrop
          backdrop = false,
          -- Highlight the search matches
          matches = true,
          -- extmark priority
          priority = 5000,
          groups = {
            match = "FlashMatch",
            current = "FlashCurrent",
            backdrop = "FlashBackdrop",
            label = "FlashLabel",
          },
        },
        -- action to perform when picking a label.
        -- defaults to the jumping logic depending on the mode.
        ---@type fun(match:Flash.Match, state:Flash.State)|nil
        action = nil,
        -- initial pattern to use when opening flash
        pattern = "",
        -- When `true`, flash will try to continue the last search
        continue = false,
        -- You can override the default options for a specific mode.
        -- Use it with `require("flash").jump({mode = "forward"})`
        ---@type table<string, Flash.Config>
        modes = {
          -- options used when flash is activated through
          -- a regular search with `/` or `?`
          search = {
            enabled = false, -- enable flash for search
            highlight = { backdrop = false },
            jump = { autojump = true, history = true, register = true, nohlsearch = true },
            search = {
              -- `forward` will be automatically set to the search direction
              -- `mode` is always set to `search`
              -- `incremental` is set to `true` when `incsearch` is enabled
            },
          },
          -- options used when flash is activated through
          -- `f`, `F`, `t`, `T`, `;` and `,` motions
          char = {
            enabled = true,
            -- by default all keymaps are enabled, but you can disable some of them,
            -- by removing them from the list.
            keys = { "f", "F", "t", "T", ";", "," },
            search = { wrap = false },
            highlight = { backdrop = false },
            jump = { register = false, autojump = true },
            multi_line = false,
            -- `left` and `right` are always left and right.
            char_actions = function(motion)
              return {
                [";"] = "next", -- set to `right` to always go right
                [","] = "prev", -- set to `left` to always go left
                -- clever-f style
                [motion:lower()] = "next",
                [motion:upper()] = "prev",
                -- jump2d style: same case goes next, opposite case goes prev
                -- [motion] = "next",
                -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
              }
            end,
          },
          -- options used for treesitter selections
          -- `require("flash").treesitter()`
          treesitter = {
            labels = lvim.selection_chars,
            jump = { pos = "range" },
            highlight = {
              label = { before = true, after = true, style = "inline" },
              backdrop = false,
              matches = false,
            },
          },
          -- options used for remote flash
          remote = {
            remote_op = { restore = true, motion = true },
          },
        },
        -- options for the floating window that shows the prompt,
        -- for regular jumps
        prompt = {
          enabled = true,
          prefix = { { "⚡", "FlashPromptIcon" } },
          win_config = {
            relative = "editor",
            width = 1, -- when <=1 it's a percentage of the editor width
            height = 1,
            row = -1, -- when negative it's an offset from the bottom
            col = 0, -- when negative it's an offset from the right
            zindex = 1000,
          },
        },
        -- options for remote operator pending mode
        remote_op = {
          -- restore window views and cursor position
          -- after doing a remote operation
          restore = false,
          -- For `jump.pos = "range"`, this setting is ignored.
          -- `true`: always enter a new motion when doing a remote operation
          -- `false`: use the window's cursor position and jump target
          -- `nil`: act as `true` for remote windows, `false` for the current window
          motion = false,
        },
      }
    end,
    on_setup = function(config)
      require("flash").setup(config.setup)
    end,
    on_done = function()
      -- to use this, make sure to set `opts.modes.char.enabled = false`
      local Config = require("flash.config")
      local Char = require("flash.plugins.char")
      for _, motion in ipairs({ "f", "t", "F", "T" }) do
        vim.keymap.set({ "n", "x", "o" }, motion, function()
          require("flash").jump(Config.get({
            mode = "char",
            search = {
              mode = Char.mode(motion),
              max_length = 1,
            },
          }, Char.motions[motion]))
        end)
      end
    end,
    keymaps = {
      {
        { "n", "x", "o" },

        ["ss"] = {
          function()
            require("flash").jump({
              search = { wrap = true, multi_window = false },
            })
          end,
          { desc = "flash" },
        },

        ["s"] = {
          function()
            require("flash").jump({
              pattern = ".", -- initialize pattern with any char
              search = {
                wrap = true,
                mode = function(str)
                  return "\\<" .. str
                end,
              },
            })
          end,
          { desc = "flash to word." },
        },

        ["S"] = {
          function()
            require("flash").treesitter({})
          end,
          { desc = "flash treesitter" },
        },
      },

      {
        { "o" },

        ["r"] = {
          function()
            require("flash").remote({})
          end,
          { desc = "remote flash" },
        },
      },
    },
  })
end

return M
