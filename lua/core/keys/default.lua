local log = require("core.log")

---@type KeymapMappings
return {
  -- disable help
  {
    "<F1>",
    "<Nop>",
    mode = { "n", "v", "x" },
  },
  -- to blachole
  {
    "c",
    [["_c]],
    mode = { "n", "v", "x" },
  },
  {
    "C",
    [["_C]],
    mode = { "n", "v", "x" },
  },
  {
    "x",
    [["_x]],
    mode = { "n", "v", "x" },
  },
  {
    "P",
    [["_dp]],
    mode = { "v", "x" },
  },
  {
    "p",
    [["_dP]],
    mode = { "v", "x" },
  },
  -- tab control
  {
    "<M-t>",
    function()
      vim.cmd([[tabnew]])
    end,
    desc = "create tab",
    mode = { "n", "v", "x" },
  },
  {
    "<M-q>",
    function()
      vim.cmd([[tabclose]])
    end,
    desc = "close tab",
    mode = { "n", "v", "x" },
  },
  {
    "<M-S-l>",
    function()
      vim.cmd([[tabnext]])
    end,
    desc = "next tab",
    mode = { "n", "v", "x" },
  },
  {
    "<M-S-h>",
    function()
      vim.cmd([[tabprevious]])
    end,
    desc = "prev tab",
    mode = { "n", "v", "x" },
  },
  -- split to window
  {
    "<C-t>",
    "<C-w><C-o>",
    mode = { "n", "v", "x" },
  },
  {
    "<A-Up>",
    "<C-\\><C-N><C-w>k",
    mode = { "i" },
  },
  {
    "<A-Down>",
    "<C-\\><C-N><C-w>j",
    mode = { "i" },
  },
  {
    "<A-Left>",
    "<C-\\><C-N><C-w>h",
    mode = { "i" },
  },
  {
    "<A-Right>",
    "<C-\\><C-N><C-w>l",
    mode = { "i" },
  },
  -- escape with c-c
  -- {
  --   "<C-c>",
  --   "<ESC>",
  --   mode = { "i" },
  -- },
  -- save
  {
    "<C-s>",
    ":w<CR>",
    mode = { "n" },
  },
  {
    "<C-x>",
    function()
      vim.cmd("noa w!")
      log:warn("File saved. No autocommands had run!")
    end,
    mode = { "n" },
  },
  -- close buffer
  {
    "<C-q>",
    ":bdelete<CR>",
    mode = { "n" },
  },
  -- disable Ex mode
  {
    "Q",
    "<Nop>",
    mode = { "n" },
  },
  {
    "qq",
    "<Nop>",
    mode = { "n" },
  },
  -- better window movement
  {
    "<C-h>",
    "<C-w>h",
    mode = { "n" },
  },
  {
    "<C-j>",
    "<C-w>j",
    mode = { "n" },
  },
  {
    "<C-k>",
    "<C-w>k",
    mode = { "n" },
  },
  {
    "<C-l>",
    "<C-w>l",
    mode = { "n" },
  },
  -- resize with arrows
  {
    "<C-M-k>",
    ":resize +5<CR>",
    mode = { "n" },
  },
  {
    "<C-M-j>",
    ":resize -5<CR>",
    mode = { "n" },
  },
  {
    "<C-M-l>",
    ":vertical resize -5<CR>",
    mode = { "n" },
  },
  {
    "<C-M-h>",
    ":vertical resize +5<CR>",
    mode = { "n" },
  },
  -- move current line / block with Alt-j/k a la vscode.
  {
    "<A-j>",
    ":m .+1<CR>==",
    mode = { "n" },
  },
  {
    "<A-k>",
    ":m .-2<CR>==",
    mode = { "n" },
  },
  {
    "<A-j>",
    ":m '>+1<CR>gv-gv",
    mode = { "x" },
  },
  {
    "<A-k>",
    ":m '<-2<CR>gv-gv",
    mode = { "x" },
  },
  -- quickfix
  {
    "qn",
    ":cnext<CR>",
    mode = { "n" },
  },
  {
    "qp",
    ":cprev<CR>",
    mode = { "n" },
  },
  {
    "<C-a>",
    ":QuickFixToggle<CR>",
    mode = { "n" },
  },
  {
    "<C-y>",
    ":QuickFixToggle<CR>",
    mode = { "n" },
  },
  -- redraw
  {
    "<C-;>",
    ":redraw<CR>",
    mode = { "n" },
  },
  -- select last put text
  {
    "gy",
    "`[V`]",
    desc = "select visual block last put text",
    mode = { "n" },
  },
  {
    "gY",
    "`[v`]",
    desc = "select visual last put text",
    mode = { "n" },
  },
  -- terminal window navigation
  {
    "<C-S-H>",
    "<C-\\><C-N><C-w>h",
    mode = { "t" },
  },
  {
    "<C-S-J>",
    "<C-\\><C-N><C-w>j",
    mode = { "t" },
  },
  {
    "<C-S-K>",
    "<C-\\><C-N><C-w>k",
    mode = { "t" },
  },
  {
    "<C-S-L>",
    "<C-\\><C-N><C-w>l",
    mode = { "t" },
  },
  {
    "<C-L>",
    function()
      vim.fn.feedkeys("", "n")
      local sb = vim.bo.scrollback
      vim.bo.scrollback = 1
      vim.bo.scrollback = sb
    end,
    mode = { "t" },
  },
  {
    "`",
    "<C-\\><C-n>",
    mode = { "t" },
  },
  -- better indenting
  {
    "<",
    "<gv",
    mode = { "v" },
  },
  {
    ">",
    ">gv",
    mode = { "v" },
  },
}
