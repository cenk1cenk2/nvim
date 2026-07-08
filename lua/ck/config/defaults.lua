return {
  leader = " ",
  localleader = ",",
  colorscheme = "onedarker",

  ui = {
    icons = require("ck.config.icons"),
    colors = require("onedarker.colors"),
    border = "single",
    winblend = 0, -- pseudo-transparency for floating windows / popups (0 = opaque)
    transparent = false,

    -- shared window-option presets for docked panels (referenced as nvim.ui.wo.panel)
    wo = { panel = { winbar = false } },

    ---@type table Shared UI dimension scale + emitters. Draw every plugin size from one
    --- t-shirt scale (xs..xl); each helper emits the form a given plugin accepts.
    dimensions = {
      -- flip points match the predominant current config: columns<180 / lines<60.
      threshold = { width = 180, height = 60 },
      width = {
        xs = { ratio = 0.15, cells = 30 }, -- file trees (neotree, diffview, codediff)
        sm = { ratio = 0.2, cells = 50 }, -- outline / nav (aerial), edgy left default
        md = { ratio = 0.25, cells = 80 }, -- data / debug tools (dap-ui, dbee), edgy right default
        lg = { ratio = 0.35, cells = 120 }, -- wide tools
        -- AI / chat panels: three-branch (<80 -> 0.5 ratio, mid -> 80, >300 -> 180).
        xl = { ratio = 0.5, cells = 120, wide = 180, wide_at = 300, lo = 120 },
      },
      height = {
        xs = { ratio = 0.15, cells = 15 }, -- compact bottom (qf, edgy bottom/top default)
        sm = { ratio = 0.2, cells = 20 }, -- standard bottom (dap, toggleterm, gitlab, neotest)
        md = { ratio = 0.25, cells = 25 }, -- tall bottom (docs-view)
        lg = { ratio = 0.35, cells = 35 }, -- help
        xl = { ratio = 0.5, cells = 50 }, -- large (hurl popup height)
      },
      float = { xs = 0.25, sm = 0.5, md = 0.6, lg = 0.8, xl = 0.9 }, -- centered floats, per axis
      -- special near-fullscreen terminal overlays (toggleterm float, tmux popup). Deliberately
      -- INVERTED vs docks: smaller screens get a LARGER popup (closer to fullscreen), big
      -- screens a slightly smaller one. `small` applies below `threshold`, `ratio` at/above.
      terminal = {
        width = { ratio = 0.9, small = 0.975 },
        height = { ratio = 0.9, small = 0.95 },
      },
      lsp = { min_width = 40, max_width = 120, max_height = 15, menu_max_height = 10 },

      -- edgy dock size: returns a FUNCTION (edgy evals it lazily on VimResized). Ratio (<1)
      -- on small screens so edgy scales it down; fixed cells on large. `wide_at`/`lo`
      -- reproduce the AI-panel three-branch. edgy floors ratios at 1 and clamps oversize.
      ---@param axis "width"|"height"
      ---@param size "xs"|"sm"|"md"|"lg"|"xl"
      dock = function(axis, size)
        local e = nvim.ui.dimensions[axis][size]

        return function()
          local total = axis == "width" and vim.o.columns or vim.o.lines
          if e.wide_at and total > e.wide_at then
            return e.wide
          end
          if total < (e.lo or nvim.ui.dimensions.threshold[axis]) then
            return e.ratio
          end

          return e.cells
        end
      end,

      -- terminal overlay ratio (INVERTED vs dock): larger on small screens, smaller on big ones.
      overlay = function(axis)
        local t = nvim.ui.dimensions.terminal[axis]
        local total = axis == "width" and vim.o.columns or vim.o.lines

        return total < nvim.ui.dimensions.threshold[axis] and t.small or t.ratio
      end,

      cells = function(axis, size)
        return nvim.ui.dimensions[axis][size].cells
      end,
      ratio = function(axis, size)
        return nvim.ui.dimensions[axis][size].ratio
      end,
      percent = function(axis, size)
        return ("%d%%"):format(nvim.ui.dimensions[axis][size].ratio * 100)
      end,
      float_pct = function(size)
        return ("%d%%"):format(nvim.ui.dimensions.float[size] * 100)
      end,
      minmax = function(axis, min_size, max_size)
        local d = nvim.ui.dimensions

        return { min = d[axis][min_size].cells, max = d[axis][max_size].ratio }
      end,
    },
  },

  selection_chars = "asdfhjkl;qwerytyuiopzxcvbnm,./ASDFHJKL:QWERYTYUIOPZXCVBNM<>>?",
  system_register = "+",

  log = {
    level = "info",
    viewer = {
      cmd = "lnav",
    },
  },

  disabled_filetypes = {
    "terminal",
    "checkhealth",
    "packer",
    "lazy",
    "lspinfo",
    "prompt",
    "notify",
    "qf",
    "lsp_floating_window",
    "diff",
    "help",
    "vimdoc",
    "prompt",
  },

  disabled_buffer_types = {
    "terminal",
    "prompt",
    "quickfix",
  },

  treesitter = {
    ---@type string[]
    parsers = {},
    ---@type table[]
    custom_parsers = {},
    ---@type table<string, string | string[]>
    ft_parsers = {},
  },

  ---@type table<string, Config>
  plugins = {},

  fn = {},
}
