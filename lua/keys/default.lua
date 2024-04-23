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

    -- tab control
    ["<M-q>"] = {
      function()
        vim.cmd([[tabclose]])
      end,
      { desc = "close tab" },
    },
    ["<M-S-l>"] = {
      function()
        vim.cmd([[tabnext]])
      end,
      { desc = "next tab" },
    },
    ["<M-S-h>"] = {
      function()
        vim.cmd([[tabprevious]])
      end,
      { desc = "prev tab" },
    },

    -- split to tab
    ["<C-t>"] = "<C-w>T",

    -- split to window
    ["<C-e>"] = "<C-w><C-o>",
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
    ["<C-q>"] = ":bdelete<CR>",

    -- disable Ex mode
    ["Q"] = "<Nop>",
    ["qq"] = "<Nop>",

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
    ["gy"] = { "`[V`]", { desc = "select visual block last put text" } },
    ["gY"] = { "`[v`]", { desc = "select visual last put text" } },
  },

  ---@usage change or add keymappings for terminal mode
  {
    { "t" },

    -- Terminal window navigation
    ["<C-H>"] = "<C-\\><C-N><C-w>h",
    ["<C-J>"] = "<C-\\><C-N><C-w>j",
    ["<C-K>"] = "<C-\\><C-N><C-w>k",
    ["<C-L>"] = "<C-\\><C-N><C-w>l",
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
