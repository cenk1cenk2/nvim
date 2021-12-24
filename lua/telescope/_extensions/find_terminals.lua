local _, finders = pcall(require, "telescope.finders")
local _, pickers = pcall(require, "telescope.pickers")
local _, sorters = pcall(require, "telescope.sorters")
local _, themes = pcall(require, "telescope.themes")
local _, previewers = pcall(require, "telescope.previewers")
local _, actions = pcall(require, "telescope.actions")
local _, entry_display = pcall(require, "telescope.pickers.entry_display")
local _, action_state = pcall(require, "telescope.actions.state")
local _, terminal = pcall(require, "toggleterm.terminal")

local M = {}

M.displayer = entry_display.create {
  separator = " | ",
  items = {
    { width = 20 },
    { remaining = true },
  },
}

function M.entries()
  return terminal.get_all(true)
end

function M.entry_maker(entry)
  return {
    display = function()
      return M.displayer {
        entry.cmd,
        entry.dir,
        entry.direction,
      }
    end,
    entry = entry,
    value = entry.cmd,
    ordinal = entry.cmd .. " " .. entry.dir,
  }
end

function M.handle_select(prompt_bufnr)
  local selection = action_state.get_selected_entry(prompt_bufnr)

  actions.close(prompt_bufnr)

  if selection then
    selection.entry:toggle()
  end
end

function M.handle_delete(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)

  current_picker:delete_selection(function(selection)
    selection.entry:shutdown()
  end)
end

function M.list(opts)
  local layout_opts = themes.get_dropdown {
    sorting_strategy = "ascending",
    prompt_title = "Open terminals",
    layout_config = { prompt_position = "bottom", width = 0.5, height = 24 },
    finder = finders.new_table {
      results = M.entries(),
      entry_maker = M.entry_maker,
    },
    attach_mappings = function(_, map)
      map("i", "<esc>", actions._close)
      map("n", "<esc>", actions._close)
      map("n", "q", actions._close)
      map("n", "q", actions._close)

      map("n", "<C-d>", M.handle_delete)
      map("i", "<C-d>", M.handle_delete)

      actions.select_default:replace(M.handle_select)

      return true
    end,
    sorter = sorters.get_fzy_sorter(),
  }

  return pickers.new(opts, layout_opts):find()
end

return require("telescope").register_extension {
  exports = {
    list = M.list,
  },
}
