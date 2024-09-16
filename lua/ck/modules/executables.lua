local log = require("ck.log")
local job = require("ck.utils.job")
local utils = require("ck.utils")

local M = {}

function M.run_genpass()
  local shada = require("ck.modules.shada")
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

          log:info("Copied generated code to clipboard: %s", generated)
          vim.fn.setreg(vim.v.register or nvim.system_register, generated)
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
  local shada = require("ck.modules.shada")
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

function M.run_otree()
  local terminal = require("ck.plugins.toggleterm-nvim")

  -- macos piping does not work properly

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local path = table.concat({ os.tmpname(), require("ck.utils.fs").get_buffer_extension(bufnr) }, ".")

  local fd, err = io.open(path, "w+")

  if fd == nil or err then
    log:error("Failed to open temporary file: %s", err)

    return
  end

  fd:write(table.concat(lines, "\n"))
  fd:flush()
  fd:close()

  local t = terminal.create_float_terminal({
    cmd = ("otree '%s'"):format(path),
    on_close = function()
      local ok = os.remove(path)

      if not ok then
        log:error("Failed to remove temporary path: %s", path)

        return
      end

      log:info("Temporary path removed: %s", path)
    end,
  })

  t:toggle()
end

function M.set_env()
  local store_key = "SET_ENV_VAR"
  local shada = require("ck.modules.shada")
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
  local shada = require("ck.modules.shada")
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
      log:warn("Kubeconfig file not found: %s", kubeconfig)

      return
    end

    shada.set(store_key, arguments)

    vim.env["KUBECONFIG"] = kubeconfig
  end)
end

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.SEARCH, "d" }),
          function()
            M.run_sd()
          end,
          desc = "sd",
        },
        {
          fn.wk_keystroke({ categories.RUN, "d" }),
          function()
            M.run_ansible_vault_decrypt()
          end,
          desc = "ansible-vault decrypt",
        },
        {
          fn.wk_keystroke({ categories.RUN, "D" }),
          function()
            M.run_ansible_vault_encrypt()
          end,
          desc = "ansible-vault encrypt",
        },
        {
          fn.wk_keystroke({ categories.RUN, "e" }),
          function()
            M.set_env()
          end,
          desc = "set environment variable",
        },

        {
          fn.wk_keystroke({ categories.RUN, "g" }),
          function()
            M.run_genpass()
          end,
          desc = "run genpass",
        },
        {
          fn.wk_keystroke({ categories.RUN, "o" }),
          function()
            M.run_otree()
          end,
          desc = "run otree",
        },
        {
          fn.wk_keystroke({ categories.RUN, "k" }),
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
