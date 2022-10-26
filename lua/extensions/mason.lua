-- https://github.com/williamboman/mason.nvim
local M = {}

local extension_name = "mason"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "williamboman/mason.nvim",
        requires = {
          { "williamboman/mason-lspconfig.nvim" },
          { "WhoIsSethDaniel/mason-tool-installer.nvim" },
        },
        config = function()
          require("utils.setup").packer_config "mason"
        end,
        disable = not config.active,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes { "mason" }
    end,
    setup = {
      ui = {
        keymaps = {
          toggle_package_expand = "<CR>",
          install_package = "i",
          update_package = "u",
          check_package_version = "c",
          update_all_packages = "U",
          check_outdated_packages = "C",
          uninstall_package = "X",
          cancel_installation = "<C-c>",
          apply_language_filter = "<C-f>",
        },
      },
      log_level = vim.log.levels.INFO,
      max_concurrent_installers = 4,

      github = {
        -- The template URL to use when downloading assets from GitHub.
        -- The placeholders are the following (in order):
        -- 1. The repository (e.g. "rust-lang/rust-analyzer")
        -- 2. The release version (e.g. "v0.3.0")
        -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
        download_url_template = "https://github.com/%s/releases/download/%s/%s",
      },
    },
    on_setup = function(config)
      require("mason").setup(config.setup)
    end,
  })
end

return M
