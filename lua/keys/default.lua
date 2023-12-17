local Log = require("lvim.core.log")

return {
  {
    { "a" },

    -- disable help
    ["<F1>"] = "<Nop>",
    -- to blachole
    ["c"] = '"_c',
    ["C"] = '"_C',
    ["x"] = '"_x',
  },

  {
    { "v", "vb" },

    -- to blachole
    ["P"] = '"_dp',
    ["p"] = '"_dP',
  },

  ---@usage change or add keymappings for insert mode
  {
    { "i" },

    -- Move current line / block with Alt-j/k ala vscode.
    -- ["<A-j>"] = "<Esc>:m .+1<CR>==gi",
    -- Move current line / block with Alt-j/k ala vscode.
    -- ["<A-k>"] = "<Esc>:m .-2<CR>==gi",

    -- navigation
    ["<A-Up>"] = "<C-\\><C-N><C-w>k",
    ["<A-Down>"] = "<C-\\><C-N><C-w>j",
    ["<A-Left>"] = "<C-\\><C-N><C-w>h",
    ["<A-Right>"] = "<C-\\><C-N><C-w>l",

    -- escape with c-c
    ["<C-c>"] = "<ESC>",
  },

  ---@usage change or add keymappings for normal mode
  {
    { "n" },

    -- save
    ["<C-s>"] = ":w<CR>",
    ["<C-x>"] = function()
      vim.cmd("noa w!")
      Log:warn("File saved. No autocommands had run!")
    end,

    -- close buffer
    ["<C-q>"] = ":BufferClose<CR>",

    -- disable Ex mode
    ["Q"] = "<Nop>",
    ["qq"] = "<Nop>",

    -- split to tab
    ["<C-t>"] = "<C-w>T",
    ["<C-E>"] = "<C-w><C-o>",

    -- Better window movement
    ["<C-h>"] = "<C-w>h",
    ["<C-j>"] = "<C-w>j",
    ["<C-k>"] = "<C-w>k",
    ["<C-l>"] = "<C-w>l",

    -- Resize with arrows
    ["<C-M-k>"] = ":resize +5<CR>",
    ["<C-M-j>"] = ":resize -5<CR>",
    ["<C-M-l>"] = ":vertical resize -5<CR>",
    ["<C-M-h>"] = ":vertical resize +5<CR>",

    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = ":m .+1<CR>==",
    ["<A-k>"] = ":m .-2<CR>==",

    -- QuickFix
    ["qn"] = ":cnext<CR>",
    ["qp"] = ":cprev<CR>",
    ["<C-a>"] = ":QuickFixToggle<CR>",
    ["<C-y>"] = ":QuickFixToggle<CR>",

    -- redraw
    ["<C-;>"] = ":redraw<CR>",

    -- select last put text
    ["gy"] = { "`[v`]", { desc = "select visual last put text" } },
    ["gY"] = { "`[V`]", { desc = "select visual block last put text" } },
  },

  ---@usage change or add keymappings for terminal mode
  {
    { "t" },

    -- Terminal window navigation
    ["<C-h>"] = "<C-\\><C-N><C-w>h",
    ["<C-j>"] = "<C-\\><C-N><C-w>j",
    ["<C-k>"] = "<C-\\><C-N><C-w>k",
    ["<C-l>"] = "<C-\\><C-N><C-w>l",
    ["`"] = "<C-\\><C-n>",
  },

  ---@usage change or add keymappings for visual mode
  {
    { "v" },

    -- Better indenting
    ["<"] = "<gv",
    [">"] = ">gv",
  },

  ---@usage change or add keymappings for visual block mode
  {
    { "vb" },

    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-j>"] = ":m '>+1<CR>gv-gv",
    ["<A-k>"] = ":m '<-2<CR>gv-gv",
  },
}
