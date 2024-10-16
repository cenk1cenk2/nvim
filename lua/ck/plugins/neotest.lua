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
          -- https://github.com/nvim-extensions/nvim-ginkgo
          "nvim-extensions/nvim-ginkgo",
          "nvim-treesitter/nvim-treesitter",
          {
            "antoinemadec/FixCursorHold.nvim",
            init = false,
            config = false,
            lazy = false,
          },
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "neotest-summary",
        "neotest-output",
      })

      -- fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
      --   vim.list_extend(c.bottom, {
      --     {
      --       ft = "neotest-summary",
      --       title = "Neotest Summary",
      --     },
      --   })
      --
      --   return c
      -- end)
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
      ---@type neotest.Config
      return {
        log_level = vim.log.levels.INFO,
        floating = {
          border = nvim.ui.border,
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
        },
        {
          fn.wk_keystroke({ categories.TESTS, "R" }),
          function()
            require("neotest").run.run(vim.fn.expand("%"))
          end,
          desc = "run current file",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "d" }),
          function()
            require("neotest").run.run({ strategy = "dap" })
          end,
          desc = "debug nearest test",
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
            require("neotest").output.open({ enter = true })
          end,
          desc = "show test output",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "s" }),
          function()
            require("neotest").summary.toggle({ enter = true })
          end,
          desc = "show test summary",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "q" }),
          function()
            require("neotest").run.stop()
          end,
          desc = "stop nearest test",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "Q" }),
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
        },
        {
          fn.wk_keystroke({ categories.TESTS, "L" }),
          function()
            nvim.fn.toggle_log_view(join_paths(get_state_dir(), "neotest.log"))
          end,
          desc = "open the default logfile",
        },
      }
    end,
  })
end

return M
