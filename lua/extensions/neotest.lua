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
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
        },
      }
    end,
    on_setup = function(config)
      require("neotest").setup(config.setup)
    end,
    wk = function(config, categories)
      return {
        [categories.TESTS] = {
          ["r"] = {
            function()
              require("neotest").run.run()
            end,
            "run nearest test",
          },
          ["f"] = {
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
            "attach nearest test",
          },
        },
      }
    end,
  })
end

return M
