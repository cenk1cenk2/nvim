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

    ---@type table Shared UI dimension scale; helpers emit the form each plugin needs.
    dimensions = {
      -- named screen-size flip points, ascending per axis.
      breakpoints = {
        width = { narrow = 120, normal = 180, wide = 240 },
        height = { normal = 60, wide = 80 },
      },
      width = {
        xs = { ratio = 0.15, cells = 30 },
        sm = { ratio = 0.2, cells = 40 },
        md = { ratio = 0.25, cells = 75 },
        lg = { ratio = 0.35, cells = 90 },
        -- AI / chat panels: three-branch (ratio -> cells -> wide).
        xl = { ratio = 0.4, cells = 100, wide = 120, ratio_below = "narrow", wide_above = "wide" },
      },
      height = {
        xs = { ratio = 0.15, cells = 15 },
        sm = { ratio = 0.2, cells = 20 },
        md = { ratio = 0.25, cells = 25 },
        lg = { ratio = 0.35, cells = 35 },
        xl = { ratio = 0.4, cells = 50 },
      },
      float = { xs = 0.25, sm = 0.5, md = 0.6, lg = 0.8, xl = 0.9 },
      -- terminal overlays, inverted vs docks: grow toward fullscreen below `grow_below`.
      terminal = {
        width = { ratio = 0.9, small = 0.975, grow_below = "wide" },
        height = { ratio = 0.9, small = 0.95, grow_below = "wide" },
      },
      lsp = { min_width = 40, max_width = 120, max_height = 15, menu_max_height = 10 },

      -- pick the first band whose `below` cutoff the screen is under; the `below`-less band is the fallback.
      resolve = function(axis, bands)
        local total = axis == "width" and vim.o.columns or vim.o.lines
        local bp = nvim.ui.dimensions.breakpoints[axis]

        for _, band in ipairs(bands) do
          local at = type(band.below) == "string" and bp[band.below] or band.below
          if at == nil or total < at then
            return band.value
          end
        end
      end,

      -- edgy dock size: lazy fn, ratio on small screens, cells on large.
      dock = function(axis, size)
        local e = nvim.ui.dimensions[axis][size]
        local bands = { { below = e.ratio_below or "normal", value = e.ratio } }
        if e.wide then
          table.insert(bands, { below = e.wide_above, value = e.cells })
          table.insert(bands, { value = e.wide })
        else
          table.insert(bands, { value = e.cells })
        end

        return function()
          return nvim.ui.dimensions.resolve(axis, bands)
        end
      end,

      overlay = function(axis)
        local t = nvim.ui.dimensions.terminal[axis]

        return nvim.ui.dimensions.resolve(axis, {
          { below = t.grow_below, value = t.small },
          { value = t.ratio },
        })
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

  -- Disabled filetypes that are still valid windows to land a file in —
  -- a dashboard gets no statuscolumn or scrollbar, but replacing it with
  -- the file you asked for is exactly right. An empty filetype is an
  -- ordinary unnamed buffer, always a target.
  pickable_filetypes = {
    "",
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
