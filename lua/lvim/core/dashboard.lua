local M = {}

local utils = require "lvim.utils"

M.config = function(config)
  lvim.builtin.dashboard = {
    active = true,
    on_config_done = nil,
    search_handler = "telescope",
    disable_at_vim_enter = 0,
    session_directory = utils.join_paths(get_cache_dir(), "sessions"),
    custom_header = { "@cenk1cenk2/nvim" },
    custom_section = {
      a = { description = { "  Load Last Session" }, command = "SessionLoad" },
      b = { description = { "⧗  Sessions" }, command = "CocList sessions" },
      c = { description = { "  Find File" }, command = "Telescope find_files" },
      d = { description = { "  File Browser" }, command = "Telescope file_browser" },
      e = {
        description = { "  New File" },
        command = ":ene!",
      },
      f = {
        description = { "  Recent Projects" },
        command = "Telescope projects",
      },
      g = { description = { "  Recently Used Files" }, command = "Telescope oldfiles" },
      h = { description = { "  Configuration" }, command = ":e " .. config.get_user_config_path() },
      q = { description = { "  Quit" }, command = "qa!" },
    },
  }
  lvim.builtin.which_key.mappings[";"] = { "<cmd>Dashboard<CR>", "Dashboard" }
end

M.setup = function()
  vim.g.dashboard_disable_at_vimenter = lvim.builtin.dashboard.disable_at_vim_enter

  vim.g.dashboard_custom_header = lvim.builtin.dashboard.custom_header

  vim.g.dashboard_default_executive = lvim.builtin.dashboard.search_handler

  vim.g.dashboard_custom_section = lvim.builtin.dashboard.custom_section

  vim.g.dashboard_session_directory = lvim.builtin.dashboard.session_directory

  local lvim_version = require("lvim.bootstrap"):get_version "short"
  local nvim_version = require("lvim.bootstrap"):get_nvim_version()
  local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/start", "*", 0, 1)

  local footer = { "Neovim loaded: " .. num_plugins_loaded .. " plugins " }

  if lvim_version then
    table.insert(footer, 2, "")
    table.insert(footer, 2, lvim_version)
  end

  if nvim_version then
    table.insert(footer, 4, "")
    table.insert(footer, 5, nvim_version)
  end

  local text = require "lvim.interface.text"
  vim.g.dashboard_custom_footer = text.align_center({ width = 0 }, footer, 0.49) -- Use 0.49 as  counts for 2 characters

  require("lvim.core.autocmds").define_augroups {
    _dashboard = {
      -- seems to be nobuflisted that makes my stuff disappear will do more testing
      {
        "FileType",
        "dashboard",
        "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= ",
      },
      -- { "FileType", "dashboard", "set showtabline=0 | autocmd BufLeave <buffer> set showtabline=1" },
      { "FileType", "dashboard", "nnoremap <silent> <buffer> q :q<CR>" },
    },
  }

  if lvim.builtin.dashboard.on_config_done then
    lvim.builtin.dashboard.on_config_done()
  end
end

return M
