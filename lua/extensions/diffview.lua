local M = {}

local extension_name = 'diffview'

function M.config()

  lvim.extensions[extension_name] = {active = true, on_config_done = nil}

  local status_ok, plugin_config = pcall(require, 'diffview.config')
  if not status_ok then return end
  local cb = plugin_config.diffview_callback

  lvim.extensions[extension_name] = vim.tbl_extend('force', lvim.extensions[extension_name], {
    setup = {
      diff_binaries = false, -- Show diffs for binaries
      use_icons = true, -- Requires nvim-web-devicons
      file_panel = {width = 35},
      key_bindings = {
        -- The `view` bindings are active in the diff buffers, only when the current
        -- tabpage is a Diffview.
        view = {
          ['<tab>'] = cb('select_next_entry'), -- Open the diff for the next file
          ['<s-tab>'] = cb('select_prev_entry'), -- Open the diff for the previous file
          ['<leader>e'] = cb('focus_files'), -- Bring focus to the files panel
          ['<leader>b'] = cb('toggle_files') -- Toggle the files panel.
        },
        file_panel = {
          ['j'] = cb('next_entry'), -- Bring the cursor to the next file entry
          ['<down>'] = cb('next_entry'),
          ['k'] = cb('prev_entry'), -- Bring the cursor to the previous file entry.
          ['<up>'] = cb('prev_entry'),
          ['<cr>'] = cb('select_entry'), -- Open the diff for the selected entry.
          ['o'] = cb('select_entry'),
          ['R'] = cb('refresh_files'), -- Update stats and entries in the file list.
          ['<tab>'] = cb('select_next_entry'),
          ['<s-tab>'] = cb('select_prev_entry'),
          ['<leader>e'] = cb('focus_files'),
          ['<leader>b'] = cb('toggle_files')
        }
      }
    }
  })
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings['g']['a'] = {':DiffviewFileHistory<CR>', 'buffer commits'}
  lvim.builtin.which_key.mappings['g']['d'] = {':DiffviewOpen<CR>', 'diff view open'}
  lvim.builtin.which_key.mappings['g']['D'] = {':DiffviewClose<CR>', 'diff view close'}

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done(extension) end
end

return M
