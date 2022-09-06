local M = {}

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

  vim.cmd [[PackerSync]]
  vim.cmd [[PackerCompile]]
  vim.cmd [[LvimCacheReset]]
end

return M
