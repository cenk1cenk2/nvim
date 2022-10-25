return {
  ---@usage change or add keymappings for insert mode
  insert_mode = {
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-j>"] = "<Esc>:m .+1<CR>==gi",
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-k>"] = "<Esc>:m .-2<CR>==gi",

    -- navigation
    ["<A-Up>"] = "<C-\\><C-N><C-w>k",
    ["<A-Down>"] = "<C-\\><C-N><C-w>j",
    ["<A-Left>"] = "<C-\\><C-N><C-w>h",
    ["<A-Right>"] = "<C-\\><C-N><C-w>l",

    -- escape with c-c
    ["<C-c>"] = "<ESC>",
  },

  ---@usage change or add keymappings for normal mode
  normal_mode = {
    ["qq"] = "",

    -- save
    ["<C-s>"] = ":w<CR>",
    ["<C-S>"] = ":w!<CR>",
    ["<C-x>"] = function()
      vim.cmd "noa w!"
      require("lvim.core.log"):warn "File saved. No autocommands had run!"
    end,

    -- close buffer
    ["<C-q>"] = ":BufferClose<CR>",
    ["<C-Q>"] = ":BufferClose<CR>",

    -- disable help
    ["<F1>"] = "<Nop>",

    -- disable Ex mode
    -- ["Q"] = "<Nop>",

    -- split to tab
    ["<C-t>"] = "<C-w>T",
    ["<C-E>"] = "<C-w><C-o>",

    -- Better window movement
    ["<C-h>"] = "<C-w>h",
    ["<C-j>"] = "<C-w>j",
    ["<C-k>"] = "<C-w>k",
    ["<C-l>"] = "<C-w>l",

    -- Resize with arrows
    ["<C-M-k>"] = ":resize +2<CR>",
    ["<C-M-j>"] = ":resize -2<CR>",
    ["<C-M-h>"] = ":vertical resize -2<CR>",
    ["<C-M-l>"] = ":vertical resize +2<CR>",

    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = ":m .+1<CR>==",
    ["<A-k>"] = ":m .-2<CR>==",

    -- QuickFix
    ["qn"] = ":cnext<CR>",
    ["qp"] = ":cprev<CR>",
    ["<C-a>"] = ":call QuickFixToggle()<CR>",
    ["<C-y>"] = ":call QuickFixToggle()<CR>",

    -- create space on top and bottom
    ["ü"] = "O<ESC>j",
    ["Ü"] = "o<ESC>k",

    -- jump between paragraphs
    -- ["ö"] = "{zz",
    -- ["ä"] = "}zz",

    -- paste last clipboard register
    -- ["op"] = '"_diw"*P',

    -- paste last yank register
    -- ["üp"] = '"_diw"0P',

    -- visual select last word
    -- ["üü"] = "viw",

    -- to blachole
    ["c"] = '"_c',
    ["C"] = '"_C',
    ["x"] = '"_x',
  },

  ---@usage change or add keymappings for terminal mode
  term_mode = {
    -- Terminal window navigation
    ["<C-h>"] = "<C-\\><C-N><C-w>h",
    ["<C-j>"] = "<C-\\><C-N><C-w>j",
    ["<C-k>"] = "<C-\\><C-N><C-w>k",
    ["<C-l>"] = "<C-\\><C-N><C-w>l",
    ["^"] = "<C-\\><C-n>",
  },

  ---@usage change or add keymappings for visual mode
  visual_mode = {
    -- Better indenting
    ["<"] = "<gv",
    [">"] = ">gv",

    -- jump between paragraphs
    -- ["ö"] = "{zz",
    -- ["ä"] = "}zz",

    -- to blachole
    ["c"] = '"_c',
    ["C"] = '"_C',
    ["x"] = '"_x',

    -- dont overwrite while pasting
    ["p"] = '"_dp',
    ["P"] = '"_dP',

    -- ["p"] = '"0p',
    -- ["P"] = '"0P',
  },

  ---@usage change or add keymappings for visual block mode
  visual_block_mode = {
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-j>"] = ":m '>+1<CR>gv-gv",
    ["<A-k>"] = ":m '<-2<CR>gv-gv",

    -- to blachole
    ["c"] = '"_c',
    ["x"] = '"_x',
    ["p"] = '"_dp',
    ["P"] = '"_dP',
  },

  ---@usage change or add keymappings for command mode
  command_mode = {
    -- navigate tab completion with <c-j> and <c-k>
    -- runs conditionally
  },
}
