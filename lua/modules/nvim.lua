local M = {}

local Log = require("lvim.core.log")

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
  Log:warn("Triggered the special update method.")

  vim.cmd([[Lazy! sync]])
  M.update_language_servers_sync()

  vim.api.nvim_create_autocmd("User", {
    pattern = "MasonUpdateAllComplete",
    callback = function()
      vim.cmd([[qa!]])
    end,
  })
end

function M.rebuild_and_update()
  M.rebuild_latest_neovim()
  M.update()
end

function M.update_language_servers()
  require("lvim.lsp").setup(true)
  require("mason-update-all").update_all()
end

function M.update_language_servers_sync()
  require("lvim.lsp").setup(true)
  M.update_language_servers()
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
    wk = function(_, categories)
      return {
        [categories.BUILD] = {
          r = {
            function()
              M.rebuild_latest_neovim()
            end,
            "install latest neovim",
          },
          l = {
            function()
              M.update_language_servers()
            end,
            "update language servers",
          },
          u = {
            function()
              M.update()
            end,
            "update",
          },
          R = {
            function()
              M.rebuild_and_update()
            end,
            "rebuild and update everything",
          },
          p = { ":LvimUpdate<CR>", "git update config repository" },
        },
      }
    end,
  })
end

return M
