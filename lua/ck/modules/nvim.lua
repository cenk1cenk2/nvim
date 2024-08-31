local M = {}

local log = require("ck.log")

function M.rebuild_latest_neovim()
  local term_opts = require("ck.plugins.toggleterm-nvim").generate_defaults_float_terminal({
    cmd = join_paths(get_config_dir(), "/utils/install-latest-neovim.sh"),
    close_on_exit = false,
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

function M.update()
  vim.cmd([[Lazy update]])
  -- vim.cmd([[Lazy sync]])
  M.update_language_servers()
end

function M.update_sync()
  log:warn("Triggered the special update method.")

  xpcall(function()
    require("ck"):update()

    vim.cmd([[Lazy! update]])
    -- vim.cmd([[Lazy! sync]])

    M.update_language_servers_sync()
  end, debug.traceback)

  vim.cmd([[qa!]])
end

function M.rebuild_and_update()
  require("ck"):update()
  M.rebuild_latest_neovim()
  M.update()
end

function M.update_language_servers()
  require("ck.lsp").setup(true)
  vim.cmd([[MasonUpdate]])
  vim.cmd([[MasonToolsUpdate]])
  vim.cmd([[TSUpdate]])
end

function M.update_language_servers_sync()
  require("ck.lsp").setup(true)
  vim.cmd([[MasonUpdate]])
  vim.cmd([[MasonToolsUpdateSync]])
  vim.cmd([[TSUpdateSync]])
end

function M.setup()
  require("ck.setup").init({
    commands = {
      {
        "LvimHeadlessUpdate",
        function()
          M.update_sync()
        end,
      },
      {
        "NvimHeadlessUpdate",
        function()
          M.update_sync()
        end,
      },
    },
    wk = function(_, categories, fn)
      ---@type WKMappings
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
            require("ck"):update()
          end,
          desc = "git update config repository",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, "Q" }),
          function()
            require("ck.config"):reload()
          end,
          desc = "reload configuration",
        },

        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS }),
          group = "logs",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS, "o" }),
          function()
            nvim.fn.toggle_log_view(require("ck.log"):get_log_filepath())
          end,
          desc = "view log",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS, "e" }),
          function()
            vim.cmd(("edit %s"):format(require("ck.log"):get_log_filepath()))
          end,
          desc = "open the logfile",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS, "X" }),
          function()
            require("ck.log"):truncate_logfile(require("ck.log"):get_log_filepath())
            require("ck.log"):truncate_logfile(require("ck.log"):get_nvim_logfile_path())
          end,
          desc = "delete the logfiles",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS, "n" }),
          function()
            nvim.fn.toggle_log_view(require("ck.log"):get_nvim_logfile_path())
          end,
          desc = "view neovim log",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, categories.LOGS, "N" }),
          function()
            vim.cmd(("edit %s"):format(require("ck.log"):get_nvim_logfile_path()))
          end,
          desc = "open the neovim logfile",
        },
      }
    end,
  })
end

return M
