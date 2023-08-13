local M = {}

local Log = require("lvim.core.log")

function M.rg_interactive()
  local store_key = "TELESCOPE_RG_INTERACTIVE_LAST_ARGS"
  local stored_value = lvim.store.get_store(store_key)

  vim.ui.input({
    prompt = "Pass in rg args:",
    default = stored_value,
  }, function(args)
    if args == nil then
      Log:warn("Nothing to do.")

      return
    end

    lvim.store.set_store(store_key, args)

    local chunks = {}

    for substring in args:gmatch("%S+") do
      table.insert(chunks, substring)
    end

    return require("telescope.builtin").live_grep({
      additional_args = chunks,
    })
  end)
end

function M.rg_string(options)
  options = options or {}
  return require("telescope.builtin").live_grep({
    additional_args = vim.list_extend({ "--no-ignore" }, options.additional_args or {}),
  })
end

function M.rg_dirty()
  require("telescope.builtin").grep_string({
    shorten_path = true,
    word_match = "-w",
    only_sort_text = true,
    search = "",
  })
end

function M.rg_grep_buffer()
  return require("telescope.builtin").live_grep({
    additional_args = { "--no-ignore", "--glob=*" },
    search_dirs = { "%:p" },
  })
end

function M.rg_current_buffer_fuzzy_find()
  return require("telescope.builtin").current_buffer_fuzzy_find({
    additional_args = { "--no-ignore", "--glob=*" },
  })
end

-- Smartly opens either git_files or find_files, depending on whether the working directory is
-- contained in a Git repo.
function M.find_project_files()
  -- local ok = pcall(builtin.git_files)

  -- if not ok then
  require("telescope.builtin").find_files({ previewer = true })
  -- end
end

return M
