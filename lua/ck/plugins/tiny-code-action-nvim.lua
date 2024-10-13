-- https://github.com/rachartier/tiny-code-action.nvim
local M = {}

M.name = "rachartier/tiny-code-action.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "rachartier/tiny-code-action.nvim",
      }
    end,
    configure = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.code_action = function()
        require("tiny-code-action").code_action()
      end
    end,
    setup = function()
      return {
        backend = "delta",
        telescope_opts = {
          layout_strategy = "horizontal",
          layout_config = {
            width = function()
              if vim.o.columns < 180 then
                return math.floor(vim.o.columns * 0.975)
              end

              return math.floor(vim.o.columns * 0.75)
            end,
            height = function()
              if vim.o.lines < 60 then
                return math.floor(vim.o.lines * 0.95)
              end

              return math.floor(vim.o.lines * 0.75)
            end,
            preview_cutoff = 1,
            -- preview_height = function(_, _, max_lines)
            --   local h = math.floor(max_lines * 0.2)
            --   return math.max(h, 10)
            -- end,
          },
        },
        signs = {
          quickfix = { "󰁨", { link = "DiagnosticInfo" } },
          others = { "?", { link = "DiagnosticWarning" } },
          refactor = { "", { link = "DiagnosticWarning" } },
          ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
          ["refactor.extract"] = { "", { link = "DiagnosticError" } },
          ["source.organizeImports"] = { "", { link = "TelescopeResultVariable" } },
          ["source.fixAll"] = { "", { link = "TelescopeResultVariable" } },
          ["source"] = { "", { link = "DiagnosticError" } },
          ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
          ["codeAction"] = { "", { link = "DiagnosticError" } },
        },
      }
    end,
    on_setup = function(c)
      require("tiny-code-action").setup(c)
    end,
  })
end

return M
