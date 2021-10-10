local M = {}

local extension_name = 'spectre'

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      normal_mode = {['as'] = [[:lua require('spectre').open_file_search()<cr>]], ['sa'] = [[:lua require('spectre').open()<cr>]]},
      visual_mode = {['as'] = [[:lua require('spectre').open_file_search()<cr>]], ['sa'] = [[:lua require('spectre').open()<cr>]]}
    },
    setup = {
      color_devicons = true,
      highlight = {ui = 'String', search = 'SpectreChange', replace = 'SpectreDelete'},
      mapping = {
        ['delete_line'] = {map = 'D', cmd = '<cmd>lua require(\'spectre\').delete()<CR>', desc = 'toggle current item'},
        ['enter_file'] = {map = '<cr>', cmd = '<cmd>lua require(\'spectre.actions\').select_entry()<CR>', desc = 'goto current file'},
        ['send_to_qf'] = {map = 'Q', cmd = '<cmd>lua require(\'spectre.actions\').send_to_qf()<CR>', desc = 'send all item to quickfix'},
        ['replace_cmd'] = {map = 'C', cmd = '<cmd>lua require(\'spectre.actions\').replace_cmd()<CR>', desc = 'input replace vim command'},
        ['show_option_menu'] = {map = 'o', cmd = '<cmd>lua require(\'spectre\').show_options()<CR>', desc = 'show option'},
        ['run_replace'] = {map = 'R', cmd = '<cmd>lua require(\'spectre.actions\').run_replace()<CR>', desc = 'replace all'},
        ['change_view_mode'] = {map = 'v', cmd = '<cmd>lua require(\'spectre\').change_view()<CR>', desc = 'change result view mode'},
        ['toggle_ignore_case'] = {map = 'zi', cmd = '<cmd>lua require(\'spectre\').change_options(\'ignore-case\')<CR>', desc = 'toggle ignore case'},
        ['toggle_ignore_hidden'] = {map = 'zh', cmd = '<cmd>lua require(\'spectre\').change_options(\'hidden\')<CR>', desc = 'toggle search hidden'}
        -- you can put your mapping here it only have normal
      },
      find_engine = {
        -- rg is map with finder_cmd
        ['rg'] = {
          cmd = 'rg',
          -- default args
          args = {'--color=never', '--no-heading', '--with-filename', '--line-number', '--column'},
          options = {
            ['ignore-case'] = {value = '--ignore-case', icon = '[I]', desc = 'ignore case'},
            ['hidden'] = {value = '--hidden', desc = 'hidden file', icon = '[H]'}
            -- you can put any option you want here it can toggle with
            -- show_option function
          }
        }
      },
      replace_engine = {['sed'] = {cmd = 'sed', args = nil}, options = {['ignore-case'] = {value = '--ignore-case', icon = '[I]', desc = 'ignore case'}}},
      default = {
        find = {
          -- pick one of item that find_engine
          cmd = 'rg',
          options = {'ignore-case'}
        },
        replace = {
          -- pick one of item that replace_engine
          cmd = 'sed'
        }
      },
      replace_vim_cmd = 'cfdo',
      is_open_target_win = true, -- open file on opener window
      is_insert_mode = false -- start open panel on is_insert_mode
    }
  }
end

function M.setup()
  local extension = require(extension_name)
  extension.setup(lvim.extensions[extension_name].setup)

  require('utils.command').wrap_to_command({
    {'FindAndReplace', [[lua require('spectre').open()]]},
    {'FindAndReplaceVisual', [[lua require('spectre').open_visual()]]},
    {'FindAndReplaceInBuffer', [[lua require('spectre').open_file_search()]]}
  })

  require('keymappings').append_to_defaults(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done(extension) end
end

return M
