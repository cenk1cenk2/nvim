-- https://github.com/georgeguimaraes/review.nvim
local M = {}

M.name = "georgeguimaraes/review.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "georgeguimaraes/review.nvim",
        version = "*",
        cmd = { "Review" },
        dependencies = {
          "MunifTanjim/nui.nvim",
        },
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.blink-cmp").name, function(c)
        c.sources.per_filetype.review = function()
          return { "buffer", "path" }
        end

        return c
      end)
    end,
    setup = function()
      return {
        comment_types = {
          note = { icon = nvim.ui.icons.ui.Note },
          suggestion = { icon = nvim.ui.icons.ui.Lightbulb },
          issue = { icon = nvim.ui.icons.ui.Bug },
          praise = { icon = nvim.ui.icons.ui.Check },
        },
        keymaps = {
          popup_cycle_type = "<C-n>",
        },
        export = {
          clipboard = false,
        },
      }
    end,
    on_setup = function(c)
      require("review").setup(c)
      require("review.popup").open = M.popup
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "m" }),
          group = "review",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "c" }),
          function()
            M.add()
          end,
          desc = "review add comment",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "b" }),
          function()
            require("review.comments").file_comment()
          end,
          desc = "review comment on file",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "e" }),
          function()
            require("review.comments").edit_at_cursor()
          end,
          desc = "review edit comment",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "x" }),
          function()
            require("review.comments").delete_at_cursor()
          end,
          desc = "review delete comment",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "j" }),
          function()
            require("review.comments").goto_next()
          end,
          desc = "review next comment",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "k" }),
          function()
            require("review.comments").goto_prev()
          end,
          desc = "review previous comment",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "f" }),
          function()
            M.pick()
          end,
          desc = "review choose comment",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "q" }),
          function()
            M.quickfix()
          end,
          desc = "review set quickfix for comments",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "s" }),
          function()
            M.preview()
          end,
          desc = "review summary",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "P" }),
          function()
            M.export()
          end,
          desc = "review export to clipboard",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "S" }),
          function()
            M.sidekick()
          end,
          desc = "review send to sidekick",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "X" }),
          function()
            require("review").clear()
          end,
          desc = "review archive and clear comments",
        },
      }
    end,
  })
end

M.skill = "code-annotations"

M.types = { "note", "suggestion", "issue", "praise" }

---@param initial_type? "note"|"suggestion"|"issue"|"praise"
---@param initial_text? string
---@param callback fun(comment_type: string|nil, text: string|nil)
function M.popup(initial_type, initial_text, callback)
  local config = require("review.config").get()
  local index = math.max(vim.fn.index(M.types, initial_type or "note") + 1, 1)
  local submitted = false

  local function title()
    local info = config.comment_types[M.types[index]]

    return (" %s %s "):format(info.icon, info.name)
  end

  local function submit(self)
    local text = table.concat(self:lines(), "\n"):gsub("%s+$", "")
    submitted = true
    self:close()
    vim.cmd.stopinsert()
    callback(text ~= "" and M.types[index] or nil, text ~= "" and text or nil)
  end

  local win = require("snacks").win({
    text = initial_text and vim.split(initial_text, "\n") or nil,
    title = title(),
    footer = (" %s type  %s submit "):format(config.keymaps.popup_cycle_type, config.keymaps.popup_submit),
    footer_pos = "center",
    width = nvim.ui.dimensions.float.sm,
    height = nvim.ui.dimensions.float.xs,
    border = nvim.ui.border,
    enter = true,
    bo = {
      buftype = "nofile",
      filetype = "review",
    },
    wo = {
      wrap = true,
      spell = false,
      conceallevel = 2,
    },
    keys = {
      cycle = {
        config.keymaps.popup_cycle_type,
        function(self)
          index = index % #M.types + 1
          self:set_title(title())
        end,
        mode = { "i", "n" },
      },
      submit = { config.keymaps.popup_submit, submit, mode = { "i", "n" } },
      cancel = { config.keymaps.popup_cancel, "close", mode = "n" },
    },
    on_close = function()
      if not submitted then
        callback(nil, nil)
      end
    end,
  })
  pcall(vim.treesitter.start, win.buf, "markdown")

  vim.cmd.startinsert()
end

---@param comment_type? "note"|"suggestion"|"issue"|"praise"
function M.add(comment_type)
  local mode = vim.api.nvim_get_mode().mode

  if mode:match("^[vV\22]") then
    local start_line, end_line = vim.fn.line("v"), vim.fn.line(".")
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    require("review.comments").add_for_range(comment_type, start_line, end_line)

    return
  end

  require("review.comments").add_at_cursor(comment_type)
end

---@return table[]
function M.comments()
  local store = require("review.store")
  store.load()

  return store.get_all()
end

---@param comment table
---@return string
function M.location(comment)
  if comment.line == 0 then
    return comment.file
  end

  local side = (comment.side or "new") == "old" and "~" or ""
  if comment.line_end and comment.line_end ~= comment.line then
    return ("%s:%s%d-%s%d"):format(comment.file, side, comment.line, side, comment.line_end)
  end

  return ("%s:%s%d"):format(comment.file, side, comment.line)
end

---@return string|nil
function M.markdown()
  local comments = M.comments()
  if #comments == 0 then
    return nil
  end

  local lines = {
    "# Review annotations",
    "",
    ("Repository: `%s`"):format(require("review.utils").git_root()),
    "",
  }

  for i, comment in ipairs(comments) do
    local text = comment.text:gsub("\n", "\n   ")
    table.insert(lines, ("%d. **[%s]** `%s` - %s"):format(i, comment.type:upper(), M.location(comment), text))
  end

  return table.concat(lines, "\n")
end

---@return string|nil message the clipboard prompt pointing at the written annotations file
function M.write()
  local markdown = M.markdown()
  if not markdown then
    require("ck.log"):warn("No review comments to export.")
    return nil
  end

  local dir = vim.fs.joinpath(vim.uv.os_tmpdir(), "review-nvim")
  vim.fn.mkdir(dir, "p")
  local file = vim.fs.joinpath(dir, ("%s-%s.md"):format(vim.fs.basename(require("review.utils").git_root()), os.date("%Y%m%d-%H%M%S")))
  vim.fn.writefile(vim.split(markdown, "\n"), file)

  return table.concat({
    ("I annotated the repository. Use the `%s` skill to work through the annotations."):format(M.skill),
    "",
    "@" .. file,
  }, "\n")
end

function M.export()
  local message = M.write()
  if not message then
    return
  end

  vim.fn.setreg("+", message)
  vim.fn.setreg("*", message)
  require("ck.log"):info("Exported %d review comment(s) to clipboard.", #M.comments())
end

function M.preview()
  local markdown = M.markdown()
  if not markdown then
    require("ck.log"):warn("No review comments to preview.")
    return
  end

  require("snacks").win({
    text = vim.split(markdown, "\n"),
    ft = "markdown",
    title = " review ",
    width = nvim.ui.dimensions.float.md,
    height = nvim.ui.dimensions.float.md,
    border = nvim.ui.border,
    bo = {
      modifiable = false,
    },
    wo = {
      spell = false,
      wrap = true,
      conceallevel = 3,
    },
  })
end

function M.sidekick()
  local message = M.write()
  if not message then
    return
  end

  require("sidekick.cli").send({ msg = message })
end

---@param comment table
---@return string|nil
function M.path(comment)
  local root = require("review.utils").git_root()
  if not root then
    return nil
  end

  return vim.fs.joinpath(root, comment.file)
end

function M.quickfix()
  local items = {}
  for _, comment in ipairs(M.comments()) do
    table.insert(items, {
      filename = M.path(comment),
      lnum = math.max(comment.line, 1),
      end_lnum = comment.line_end,
      text = ("[%s] %s"):format(comment.type:upper(), comment.text:gsub("\n", " ")),
    })
  end

  if #items == 0 then
    require("ck.log"):warn("No review comments.")
    return
  end

  vim.fn.setqflist({}, " ", { title = "review comments", items = items })
  vim.cmd("copen")
end

function M.pick()
  local comments = M.comments()
  if #comments == 0 then
    require("ck.log"):warn("No review comments.")
    return
  end

  vim.ui.select(comments, {
    prompt = "Review comments",
    format_item = function(comment)
      return ("[%s] %s %s"):format(comment.type:upper(), M.location(comment), comment.text:gsub("\n", " "))
    end,
  }, function(comment)
    if not comment then
      return
    end

    vim.cmd.edit(vim.fn.fnameescape(M.path(comment)))
    pcall(vim.api.nvim_win_set_cursor, 0, { math.max(comment.line, 1), 0 })
  end)
end

return M
