--
local M = {}

local extension_name = "project_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "ahmedkhalf/project.nvim",
        config = function()
          require("utils.setup").packer_config "project_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      ---@usage set to true to disable setting the current-woriking directory
      --- Manual mode doesn't automatically change your root directory, so you have
      --- the option to manually do so using `:ProjectRoot` command.
      manual_mode = true,

      ---@usage Methods of detecting the root directory
      --- Allowed values: **"lsp"** uses the native neovim lsp
      --- **"pattern"** uses vim-rooter like glob pattern matching. Here
      --- order matters: if one is not detected, the other is used as fallback. You
      --- can also delete or rearangne the detection methods.
      -- detection_methods = { "lsp", "pattern" }, -- NOTE: lsp detection will get annoying with multiple langs in one project
      detection_methods = { "pattern" },

      ---@usage patterns used to detect root dir, when **"pattern"** is in detection_methods
      patterns = { ".git", "lerna.json", "workspace.json", "nx.json" },

      ---@ Show hidden files in telescope when searching for files in a project
      show_hidden = true,

      ---@usage When set to false, you will get a message when project.nvim changes your directory.
      -- When set to false, you will get a message when project.nvim changes your directory.
      silent_chdir = false,

      ---@usage list of lsp client names to ignore when using **lsp** detection. eg: { "efm", ... }
      ignore_lsp = {},

      ---@type string
      ---@usage path to store the project history for use in telescope
      datapath = get_cache_dir(),
    },
    on_setup = function(config)
      require("project_nvim").setup(config.setup)
    end,
    on_done = function()
      require("telescope").load_extension "projects"
    end,
    wk = {
      w = {
        p = { ":Telescope projects<CR>", "projects" },
      },
    },
  })
end

return M
