local M = {}

function M.rebuild_latest_neovim()
  local term_opts = require("extensions.toggleterm-nvim").generate_defaults_float_terminal({
    cmd = join_paths(get_config_dir(), "/utils/install-latest-neovim.sh"),
    close_on_exit = false,
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

function M.rebuild_and_update()
  M.rebuild_latest_neovim()

  vim.cmd([[Lazy sync]])
end

function M.update_language_servers()
  vim.cmd([[MasonToolsUpdate]])
  vim.cmd([[Mason]])
end

function M.setup()
  require("utils.setup").init({
    name = "rebuild",
    wk = function(_, categories)
      return {
        [categories.BUILD] = {
          r = {
            function()
              M.rebuild_latest_neovim()
            end,
            "install latest neovim",
          },
          u = {
            function()
              M.update_language_servers()
            end,
            "update language servers",
          },
          U = {
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
