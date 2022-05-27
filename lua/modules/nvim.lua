local M = {}

local Log = require "lvim.core.log"

function M.reinstall_lsp_servers()
  vim.cmd [[LspStop]]

  for _, server_name in ipairs(lvim.lsp.ensure_installed) do
    local server_available, server = require("nvim-lsp-installer.servers").get_server(server_name)

    if server_available then
      if server:is_installed() then
        server:uninstall()

        Log:info(string.format("Uninstalling [%s]", server.name))
      end

      server:install()

      Log:info(string.format("Installing [%s]", server.name))

      server:install()
    else
      Log:warn("Requested LSP is not available: " .. server_name)
    end
  end

  vim.cmd [[LspInstallInfo]]

  vim.cmd [[LspStart]]
end

function M.rebuild_latest_neovim()
  local term_opts = vim.tbl_deep_extend("force", lvim.builtin.terminal, {
    cmd = join_paths(get_config_dir(), "/utils/install-latest-neovim.sh"),
    open_mapping = lvim.log.viewer.layout_config.open_mapping,
    direction = lvim.log.viewer.layout_config.direction,
    -- TODO: this might not be working as expected
    size = lvim.log.viewer.layout_config.size,
    float_opts = lvim.log.viewer.layout_config.float_opts,
    close_on_exit = false,
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

function M.rebuild_and_update()
  M.rebuild_latest_neovim()
  -- M.reinstall_lsp_servers()

  vim.cmd [[PackerSync]]
  vim.cmd [[PackerCompile]]
  vim.cmd [[LvimCacheReset]]
end

function M.setup()
  require("utils.command").create_commands {
    {
      name = "RebuildAndUpdate",
      fn = function()
        M.rebuild_and_update()
      end,
    },
    {
      name = "RebuildLatestNeovim",
      fn = function()
        M.rebuild_latest_neovim()
      end,
    },
    {
      name = "LspInstallerReinstallAll",
      fn = function()
        M.reinstall_lsp_servers()
      end,
    },
  }
end

return M
