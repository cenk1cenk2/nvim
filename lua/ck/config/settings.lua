local M = {}

M._ = {}
M._.has_loaded = false

function M.load_default_options()
  local undodir = join_paths(get_cache_dir(), "undo")

  vim.fs.mkdir(undodir, { parents = true })

  vim.opt.timeoutlen = 200
  vim.opt.backup = false
  vim.opt.autoread = true
  vim.opt.clipboard = "unnamedplus"
  -- Inside tmux the attached client decides the clipboard, and it can change while nvim runs: env-sync keeps the server's
  -- WAYLAND_DISPLAY set for a local client and unset for an ssh one. Over ssh the terminal answers `refresh-client -l`
  -- after the 50ms the builtin tmux provider waits, so wait for the answer instead, and reuse it for the reads one put makes.
  if vim.env.TMUX then
    local cache = { lines = nil, at = 0 }

    local function wayland()
      return (vim.fn.systemlist({ "tmux", "show-environment", "-g", "WAYLAND_DISPLAY" })[1] or ""):match("^WAYLAND_DISPLAY=(.+)$")
    end

    local function newest()
      local index = -1
      for _, name in ipairs(vim.fn.systemlist({ "tmux", "list-buffers", "-F", "#{buffer_name}" })) do
        index = math.max(index, tonumber(name:match("^buffer(%d+)$")) or -1)
      end

      return index
    end

    local function copy(lines)
      cache.lines = nil
      local display = wayland()
      if display then
        vim.fn.systemlist({ "env", "WAYLAND_DISPLAY=" .. display, "wl-copy", "--type", "text/plain" }, lines, 1)
      else
        vim.fn.systemlist({ "tmux", "load-buffer", "-w", "-" }, lines, 1)
      end
    end

    local function paste()
      if cache.lines and vim.uv.hrtime() - cache.at < 300e6 then
        return cache.lines
      end

      local display = wayland()
      if display then
        cache.lines = vim.fn.systemlist({ "env", "WAYLAND_DISPLAY=" .. display, "wl-paste", "--no-newline" }, { "" }, 1)
      else
        local before = newest()
        vim.fn.system({ "tmux", "refresh-client", "-l" })
        vim.wait(1000, function()
          return newest() ~= before
        end, 20)
        cache.lines = vim.fn.systemlist({ "tmux", "save-buffer", "-" }, { "" }, 1)
      end
      cache.at = vim.uv.hrtime()

      return cache.lines
    end

    vim.g.clipboard = {
      name = "tmux",
      copy = { ["+"] = copy, ["*"] = copy },
      paste = { ["+"] = paste, ["*"] = paste },
    }
  end
  vim.opt.cmdheight = 2
  vim.opt.completeopt = { "menuone", "noselect" }
  vim.opt.conceallevel = 0
  vim.opt.fileencoding = "utf-8"
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = function()
    return vim.treesitter.foldexpr()
  end
  -- vim.opt.foldtext = "v:lua.nvim.fold.text()"
  vim.opt.indentexpr = function()
    return require("nvim-treesitter").indentexpr()
  end
  vim.opt.fillchars = {
    foldopen = nvim.ui.icons.ArrowCircleDown,
    foldsep = nvim.ui.icons.BoldLineLeft,
    foldclose = nvim.ui.icons.ArrowCircleRight,
    fold = " ",
  }
  vim.opt.sessionoptions = { "blank", "buffers", "curdir", "help", "tabpages", "winsize", "terminal", "globals", "folds" }
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
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 0
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
  vim.opt.gdefault = true
  -- add difftastic at some point
  -- vim.opt.diffexpr = "difft --display inline"

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

function M.load()
  if M._.has_loaded then
    require("ck.log"):warn("Already set default settings.")
    return
  end

  M.load_default_options()

  if is_headless() then
    M.load_headless_options()
  end

  M._.has_loaded = true
end

return M
