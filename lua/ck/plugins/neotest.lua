-- https://github.com/nvim-neotest/neotest
local M = {}

M.name = "nvim-neotest/neotest"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-neotest/neotest",
        dependencies = {
          "nvim-neotest/nvim-nio",
          -- https://github.com/nvim-neotest/neotest-go [dead]
          -- https://github.com/fredrikaverpil/neotest-golang
          "fredrikaverpil/neotest-golang",
          -- https://github.com/rouge8/neotest-rust
          "rouge8/neotest-rust",
          -- https://github.com/haydenmeade/neotest-jest
          "haydenmeade/neotest-jest",
          -- https://github.com/nvim-contrib/nvim-ginkgo
          {
            -- "nvim-contrib/nvim-ginkgo",
            -- dir = "/Users/cenk/development/nvim-ginkgo",
            "cenk1cenk2/nvim-ginkgo",
            branch = "patch-1",
          },
          "nvim-treesitter/nvim-treesitter",
          -- {
          --   "antoinemadec/FixCursorHold.nvim",
          --   init = false,
          --   config = false,
          --   lazy = false,
          -- },
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "neotest-summary",
        "neotest-output",
        "neotest-output-panel",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            ft = "neotest-summary",
            title = "Neotest Summary",
          },
        })

        vim.list_extend(c.bottom, {
          {
            ft = "neotest-output-panel",
            title = "Neotest Output Panel",
            size = {
              height = function()
                if vim.o.lines < 60 then
                  return 0.35
                end

                return 35
              end,
            },
          },
        })

        return c
      end)
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({
          "neotest-summary",
          "neotest-output",
        }),
      }
    end,
    setup = function()
      -- TODO: flatten.nvim has problems with nvim-neotest for discovery
      -- https://github.com/willothy/flatten.nvim/issues/106
      -- https://github.com/nvim-neotest/neotest/issues/468

      ---@type neotest.Config
      return {
        log_level = require("ck.log"):to_nvim_level(),
        floating = {
          border = nvim.ui.border,
        },
        -- See all config options with :h neotest.Config
        discovery = {
          -- Drastically improve performance in ginormous projects by
          -- only AST-parsing the currently opened buffer.
          enabled = true,
          -- Number of workers to parse files concurrently.
          -- A value of 0 automatically assigns number based on CPU.
          -- Set to 1 if experiencing lag.
          concurrent = 1,
        },
        running = {
          -- Run tests concurrently when an adapter provides multiple commands to run.
          concurrent = true,
        },
        summary = {
          -- Enable/disable animation of icons.
          animated = true,
          follow = true,
          mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "zr",
            output = "O",
            short = "S",
            attach = "a",
            jumpto = "o",
            stop = "x",
            run = "r",
            debug = "d",
            mark = "m",
            run_marked = "R",
            debug_marked = "D",
            clear_marked = "M",
            target = "t",
            clear_target = "T",
            next_failed = "J",
            prev_failed = "K",
            watch = "w",
            help = "?",
          },
        },
        adapters = {
          require("nvim-ginkgo"),
          require("neotest-golang"),
          require("neotest-rust"),
          require("neotest-jest")({
            jestCommand = "pnpm run test",
          }),
        },
      }
    end,
    on_setup = function(c)
      require("neotest").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TESTS, "r" }),
          function()
            require("neotest").run.run()
          end,
          desc = "run nearest test",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "R" }),
          function()
            require("neotest").run.run(vim.fn.expand("%"))
          end,
          desc = "run current file",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "j" }),
          function()
            require("neotest").run.run_last()
          end,
          desc = "run last",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "d" }),
          function()
            require("neotest").run.run({ strategy = "dap" })
          end,
          desc = "debug nearest test",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "D" }),
          function()
            require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
          end,
          desc = "debug file",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "k" }),
          function()
            require("neotest").output.open({ enter = true, short = false, auto_close = true, last_run = true })
          end,
          desc = "show test output",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "K" }),
          function()
            require("neotest").output.open({ last_run = true, enter = true, short = true, auto_close = true })
          end,
          desc = "show test output for last run",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "o" }),
          function()
            require("neotest").output_panel.toggle()
          end,
          desc = "toggle test output panel",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "O" }),
          function()
            require("neotest").output_panel.clear()
          end,
          desc = "clear test output panel",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "s" }),
          function()
            require("neotest").summary.toggle()
          end,
          desc = "toggle test summary",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "S" }),
          function()
            require("neotest").summary.open()
          end,
          desc = "open test summary",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "n" }),
          function()
            require("neotest").jump.next()
          end,
          desc = "next test",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "N" }),
          function()
            require("neotest").jump.next({ status = "failed" })
          end,
          desc = "next failed test",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "p" }),
          function()
            require("neotest").jump.prev()
          end,
          desc = "previous test",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "P" }),
          function()
            require("neotest").jump.prev({ status = "failed" })
          end,
          desc = "previous failed test",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "x" }),
          function()
            require("neotest").run.stop()
          end,
          desc = "stop nearest test",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "X" }),
          function()
            require("neotest").run.stop({ vim.fn.expand("%") })
          end,
          desc = "stop all tests for the file",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "a" }),
          function()
            require("neotest").run.attach()
          end,
          desc = "attach to nearest test",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "w" }),
          function()
            require("neotest").watch.toggle()
          end,
          desc = "toggle watching test",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "W" }),
          function()
            require("neotest").watch.stop()
          end,
          desc = "remove watching all tests",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TESTS, "Q" }),
          function()
            vim.cmd([[Lazy reload neotest]])
          end,
          desc = "reload plugin",
        },
        {
          fn.wk_keystroke({ categories.TESTS, categories.LOGS }),
          group = "logs",
        },

        {
          fn.wk_keystroke({ categories.TESTS, categories.LOGS, "o" }),
          function()
            nvim.fn.toggle_log_view(join_paths(get_state_dir(), "neotest.log"))
          end,
          desc = "open the default logfile [neotest]",
        },
      }
    end,
  })
end

return M
