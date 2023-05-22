local Log = require("lvim.core.log")
local job = require("utils.job")

local M = {}

function M.run_markdown_toc()
  local server_name = "markdown-toc"
  local server = require("mason-registry").get_package(server_name)

  if not server:is_installed() then
    Log:error(("Server %s is not available."):format(server_name))

    return
  end

  local config = vim.deepcopy(require("modules.lsp-config").get_lsp_default_config(server_name))

  job.spawn({
    command = table.concat(config.command),
    args = vim.list_extend(vim.deepcopy(config.args), { vim.fn.expand("%") }),
  })
  M.reload_file()
end

function M.run_md_printer()
  job.spawn({
    command = "md-printer",
    args = { vim.fn.expand("%") },
  })
  M.reload_file()
end

function M.run_genpass()
  local store_key = "RUN_GENPASS_ARGS"
  local stored_value = lvim.store.get_store(store_key)

  vim.ui.input({
    prompt = "Genpass arguments:",
    default = stored_value,
  }, function(arguments)
    local result = job.spawn({
      command = "genpass",
      args = vim.split(arguments or {}, " "),
    })

    lvim.store.set_store(store_key, arguments)

    local generated = result:result()[1]

    Log:info(("Copied generated code to clipboard: %s"):format(generated))
    vim.fn.setreg(vim.v.register or lvim.system_register, generated)
  end)
end

function M.run_ansible_vault_decrypt()
  job.spawn({ command = "ansible-vault", args = { "decrypt", vim.fn.expand("%") } })

  M.reload_file()
end

function M.run_ansible_vault_encrypt()
  job.spawn({ command = "ansible-vault", args = { "encrypt", vim.fn.expand("%") } })

  M.reload_file()
end

function M.reload_file()
  local ok = pcall(function()
    vim.cmd("e")
  end)

  if not ok then
    Log:warn(("Can not reload file since it is unsaved: %s"):format(vim.fn.expand("%")))
  end
end

function M.setup()
  require("utils.setup").init({
    name = "executables",
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          d = {
            function()
              M.run_ansible_vault_decrypt()
            end,
            "ansible-vault decrypt",
          },
          D = {
            function()
              M.run_ansible_vault_encrypt()
            end,
            "ansible-vault encrypt",
          },
          g = {
            function()
              M.run_genpass()
            end,
            "run genpass",
          },
          t = {
            function()
              M.run_markdown_toc()
            end,
            "run markdown-toc",
          },
          P = {
            function()
              M.run_md_printer()
            end,
            "run md-printer",
          },
        },
      }
    end,
  })
end

return M
