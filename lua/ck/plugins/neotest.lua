-- https://github.com/nvim-neotest/neotest
-- https://github.com/nvim-neotest/neotest-go
-- https://github.com/rouge8/neotest-rust
-- https://github.com/haydenmeade/neotest-jest
local M = {}

M.name = "nvim-neotest/neotest"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "nvim-neotest/neotest",
        dependencies = {
          "nvim-neotest/nvim-nio",
          "nvim-neotest/neotest-go",
          "rouge8/neotest-rust",
          "haydenmeade/neotest-jest",
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
      return {
        -- log_level = vim.log.levels.TRACE,
        discover = {
          concurrent = 1,
        },
        floating = {
          border = nvim.ui.border,
        },
        adapters = {
          require("neotest-go"),
          require("neotest-rust"),
          require("neotest-jest")({
            jestCommand = "pnpm run test",
          }),
          require("nvim-ginkgo"),
        },
      }
    end,
    on_setup = function(c)
      require("neotest").setup(c)
    end,
    wk = function(_, categories, fn)
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
