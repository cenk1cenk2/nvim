local log = require("lvim.log")
local job = require("utils.job")
local utils = require("utils")

local M = {}

function M.run_genpass()
  local shada = require("modules.shada")
  local store_key = "RUN_GENPASS_ARGS"
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Genpass arguments:",
    highlight = utils.treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    shada.set(store_key, arguments)

    job
      .create({
        command = "genpass",
        args = vim.split(arguments or {}, " "),
        on_success = function(j)
          local generated = j:result()[1]

          log:info(("Copied generated code to clipboard: %s"):format(generated))
          vim.fn.setreg(vim.v.register or lvim.system_register, generated)
        end,
      })
      :start()
  end)
end

function M.run_ansible_vault_decrypt()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  job
    .create({
      command = "ansible-vault",
      writer = lines,
      args = { "decrypt" },
      on_success = function(j)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, j:result())
      end,
    })
    :start()
end

function M.run_ansible_vault_encrypt()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  job
    .create({
      command = "ansible-vault",
      writer = lines,
      args = { "encrypt" },
      on_success = function(j)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, j:result())
      end,
    })
    :start()
end

function M.run_sd()
  local store_key = "SD_INPUT"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "sd: ",
    highlight = utils.treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      log:warn("No arguments provided")

      return
    end

    arguments = vim.split(arguments, " ")
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    job
      .create({
        command = "sd",
        args = arguments,
        writer = lines,
        on_success = function(j)
          shada.set(store_key, table.concat(arguments, " "))

          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, j:result())
        end,
      })
      :start()
  end)
end

function M.run_jq()
  local store_key = "JQ_INPUT"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "jq: ",
    highlight = utils.treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      arguments = "."
    end

    arguments = vim.split(arguments, " ")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    job
      .create({
        command = "jq",
        args = arguments,
        writer = lines,
        on_success = function(j)
          shada.set(store_key, table.concat(arguments, " "))

          local result = table.concat(j:result(), "\n")

          log:info(("Copied result to clipboard: %s"):format(result))
          vim.fn.setreg(vim.v.register or lvim.system_register, result)
        end,
      })
      :start()
  end)
end

function M.run_jqp()
  local terminal = require("extensions.toggleterm-nvim")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local t = terminal.create_float_terminal({ cmd = ("echo '%s' | jqp"):format(table.concat(lines, "\\n")) })

  t:toggle()
end

function M.run_yq()
  local store_key = "YQ_INPUT"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "yq: ",
    highlight = utils.treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      arguments = "."
    end

    arguments = vim.split(arguments, " ") or { "." }
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    job
      .create({
        command = "yq",
        args = arguments,
        writer = lines,
        on_success = function(j)
          shada.set(store_key, table.concat(arguments, " "))

          local result = table.concat(j:result(), "\n")

          log:info(("Copied result to clipboard: %s"):format(result))
          vim.fn.setreg(vim.v.register or lvim.system_register, result)
        end,
      })
      :start()
  end)
end

function M.set_env()
  local store_key = "LVIM_SET_ENV_VAR"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Environment Variable:",
    default = stored_value,
    completion = "environment",
  }, function(env)
    if env == nil then
      log:warn("Nothing to do.")

      return
    end

    shada.set(store_key, env)

    vim.ui.input({
      prompt = "Value:",
      default = vim.env[env],
      completion = "file",
    }, function(val)
      if val == nil then
        log:warn("Nothing to do.")

        return
      end

      vim.env[env] = vim.fn.expand(tostring(val))
    end)
  end)
end

function M.set_kubeconfig()
  local store_key = "KUBECONFIG"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Kubeconfig file:",
    default = stored_value,
    completion = "file",
  }, function(arguments)
    if arguments == nil then
      log:warn("Nothing to do.")

      return
    end

    local kubeconfig = vim.fn.expand(arguments)

    if not is_file(kubeconfig) then
      log:warn(("Kubeconfig file not found: %s"):format(kubeconfig))

      return
    end

    shada.set(store_key, arguments)

    vim.env["KUBECONFIG"] = kubeconfig
  end)
end

function M.setup()
  require("utils.setup").init({
    name = "executables",
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.SEARCH, "d" }),
          function()
            M.run_sd()
          end,
          desc = "sd",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "d" }),
          function()
            M.run_ansible_vault_decrypt()
          end,
          desc = "ansible-vault decrypt",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "D" }),
          function()
            M.run_ansible_vault_encrypt()
          end,
          desc = "ansible-vault encrypt",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "e" }),
          function()
            M.set_env()
          end,
          desc = "set environment variable",
        },

        {
          fn.wk_keystroke({ categories.TASKS, "g" }),
          function()
            M.run_genpass()
          end,
          desc = "run genpass",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "j" }),
          function()
            M.run_jq()
          end,
          desc = "run jq",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "J" }),
          function()
            M.run_yq()
          end,
          desc = "run yq",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "p" }),
          function()
            M.run_jqp()
          end,
          desc = "run jqp",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "k" }),
          function()
            M.set_kubeconfig()
          end,
          desc = "set kubeconfig",
        },
      }
    end,
  })
end

return M
