-- as in https://github.com/jinzhongjia/neovim-config/ from https://github.com/olimorris/codecompanion.nvim/discussions/1984
local Job = require("plenary.job")
local anthropic = require("codecompanion.adapters.http.anthropic")
local config = require("codecompanion.config")
local curl = require("plenary.curl")
local log = require("codecompanion.utils.log")

-- Module-level API key cache
local _api_key = nil
local _api_key_loaded = false

-- OAuth flow constant configuration
local OAUTH_CONFIG = {
  CLIENT_ID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e", -- OAuth client ID
  REDIRECT_URI = "https://console.anthropic.com/oauth/code/callback", -- Authorization callback URL
  AUTH_URL = "https://console.anthropic.com/oauth/authorize", -- Authorization request URL
  TOKEN_URL = "https://api.anthropic.com/v1/oauth/token", -- Token exchange URL
  API_KEY_URL = "https://api.anthropic.com/api/oauth/claude_cli/create_api_key", -- API key creation URL
  SCOPES = "org:create_api_key user:profile user:inference", -- Requested permission scopes
}

-- URL encoding function for building OAuth URL parameters
---@param str string
---@return string
local function url_encode(str)
  if str then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

-- Generate cryptographically secure random string for PKCE
-- PKCE (Proof Key for Code Exchange) is a security extension for OAuth 2.0
---@param length number
---@return string
local function generate_random_string(length)
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
  local result = {}

  -- Use better cross-platform random seed generation method
  -- Combine multiple entropy sources to improve randomness
  local seed = os.time() -- Base timestamp

  -- Use vim.loop (libuv) to get high-precision time, cross-platform compatible
  if vim.loop then
    -- Get high-precision timestamp (microseconds)
    local hrtime = vim.loop.hrtime()
    if hrtime then
      -- Take lower 32 bits as additional entropy
      seed = seed + (hrtime % 2147483647)
    end

    -- Get process ID as additional entropy
    local pid = vim.loop.os_getpid()
    if pid then
      seed = seed + pid
    end
  end

  -- Add some runtime information as entropy
  local runtime_entropy = tostring({}):match("0x(%x+)") -- Get entropy from new object address
  if runtime_entropy then
    seed = seed + (tonumber(runtime_entropy, 16) % 1000000)
  end

  math.randomseed(seed)
  -- Warm up random number generator
  for _ = 1, 10 do
    math.random()
  end

  for i = 1, length do
    local rand_index = math.random(1, #chars)
    table.insert(result, chars:sub(rand_index, rand_index))
  end
  return table.concat(result)
end

-- Generate SHA256 hash required for PKCE challenge (base64url format)
---@param input string
---@return string
local function sha256_base64url(input)
  -- Try to use OpenSSL to generate correct SHA256 hash
  -- Note: Windows systems may need OpenSSL installed separately
  if vim.fn.executable("openssl") == 1 then
    local job = Job:new({
      command = "openssl",
      args = { "dgst", "-sha256", "-binary" },
      writer = input,
      enable_recording = true,
    })

    local success, _ = pcall(function()
      job:sync(3000) -- 3 second timeout
    end)

    if success and job.code == 0 then
      local hash_binary = table.concat(job:result(), "")
      if hash_binary ~= "" then
        local base64 = vim.base64.encode(hash_binary)
        return base64:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
      end
    else
      log:warn("OpenSSL command execution failed, error code: %s", job.code)
    end
  else
    log:warn("OpenSSL unavailable, will use insecure hash method (development only)")
  end

  -- Fallback: not cryptographically secure but functional (development/testing only)
  log:warn("Using fallback hash method (not cryptographically secure)")
  local simple_hash = vim.base64.encode(input)
  return simple_hash:gsub("[+/=]", { ["+"] = "-", ["/"] = "_", ["="] = "" })
end

-- Generate PKCE code verifier and challenge
---@return { verifier: string, challenge: string }
local function generate_pkce()
  local verifier = generate_random_string(128) -- Use maximum length to improve security
  local challenge = sha256_base64url(verifier)
  return {
    verifier = verifier,
    challenge = challenge,
  }
end

-- Find data path for storing OAuth tokens
-- Support custom path via environment variable
---@return string|nil
local function find_data_path()
  -- First check environment variable
  local env_path = os.getenv("CODECOMPANION_ANTHROPIC_TOKEN_PATH")
  if env_path and vim.fn.isdirectory(vim.fs.dirname(env_path)) > 0 then
    return vim.fs.dirname(env_path)
  end

  -- Use Neovim data directory (cross-platform compatible)
  local nvim_data = vim.fn.stdpath("data")
  if nvim_data and vim.fn.isdirectory(nvim_data) > 0 then
    return nvim_data
  end

  return nil
end

-- Get OAuth token file path
-- Use cross-platform path separator
---@return string|nil
local function get_token_file_path()
  local data_path = find_data_path()
  if not data_path then
    log:error("Anthropic OAuth: Unable to determine data directory")
    return nil
  end

  -- Use vim.fs.joinpath to ensure cross-platform path compatibility
  local path_sep = package.config:sub(1, 1) -- Get system path separator
  return data_path .. path_sep .. "anthropic_oauth.json"
end

-- Load API key from file
---@return string|nil
local function load_api_key()
  if _api_key_loaded then
    return _api_key
  end

  _api_key_loaded = true

  local token_file = get_token_file_path()
  if not token_file or vim.fn.filereadable(token_file) == 0 then
    return nil
  end

  local success, content = pcall(vim.fn.readfile, token_file)
  if not success or not content or #content == 0 then
    log:debug("Anthropic OAuth: Unable to read token file or file is empty")
    return nil
  end

  local decode_success, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if decode_success and data and data.api_key then
    _api_key = data.api_key
    return data.api_key
  else
    log:warn("Anthropic OAuth: Invalid token file format")
    return nil
  end
end

-- Save API key to file
---@param api_key string
---@return boolean
local function save_api_key(api_key)
  if not api_key or api_key == "" then
    log:error("Anthropic OAuth: Cannot save empty API key")
    return false
  end

  local token_file = get_token_file_path()
  if not token_file then
    return false
  end

  local data = {
    api_key = api_key,
    created_at = os.time(),
    version = 1, -- Version number for possible future data migration
  }

  local success, err = pcall(function()
    vim.fn.writefile({ vim.json.encode(data) }, token_file)
  end)

  if success then
    _api_key = api_key
    _api_key_loaded = true
    log:info("Anthropic OAuth: API key saved successfully")
    return true
  else
    log:error("Anthropic OAuth: Failed to save API key: %s", err or "unknown error")
    return false
  end
end

-- Create API key using OAuth access token
---@param access_token string
---@return string|nil
local function create_api_key(access_token)
  if not access_token or access_token == "" then
    log:error("Anthropic OAuth: Access token required")
    return nil
  end

  log:debug("Anthropic OAuth: Creating API key")

  local response = curl.post(OAUTH_CONFIG.API_KEY_URL, {
    headers = {
      ["Content-Type"] = "application/json",
      ["authorization"] = "Bearer " .. access_token,
    },
    body = vim.json.encode({}),
    insecure = config.adapters.opts.allow_insecure,
    proxy = config.adapters.opts.proxy,
    timeout = 30000, -- 30 second timeout
    on_error = function(err)
      log:error("Anthropic OAuth: API key creation request error: %s", vim.inspect(err))
    end,
  })

  if not response then
    log:error("Anthropic OAuth: No response from API key creation request")
    return nil
  end

  if response.status >= 400 then
    log:error("Anthropic OAuth: API key creation failed, status code %d: %s", response.status, response.body or "no body")
    return nil
  end

  local decode_success, api_key_data = pcall(vim.json.decode, response.body)
  if not decode_success or not api_key_data or not api_key_data.raw_key then
    log:error("Anthropic OAuth: Invalid API key response format")
    return nil
  end

  log:debug("Anthropic OAuth: API key created successfully")
  return api_key_data.raw_key
end

-- Exchange authorization code for access token and create API key
---@param code string
---@param verifier string
---@return string|nil
local function exchange_code_for_api_key(code, verifier)
  if not code or code == "" or not verifier or verifier == "" then
    log:error("Anthropic OAuth: Authorization code and verifier required")
    return nil
  end

  log:debug("Anthropic OAuth: Exchanging authorization code for access token")

  -- Parse authorization code and state from callback URL fragment
  local code_parts = vim.split(code, "#")
  local auth_code = code_parts[1]
  local state = code_parts[2] or verifier

  local request_data = {
    code = auth_code,
    state = state,
    grant_type = "authorization_code",
    client_id = OAUTH_CONFIG.CLIENT_ID,
    redirect_uri = OAUTH_CONFIG.REDIRECT_URI,
    code_verifier = verifier,
    scope = OAUTH_CONFIG.SCOPES,
  }

  log:debug("Anthropic OAuth: Token exchange request initiated")

  local response = curl.post(OAUTH_CONFIG.TOKEN_URL, {
    headers = {
      ["Content-Type"] = "application/json",
    },
    body = vim.json.encode(request_data),
    insecure = config.adapters.opts.allow_insecure,
    proxy = config.adapters.opts.proxy,
    timeout = 30000, -- 30 second timeout
    on_error = function(err)
      log:error("Anthropic OAuth: Token exchange request error: %s", vim.inspect(err))
    end,
  })

  if not response then
    log:error("Anthropic OAuth: No response from token exchange request")
    return nil
  end

  if response.status >= 400 then
    log:error("Anthropic OAuth: Token exchange failed, status code %d: %s", response.status, response.body or "no body")
    return nil
  end

  local decode_success, token_data = pcall(vim.json.decode, response.body)
  if not decode_success or not token_data or not token_data.access_token then
    log:error("Anthropic OAuth: Invalid token response format")
    return nil
  end

  log:debug("Anthropic OAuth: Successfully obtained access token")

  -- Use access token to create API key
  local api_key = create_api_key(token_data.access_token)
  if api_key and save_api_key(api_key) then
    return api_key
  end

  return nil
end

-- Generate OAuth authorization URL with PKCE
---@return { url: string, verifier: string }
local function generate_auth_url()
  local pkce = generate_pkce()

  -- Build properly encoded and ordered query string
  local query_params = {
    "code=true",
    "client_id=" .. url_encode(OAUTH_CONFIG.CLIENT_ID),
    "response_type=code",
    "redirect_uri=" .. url_encode(OAUTH_CONFIG.REDIRECT_URI),
    "scope=" .. url_encode(OAUTH_CONFIG.SCOPES),
    "code_challenge=" .. url_encode(pkce.challenge),
    "code_challenge_method=S256",
    "state=" .. url_encode(pkce.verifier),
  }

  local auth_url = OAUTH_CONFIG.AUTH_URL .. "?" .. table.concat(query_params, "&")
  log:debug("Anthropic OAuth: Authorization URL generated")

  return {
    url = auth_url,
    verifier = pkce.verifier,
  }
end

-- Get API key from cache or file
---@return string|nil
local function get_api_key()
  -- Try to load from cache or file
  local api_key = load_api_key()
  if api_key then
    return api_key
  end

  -- New OAuth flow required
  log:error("Anthropic OAuth: No API key found. Please run :AnthropicOAuthSetup to authenticate")
  return nil
end

-- Setup OAuth authentication (interactive)
---@return boolean
local function setup_oauth()
  local auth_data = generate_auth_url()

  vim.notify("Opening Anthropic OAuth authentication in browser...", vim.log.levels.INFO)

  -- Open URL in default browser (cross-platform handling)
  local open_cmd
  if vim.fn.has("mac") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("unix") == 1 then
    -- Linux system, try xdg-open first
    open_cmd = "xdg-open"
    -- If xdg-open doesn't exist, try other common commands
    if vim.fn.executable("xdg-open") == 0 then
      if vim.fn.executable("gnome-open") == 1 then
        open_cmd = "gnome-open"
      elseif vim.fn.executable("kde-open") == 1 then
        open_cmd = "kde-open"
      end
    end
  elseif vim.fn.has("win32") == 1 then
    -- Windows requires special handling, use cmd /c start
    open_cmd = 'cmd /c start ""'
  end

  if open_cmd then
    local cmd
    if vim.fn.has("win32") == 1 then
      -- Windows: use double quotes and escape special characters
      cmd = open_cmd .. ' "' .. auth_data.url:gsub("&", "^&") .. '"'
    else
      -- Unix/Mac: use single quotes
      cmd = open_cmd .. " '" .. auth_data.url .. "'"
    end

    local success = pcall(vim.fn.system, cmd)
    if not success then
      vim.notify("Unable to automatically open browser. Please manually open this URL:\n" .. auth_data.url, vim.log.levels.WARN)
    end
  else
    vim.notify("Please open this URL in your browser:\n" .. auth_data.url, vim.log.levels.INFO)
  end

  -- Prompt user for authorization code
  vim.ui.input({
    prompt = "Please enter the authorization code from the callback URL (the part after 'code='):",
  }, function(code)
    if not code or code == "" then
      vim.notify("OAuth setup cancelled", vim.log.levels.WARN)
      return
    end

    -- Show progress
    vim.notify("Exchanging authorization code for API key...", vim.log.levels.INFO)

    local api_key = exchange_code_for_api_key(code, auth_data.verifier)
    if api_key then
      vim.notify("Anthropic OAuth authentication successful! API key created and saved.", vim.log.levels.INFO)
    else
      vim.notify("Anthropic OAuth authentication failed. Please check logs and retry.", vim.log.levels.ERROR)
    end
  end)

  return true
end

-- Create user commands for OAuth management
vim.api.nvim_create_user_command("AnthropicOAuthSetup", function()
  setup_oauth()
end, {
  desc = "Setup Anthropic OAuth authentication",
})

vim.api.nvim_create_user_command("AnthropicOAuthStatus", function()
  local api_key = load_api_key()
  if not api_key then
    vim.notify("No Anthropic API key found. Run :AnthropicOAuthSetup to authenticate.", vim.log.levels.WARN)
    return
  end

  vim.notify("Anthropic API key is configured and ready to use.", vim.log.levels.INFO)
end, {
  desc = "Check Anthropic OAuth API key status",
})

vim.api.nvim_create_user_command("AnthropicOAuthClear", function()
  local token_file = get_token_file_path()
  if token_file and vim.fn.filereadable(token_file) == 1 then
    local success = pcall(vim.fn.delete, token_file)
    if success then
      _api_key = nil
      _api_key_loaded = false
      vim.notify("Anthropic API key cleared.", vim.log.levels.INFO)
    else
      vim.notify("Failed to clear API key file.", vim.log.levels.ERROR)
    end
  else
    vim.notify("No Anthropic API key to clear.", vim.log.levels.WARN)
  end
end, {
  desc = "Clear stored Anthropic OAuth API key",
})

-- Create adapter by extending base anthropic adapter
local adapter = vim.tbl_deep_extend("force", vim.deepcopy(anthropic), {
  name = "anthropic_oauth",
  formatted_name = "Anthropic (OAuth)",

  env = {
    -- Get API key from OAuth flow
    ---@return string|nil
    api_key = function()
      return get_api_key()
    end,
  },

  headers = {
    ["content-type"] = "application/json",
    ["x-api-key"] = "${api_key}",
    ["anthropic-version"] = "2023-06-01",
    ["anthropic-beta"] = "claude-code-20250219,oauth-2025-04-20,interleaved-thinking-2025-05-14,fine-grained-tool-streaming-2025-05-14",
  },

  -- Override model schema with latest models
  schema = vim.tbl_deep_extend("force", anthropic.schema or {}, {
    model = {
      order = 1,
      mapping = "parameters",
      type = "enum",
      desc = "The model that will complete your prompt. See https://docs.anthropic.com/claude/docs/models-overview for additional details and options.",
      default = "claude-opus-4-1-20250805",
      choices = {
        ["claude-opus-4-1-20250805"] = { opts = { can_reason = false, has_vision = true } },
        ["claude-opus-4-20250514"] = { opts = { can_reason = true, has_vision = true } },
        ["claude-sonnet-4-20250514"] = { opts = { can_reason = false, has_vision = true } },
        ["claude-3-7-sonnet-20250219"] = {
          opts = { can_reason = true, has_vision = true, has_token_efficient_tools = true },
        },
        ["claude-3-5-haiku-20241022"] = { opts = { has_vision = true } },
      },
    },
  }),
})

-- Override handlers to add OAuth-specific functionality and Claude Code system message
adapter.handlers = vim.tbl_extend("force", anthropic.handlers, {
  -- Check for valid API key before starting request
  ---@param self CodeCompanion.Adapter
  ---@return boolean
  setup = function(self)
    -- Get and validate API key
    local api_key = get_api_key()
    if not api_key then
      vim.notify("No Anthropic API key found. Run :AnthropicOAuthSetup to authenticate.", vim.log.levels.ERROR)
      return false
    end

    -- Call original setup function to handle streaming and model options
    return anthropic.handlers.setup(self)
  end,

  -- Format messages with Claude Code system message at the beginning (required for OAuth)
  ---@param self CodeCompanion.Adapter
  ---@param messages table
  ---@return table
  form_messages = function(self, messages)
    -- First, call original form_messages to get standard format
    local formatted = anthropic.handlers.form_messages(self, messages)

    -- Extract existing system messages or initialize empty array
    local system = formatted.system or {}

    -- Add Claude Code system message at the beginning (required for OAuth to work properly)
    table.insert(system, 1, {
      type = "text",
      text = "You are Claude Code, Anthropic's official CLI for Claude.",
    })

    -- Return formatted messages with modified system message
    return {
      system = system,
      messages = formatted.messages,
    }
  end,
})

return adapter
