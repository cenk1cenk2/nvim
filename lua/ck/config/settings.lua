local M = {}

M._ = {}
M._.setup = false

function M.load_default_options()
  local undodir = join_paths(get_cache_dir(), "undo")

  if not is_directory(undodir) then
    vim.fn.mkdir(undodir, "p")
  end

  vim.opt.timeoutlen = 200
  vim.opt.backup = false
  vim.opt.clipboard = "unnamedplus"
  vim.opt.cmdheight = 2
  vim.opt.completeopt = { "menuone", "noselect" }
  vim.opt.conceallevel = 0
  vim.opt.fileencoding = "utf-8"
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
  vim.opt.indentexpr = "nvim_treesitter#indent()"
  vim.opt.fillchars = { foldclose = nvim.ui.icons.ArrowCircleRight }
  vim.opt.sessionoptions = { "blank", "buffers", "curdir", "help", "tabpages", "winsize", "terminal", "globals" }
  vim.opt.foldenable = false
  vim.opt.foldlevel = 99
  vim.opt.foldcolumn = "0"
  vim.opt.guifont = "ConsolasLG Nerd Font:h17"
  vim.opt.hidden = true
  vim.opt.hlsearch = true
  vim.opt.ignorecase = true
  vim.opt.mouse = "a"
  vim.opt.pumheight = 20
  vim.opt.showmode = false
  vim.opt.showtabline = 2
  vim.opt.smartcase = true
  vim.opt.smartindent = true
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.swapfile = false
  vim.opt.termguicolors = true
  vim.opt.title = true
  vim.opt.titlestring = "%<%F%=%l/%L - nvim"
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  vim.opt.laststatus = 3
  vim.opt.more = false
  vim.opt.splitkeep = "screen"
  vim.opt.undodir = undodir
  vim.opt.undofile = true
  vim.opt.updatetime = 100
  vim.opt.writebackup = false
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
  vim.opt.cursorline = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.numberwidth = 2
  vim.opt.signcolumn = "yes"
  vim.opt.wrap = true
  vim.opt.spell = false
  vim.opt.spelllang = "en"
  vim.opt.shadafile = join_paths(get_cache_dir(), "shada", "main.shada")
  vim.opt.scrolloff = 8
  vim.opt.sidescrolloff = 8
  vim.opt.exrc = true

  -- vim.opt.shortmess:append("c") -- don't show redundant messages from ins-completion-menu
  -- vim.opt.shortmess:append("I") -- don't show the default intro message
  vim.opt.whichwrap:append("<,>,[,],h,l")
end

M.load_headless_options = function()
  vim.opt.shortmess = "" -- try to prevent echom from cutting messages off or prompting
  vim.opt.more = false -- don't pause listing when screen is filled
  vim.opt.cmdheight = 9999 -- helps avoiding |hit-enter| prompts.
  vim.opt.columns = 9999 -- set the widest screen possible
  vim.opt.swapfile = false -- don't use a swap file
end

function M.setup()
  if M._.setup then
    require("ck.log"):warn("Already set default settings.")
    return
  end

  M.load_default_options()

  if is_headless() then
    M.load_headless_options()
  end

  M._.setup = true
end

return M
