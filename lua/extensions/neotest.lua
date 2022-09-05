local M = {}

local extension_name = "neotest"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
  }

  local status_ok, neotest = pcall(require, extension_name)

  if not status_ok then
    return
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], {
    on_config_done = nil,
    keymaps = {
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
    setup = {
      adapters = {
        require "neotest-go",
        require "neotest-rust",
        require "neotest-jest" {
          jestCommand = "yarn run test",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        },
      },
    },
  })
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings["J"] = lvim.extensions[extension_name].keymaps

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
