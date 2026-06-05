-- https://github.com/NeogitOrg/neogit
local M = {}

M.name = "NeogitOrg/neogit"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "NeogitOrg/neogit",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "dlyongemallo/diffview-plus.nvim",

          "nvim-telescope/telescope.nvim",
        },
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.possession-nvim").name, function(c)
        local before_save = c.hooks.before_save
        c.hooks.before_save = function(name)
          pcall(function()
            if is_loaded("neogit") then
              require("neogit").close()
            end
          end)

          return before_save(name)
        end

        return c
      end)
    end,
    setup = function()
      return {
        graph_style = "kitty",
        disable_insert_on_commit = true,
        git_services = {
          ["gitlab.kilic.dev"] = {
            pull_request = "https://gitlab.kilic.dev/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
            commit = "https://gitlab.kilic.dev/${owner}/${repository}/-/commit/${oid}",
            tree = "https://gitlab.kilic.dev/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads",
          },
        },
        -- Disable line numbers
        disable_line_numbers = false,
        -- Disable relative line numbers
        disable_relative_line_numbers = false,
        mappings = {
          commit_editor = {
            ["q"] = "Close",
            ["<c-c><c-s>"] = "Submit",
            ["<c-c><c-c>"] = "Abort",
          },
          commit_editor_I = {
            ["<c-c><c-s>"] = "Submit",
            ["<c-c><c-c>"] = "Abort",
          },
        },
      }
    end,
    on_setup = function(c)
      require("neogit").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "g" }),
          function()
            require("neogit").open()
          end,
          desc = "neogit",
        },
      }
    end,
  })
end

return M
