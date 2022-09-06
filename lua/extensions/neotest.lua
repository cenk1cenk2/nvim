-- https://github.com/nvim-neotest/neotest
-- https://github.com/nvim-neotest/neotest-go
-- https://github.com/rouge8/neotest-rust
-- https://github.com/haydenmeade/neotest-jest

local setup = require "utils.setup"

local M = {}

local extension_name = "neotest"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-neotest/neotest",
        requires = {
          "nvim-neotest/neotest-go",
          "rouge8/neotest-rust",
          "haydenmeade/neotest-jest",
        },
        config = function()
          require("utils.setup").packer_config "neotest"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        neotest = require "neotest",
      }
    end,
    setup = function()
      return {
        adapters = {
          require "neotest-go",
          require "neotest-rust",
          require "neotest-jest" {
            jestCommand = "yarn run test",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          },
        },
      }
    end,
    on_setup = function(config)
      require("neotest").setup(config.setup)
    end,
    wk = function(config)
      local neotest = config.inject.neotest

      return {
        ["J"] = {
          name = "+neotest",
          ["r"] = {
            function()
              neotest.run.run()
            end,
            "run nearest test",
          },
          ["f"] = {
            function()
              neotest.run.run(vim.fn.expand "%")
            end,
            "run current file",
          },
          ["d"] = {
            function()
              neotest.run.run { strategy = "dap" }
            end,
            "debug nearest test",
          },
          ["D"] = {
            function()
              neotest.run.run { vim.fn.expand "%", strategy = "dap" }
            end,
            "debug file",
          },
          ["s"] = {
            function()
              neotest.run.stop()
            end,
            "debug nearest test",
          },
          ["a"] = {
            function()
              neotest.run.attach()
            end,
            "attach nearest test",
          },
        },
      }
    end,
  })
end

return M
