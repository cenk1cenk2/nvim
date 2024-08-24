local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local themes = require("telescope.themes")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")

local M = {}

M.terminal_previewer = previewers.new_buffer_previewer({
  title = "Toggleterm Preview",
  get_buffer_by_name = function(_, selection)
    return selection.entry.name
  end,
  define_preview = function(self, selection, _)
    local buf = vim.F.npcall(function()
      return selection.entry.bufnr
    end)

    local lines = { "not available" }
    if buf and vim.api.nvim_buf_is_valid(buf) then
      lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    end

    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
  end,
})

M.displayer = entry_display.create({
  separator = " | ",
  items = {
    { width = 20 },
    { remaining = true },
  },
})

function M.entries()
  return require("toggleterm.terminal").get_all(true)
end

function M.entry_maker(entry)
  return {
    display = function()
      return M.displayer({
        entry.cmd,
        entry.dir,
        entry.direction,
      })
    end,
    entry = entry,
    value = entry.cmd,
    ordinal = ("%s %s %s"):format(entry.cmd, entry.dir, entry.direction),
  }
end

function M.handle_select(prompt_bufnr)
  local selection = action_state.get_selected_entry()

  actions.close(prompt_bufnr)

  if selection then
    selection.entry:toggle()
    selection.entry:focus()
  end
end

function M.handle_delete(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)

  current_picker:delete_selection(function(selection)
    selection.entry:shutdown()
  end)
end

function M.list(opts)
  local layout_opts = themes.get_dropdown({
    sorting_strategy = "ascending",
    prompt_title = "Open terminals",
    layout_strategy = "horizontal",
    layout_config = { width = 0.95, height = 0.9 },
    previewer = M.terminal_previewer,
    finder = finders.new_table({
      results = M.entries(),
      entry_maker = M.entry_maker,
    }),
    attach_mappings = function(_, map)
      map("i", "<esc>", actions.close)
      map("n", "<esc>", actions.close)
      map("n", "q", actions.close)
      map("n", "q", actions.close)

      map("n", "<C-d>", M.handle_delete)
      map("i", "<C-d>", M.handle_delete)

      actions.select_default:replace(M.handle_select)

      return true
    end,
    sorter = sorters.get_fzy_sorter(),
  })

  return pickers.new(opts, layout_opts):find()
end

return require("telescope").register_extension({
  exports = {
    list = M.list,
  },
})
