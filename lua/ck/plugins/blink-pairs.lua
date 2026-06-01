-- https://github.com/saghen/blink.pairs

local M = {}

M.name = "saghen/blink.pairs"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "saghen/blink.pairs",
        build = function()
          require("blink.pairs").build():pwait(60000)
        end,
        -- version = "*",
        -- build = function()
        --   require("blink.pairs").download():pwait(60000)
        -- end,
        event = { "InsertEnter", "CmdlineEnter" },
        -- dependencies = {
        --   "saghen/blink.download",
        -- },
      }
    end,
    setup = function()
      ---@type blink.pairs.Config
      return {
        mappings = {
          enabled = true,
          pairs = {
            -- rust closure pairs
            ["|"] = {
              { "|", "|", enter = false, languages = { "rust" } },
            },
            -- angle brackets for generics in all languages except HTML/JSX/TSX
            ["<"] = {
              {
                "<",
                ">",
                when = function(ctx)
                  return ctx.ts:whitelist("angle").matches
                end,
                languages = {
                  "rust",
                  "typescript",
                  "javascript",
                  "go",
                  "java",
                  "kotlin",
                  "scala",
                  "lua",
                  "cpp",
                  "c",
                  "zig",
                },
              },
            },
          },
          wrap = {
            normal_mode = {
              ["<M-e>"] = "motion",
              ["<M-S-e>"] = "motion_reverse",
            },
          },
          disabled_filetypes = nvim.disabled_filetypes,
        },
        highlights = {
          enabled = true,
          groups = {
            "BlinkPairsRainbow1",
            "BlinkPairsRainbow2",
            "BlinkPairsRainbow3",
            "BlinkPairsRainbow4",
          },
          unmatched_group = "BlinkPairsUnmatched",
          matchparen = {
            enabled = true,
          },
        },
      }
    end,
    on_setup = function(c)
      require("blink.pairs").setup(c)
    end,
  })
end

return M
