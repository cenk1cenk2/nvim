local M = {}

local data_key = "CK_FLATTEN_DATA"

local function handler_name()
  local name = vim.env.CK_FLATTEN_HANDLER
  if name == nil or name == "" then
    return nil
  end

  return name
end

local function load_handler(name)
  local ok, handler = pcall(require, "ck.modules." .. name)
  if not ok then
    vim.notify(("flatten handler not found: %s"):format(name), vim.log.levels.ERROR)

    return nil
  end

  return handler
end

function M.guest_data()
  local name = handler_name()
  if not name then
    return nil
  end

  local handler = load_handler(name)
  if not handler or type(handler.flatten_guest_data) ~= "function" then
    return nil
  end

  return {
    handler = name,
    payload = handler.flatten_guest_data(),
  }
end

function M.pre_open(opts)
  local data = opts.data
  if type(data) ~= "table" or type(data.handler) ~= "string" then
    return
  end

  vim.g[data_key] = data

  local handler = load_handler(data.handler)
  if handler and type(handler.flatten_pre_open) == "function" then
    handler.flatten_pre_open(data.payload, data)
  end
end

function M.get_data(handler)
  local data = vim.g[data_key]
  if type(data) ~= "table" then
    return nil
  end

  if handler and data.handler ~= handler then
    return nil
  end

  return data.payload
end

function M.clear_data(handler)
  local data = vim.g[data_key]
  if handler and type(data) == "table" and data.handler ~= handler then
    return
  end

  vim.g[data_key] = nil
end

return M
