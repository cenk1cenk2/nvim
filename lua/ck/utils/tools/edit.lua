local State = require("mcphub.state")
local approvals = require("codecompanion.interactions.chat.tools.approvals")

local fmt = string.format

local function make_response(status, msg)
  return { status = status, data = msg }
end

local DESCRIPTION = [[Replace multiple sections in a file using SEARCH/REPLACE blocks that define exact changes to specific parts of the file. This tool starts an interactive edit session in Neovim where the user can accept or reject individual changes.

The result includes:
1. A diff comparing the file before and after the edit session
2. Feedback from parsing, matching, and user decisions
3. Diagnostics in the file after the edit session

IMPORTANT: You MUST give EXTREME care to the result of this tool. The diff shows what changes were made, and the feedback provides context on how blocks were applied.
IMPORTANT: Once edits are shown in the buffer, the user might make additional changes. This is intentional and MUST be respected in subsequent calls.]]

local INPUT_DESCRIPTION = [[One or more SEARCH/REPLACE blocks following this exact format:

<<<<<<< SEARCH
[exact content to find]
=======
[new content to replace with]
>>>>>>> REPLACE

CRITICAL:
- When there are two or more related changes needed in a file, always use multiple SEARCH/REPLACE blocks in the diff from the start of the file to the end.
- The markers `<<<<<<< SEARCH`, `=======`, and `>>>>>>> REPLACE` MUST be exact with no other characters on the line.

Examples:

1. Multiple changes in one call from top to bottom:
<<<<<<< SEARCH
import os
=======
import os
import json
>>>>>>> REPLACE

<<<<<<< SEARCH
def process_data():
    # old implementation
    pass
=======
def process_data():
    # new implementation
    with open('data.json') as f:
        return json.load(f)
>>>>>>> REPLACE

2. Deletion example:
<<<<<<< SEARCH
def unused_function():
    return "delete me"

=======
>>>>>>> REPLACE

CRITICAL RULE: When SEARCH or REPLACE content includes lines starting with `<<<<<<<`, `=======`, or `>>>>>>>`, escape them with a backslash.

CRITICAL rules:
1. SEARCH content must match the file section EXACTLY (character-for-character including whitespace and indentation).
2. SEARCH/REPLACE blocks will ONLY replace the first match occurrence. Use multiple blocks for multiple occurrences.
3. Keep blocks concise — include just the changing lines and a few surrounding lines for uniqueness.
4. To move code: use two blocks (delete from original + insert at new location).
5. To delete code: use empty REPLACE section.

IMPORTANT: Batch multiple related changes for a file into a single call.]]

---@class CodeCompanion.Tool.McpHubEdit: CodeCompanion.Tools.Tool
return {
  name = "insert_edit_into_file",
  cmds = {
    ---@param self CodeCompanion.Tools
    ---@param args table
    ---@param opts table
    function(self, args, opts)
      local path = args.path
      if not path or vim.trim(path) == "" then
        return opts.output_cb(make_response("error", "Missing required parameter: path"))
      end

      local diff = args.diff
      if not diff or vim.trim(diff) == "" then
        return opts.output_cb(make_response("error", "Missing required parameter: diff"))
      end

      local config = State.config and State.config.builtin_tools and State.config.builtin_tools.edit_file or {}
      local EditSession = require("mcphub.native.neovim.files.edit_file.edit_session")

      local is_approved = approvals:is_approved(self.chat.bufnr, { tool_name = "insert_edit_into_file" })

      local session = EditSession.new(path, diff, config)
      session:start({
        interactive = not is_approved,
        on_success = function(summary)
          local display_path = vim.fn.fnamemodify(path, ":.")
          local explanation = args.explanation or ""
          local msg = fmt("Edited `%s`", display_path)
          if explanation ~= "" then
            msg = msg .. "\n" .. explanation
          end
          msg = msg .. "\n\n" .. summary

          opts.output_cb(make_response("success", msg))
        end,
        on_error = function(error_report)
          opts.output_cb(make_response("error", error_report))
        end,
      })
    end,
  },
  schema = {
    type = "function",
    ["function"] = {
      name = "insert_edit_into_file",
      description = DESCRIPTION,
      parameters = {
        type = "object",
        properties = {
          path = {
            type = "string",
            description = "The absolute path to the file to modify",
          },
          diff = {
            type = "string",
            description = INPUT_DESCRIPTION,
          },
          explanation = {
            type = "string",
            description = "Brief explanation of what the edits accomplish",
          },
        },
        required = { "path", "diff", "explanation" },
        additionalProperties = false,
      },
      strict = true,
    },
  },
  handlers = {
    ---@param self CodeCompanion.Tool.McpHubEdit
    ---@param meta { tools: table }
    ---@return boolean
    prompt_condition = function(self, meta)
      if self.opts.require_approval_before then
        return true
      end

      return false
    end,
  },
  output = {
    ---@param self CodeCompanion.Tool.McpHubEdit
    ---@param opts table
    ---@return string
    cmd_string = function(self, opts)
      local args = self.args
      local display_path = args.path and vim.fn.fnamemodify(args.path, ":.") or "unknown"

      return fmt("Edit `%s`", display_path)
    end,

    ---@param self CodeCompanion.Tool.McpHubEdit
    ---@param meta {tools: CodeCompanion.Tools}
    ---@return string
    prompt = function(self, meta)
      local args = self.args
      local display_path = args.path and vim.fn.fnamemodify(args.path, ":.") or "unknown"

      return fmt("Apply edits to `%s`?", display_path)
    end,

    ---@param self CodeCompanion.Tool.McpHubEdit
    ---@param stdout table|nil
    ---@param meta { tools: table, cmd: table }
    success = function(self, stdout, meta)
      if stdout then
        local chat = meta.tools.chat
        local output = vim.iter(stdout):flatten():join("\n")
        chat:add_tool_output(self, output)
      end
    end,

    ---@param self CodeCompanion.Tool.McpHubEdit
    ---@param stderr table
    ---@param meta { tools: CodeCompanion.Tools, cmd: string}
    error = function(self, stderr, meta)
      if stderr then
        local chat = meta.tools.chat
        local errors = vim.iter(stderr):flatten():join("\n")
        chat:add_tool_output(self, "**Error:**\n" .. errors)
      end
    end,

    ---@param self CodeCompanion.Tool.McpHubEdit
    ---@param meta {tools: CodeCompanion.Tools}
    rejected = function(self, meta)
      local chat = meta.tools.chat
      chat:add_tool_output(self, "Edit was rejected by user.")
    end,
  },
}
