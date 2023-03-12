-- https://github.com/nvim-neotest/neotest
-- https://github.com/nvim-neotest/neotest-go
-- https://github.com/rouge8/neotest-rust
-- https://github.com/haydenmeade/neotest-jest
local M = {}

local extension_name = "neotest"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-neotest/neotest",
        dependencies = {
          "nvim-neotest/neotest-go",
          "rouge8/neotest-rust",
          "haydenmeade/neotest-jest",
        },
      }
    end,
    setup = function()
      return {
        adapters = {
          require("neotest-go"),
          require("neotest-rust"),
          require("neotest-jest")({
            jestCommand = "yarn run test",
          }),
        },
      }
    end,
    on_setup = function(config)
      require("neotest").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.TESTS] = {
          ["r"] = {
            function()
              require("neotest").run.run()
            end,
            "run nearest test",
          },
          ["R"] = {
            function()
              require("neotest").run.run(vim.fn.expand("%"))
            end,
            "run current file",
          },
          ["d"] = {
            function()
              require("neotest").run.run({ strategy = "dap" })
            end,
            "debug nearest test",
          },
          ["D"] = {
            function()
              require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
            end,
            "debug file",
          },
          ["k"] = {
            function()
              require("neotest").output.open()
            end,
            "show test output",
          },
          ["K"] = {
            function()
              require("neotest").summary.toggle()
            end,
            "show test summary",
          },
          ["s"] = {
            function()
              require("neotest").run.stop()
            end,
            "debug nearest test",
          },
          ["a"] = {
            function()
              require("neotest").run.attach()
            end,
            "attach to nearest test",
          },
          ["L"] = {
            function()
              lvim.fn.toggle_log_view(join_paths(get_state_dir(), "neotest.log"))
            end,
            "open the default logfile",
          },
        },
      }
    end,
  })
end

return M
