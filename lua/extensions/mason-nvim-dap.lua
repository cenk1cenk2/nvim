-- https://github.com/jay-babu/mason-nvim-dap.nvim
local M = {}

M.name = "jay-babu/mason-nvim-dap.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "jay-babu/mason-nvim-dap.nvim",
        keys = { { "<Space>d" } },
      }
    end,
    setup = function()
      return {
        -- A list of adapters to install if they're not already installed.
        -- This setting has no relation with the `automatic_installation` setting.
        ensure_installed = {},

        -- NOTE: this is left here for future porting in case needed
        -- Whether adapters that are set up (via dap) should be automatically installed if they're not already installed.
        -- This setting has no relation with the `ensure_installed` setting.
        -- Can either be:
        --   - false: Daps are not automatically installed.
        --   - true: All adapters set up via dap are automatically installed.
        --   - { exclude: string[] }: All adapters set up via mason-nvim-dap, except the ones provided in the list, are automatically installed.
        --       Example: automatic_installation = { exclude = { "python", "delve" } }
        automatic_installation = false,

        -- Whether adapters that are installed in mason should be automatically set up in dap.
        -- Removes the need to set up dap manually.
        -- See mappings.adapters and mappings.configurations for settings.
        -- Must invoke when set to true: `require 'mason-nvim-dap'.setup_handlers()`
        -- Can either be:
        -- 	- false: Dap is not automatically configured.
        -- 	- true: Dap is automatically configured.
        -- 	- {adapters: {ADAPTER: {}, }, configurations: {ADAPTER: {}, }}. Allows overriding default configuration.
        automatic_setup = true,
        handlers = {
          function(source_name)
            -- all sources with no handler get passed here

            -- Keep original functionality of `automatic_setup = true`
            require("mason-nvim-dap.automatic_setup")(source_name)
          end,
        },
      }
    end,
    on_setup = function(c)
      require("mason-nvim-dap").setup(c)
    end,
  })
end

return M
