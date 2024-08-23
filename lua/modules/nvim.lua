local M = {}

local log = require("lvim.log")

function M.rebuild_latest_neovim()
  local term_opts = require("extensions.toggleterm-nvim").generate_defaults_float_terminal({
    cmd = join_paths(get_config_dir(), "/utils/install-latest-neovim.sh"),
    close_on_exit = false,
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

function M.update()
  vim.cmd([[Lazy sync]])
  M.update_language_servers()
end

function M.update_sync()
  log:warn("Triggered the special update method.")

  local _, err = pcall(function()
    require("lvim"):update()

    vim.cmd([[Lazy! sync]])

    M.update_language_servers_sync()

    vim.api.nvim_create_autocmd("User", {
      pattern = "MasonUpdateAllComplete",
      callback = function()
        vim.cmd([[qa!]])
      end,
    })
  end)

  if err then
    vim.cmd([[qa!]])

    log:error(err)
  end
end

function M.rebuild_and_update()
  require("lvim"):update()
  M.rebuild_latest_neovim()
  M.update()
end

function M.update_language_servers()
  require("lvim.lsp").setup(true)
  vim.cmd([[MasonUpdate]])
  require("mason-update-all").update_all()
end

function M.update_language_servers_sync()
  require("lvim.lsp").setup(true)
  M.update_language_servers()
  vim.cmd([[TSUpdateSync]])
end

function M.setup()
  require("utils.setup").init({
    name = "rebuild",
    commands = {
      {
        name = "LvimHeadlessUpdate",
        fn = function()
          M.update_sync()
        end,
      },
    },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.NEOVIM, "r" }),
          function()
            M.rebuild_latest_neovim()
          end,
          desc = "install latest neovim",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, "l" }),
          function()
            M.update_language_servers()
          end,
          desc = "update language servers",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, "u" }),
          function()
            M.update()
          end,
          desc = "update",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, "R" }),
          function()
            M.rebuild_and_update()
          end,
          desc = "rebuild and update everything",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, "p" }),
          function()
            require("lvim"):update()
          end,
          desc = "git update config repository",
        },
      }
    end,
  })
end

return M
