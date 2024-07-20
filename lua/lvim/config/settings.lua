local M = {}

M.load_default_options = function()
  local utils = require("lvim.utils")

  local undodir = join_paths(get_cache_dir(), "undo")

  if not utils.is_directory(undodir) then
    vim.fn.mkdir(undodir, "p")
  end

  ---@type vim.opt
  local default_options = {
    backup = false, -- creates a backup file
    clipboard = "unnamedplus", -- allows neovim to access the system clipboard
    cmdheight = 2, -- more space in the neovim command line for displaying messages
    completeopt = { "menuone", "noselect" },
    conceallevel = 0, -- so that `` is visible in markdown files
    fileencoding = "utf-8", -- the encoding written to a file
    foldmethod = "expr", -- folding, set to "expr" for treesitter based folding
    foldexpr = "v:lua.vim.treesitter.foldexpr()", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
    foldtext = "v:lua.vim.treesitter.foldtext()",
    indentexpr = "nvim_treesitter#indent()",
    fillchars = {
      foldclose = lvim.ui.icons.ArrowCircleRight,
    },
    sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "terminal", "globals" },
    foldenable = false,
    foldlevel = 99,
    foldcolumn = "0",
    guifont = "ConsolasLG Nerd Font:h17", -- the font used in graphical neovim applications
    hidden = true, -- required to keep multiple buffers and open multiple buffers
    hlsearch = true, -- highlight all matches on previous search pattern
    ignorecase = true, -- ignore case in search patterns
    mouse = "a", -- allow the mouse to be used in neovim
    pumheight = 20, -- pop up menu height
    showmode = false, -- we don't need to see things like -- INSERT -- anymore
    showtabline = 2, -- always show tabs
    smartcase = true, -- smart case
    smartindent = true, -- make indenting smarter again
    splitbelow = true, -- force all horizontal splits to go below current window
    splitright = true, -- force all vertical splits to go to the right of current window
    swapfile = false, -- creates a swapfile
    termguicolors = true, -- set term gui colors (most terminals support this)
    timeoutlen = 250, -- time to wait for a mapped sequence to complete (in milliseconds)
    title = true, -- set the title of window to the value of the titlestring
    grepprg = "rg --vimgrep --no-heading --smart-case",
    grepformat = "%f:%l:%c:%m,%f:%l:%m",
    laststatus = 3,
    splitkeep = "screen",
    -- opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
    undodir = undodir, -- set an undo directory
    undofile = true, -- enable persistent undo
    updatetime = 100, -- faster completion
    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true, -- convert tabs to spaces
    shiftwidth = 2, -- the number of spaces inserted for each indentation
    tabstop = 2, -- insert 2 spaces for a tab
    cursorline = true, -- highlight the current line
    number = true, -- set numbered lines
    relativenumber = true, -- set relative numbered lines
    numberwidth = 2, -- set number column width to 2 {default 4}
    signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
    wrap = true, -- display lines as one long line
    spell = false,
    spelllang = "en",
    -- spellfile = join_paths(get_config_dir(), "spell", "en.utf-8.add"),
    shadafile = join_paths(get_cache_dir(), "shada", "main.shada"),
    scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor.
    sidescrolloff = 8, -- minimal number of screen lines to keep left and right of the cursor.
    exrc = true,
  }

  if vim.env["SSH_TTY"] then
    local refresh_tmux_client = function()
      if vim.env["TMUX_PANE"] then
        local result = os.execute(("tmux refresh-client -l %s"):format(vim.env["TMUX_PANE"]))

        if result == false then
          require("lvim.core.log"):warn("Failed to refresh tmux client.")

          return false
        end
      end

      return true
    end

    local copy = function(register)
      local cb = require("vim.ui.clipboard.osc52").copy(register)

      return function(...)
        return cb(...)
      end
    end

    local paste = function(register)
      local cb = require("vim.ui.clipboard.osc52").paste(register)

      return function(...)
        local result = refresh_tmux_client()
        if result == false then
          return
        end

        return cb(...)
      end
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = copy("*"),
        ["*"] = copy("*"),
      },
      paste = {
        ["+"] = paste("+"),
        ["*"] = paste("*"),
      },
    }
  end

  ---  SETTINGS  ---
  vim.opt.shortmess:append("c") -- don't show redundant messages from ins-completion-menu
  vim.opt.shortmess:append("I") -- don't show the default intro message
  vim.opt.whichwrap:append("<,>,[,],h,l")

  for k, v in pairs(default_options) do
    vim.opt[k] = v
  end
end

M.load_headless_options = function()
  vim.opt.shortmess = "" -- try to prevent echom from cutting messages off or prompting
  vim.opt.more = false -- don't pause listing when screen is filled
  vim.opt.cmdheight = 9999 -- helps avoiding |hit-enter| prompts.
  vim.opt.columns = 9999 -- set the widest screen possible
  vim.opt.swapfile = false -- don't use a swap file
end

M.load_defaults = function()
  -- if is_headless() then
  --   M.load_headless_options()
  --
  --   return
  -- end

  M.load_default_options()
end

return M
