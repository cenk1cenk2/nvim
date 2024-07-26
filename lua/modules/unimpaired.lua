local M = {}

local function create_array(count, item)
  local array = {}
  for _ = 1, count do
    table.insert(array, item)
  end
  return array
end

local function paste_blank_line(line)
  local lines = create_array(vim.v.count1, "")
  vim.api.nvim_buf_set_lines(0, line, line, true, lines)
end

function M.paste_blank_line_above()
  paste_blank_line(vim.fn.line(".") - 1)
end

function M.paste_blank_line_below()
  paste_blank_line(vim.fn.line("."))
end

function M.setup()
  require("utils.setup").init({
    name = "unimpaired",
    keymaps = function()
      return {
        {
          "oo",
          function()
            M.paste_blank_line_below()
          end,
          desc = "paste blank line below",
          mode = { "n" },
        },
        {
          "OO",
          function()
            M.paste_blank_line_above()
          end,
          desc = "paste blank line above",
          mode = { "n" },
        },
      }
    end,
  })
end

return M
