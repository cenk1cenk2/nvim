local M = {}

local log = require("ck.log")

---Runs a `gh` command for the current branch in the background.
---@param args string[]
---@param on_success? fun(stdout: string)
function M.gh(args, on_success)
  vim.system(vim.list_extend({ "gh" }, args), { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        log:error("gh %s failed: %s", table.concat(args, " "), vim.trim(result.stderr or ""))

        return
      end

      if on_success then
        on_success(vim.trim(result.stdout or ""))
      end
    end)
  end)
end

---Runs an interactive `gh` command in a floating terminal so its prompts can be answered.
---@param cmd string
function M.terminal(cmd)
  require("ck.plugins.toggleterm-nvim").create_float_terminal({ cmd = cmd, close_on_exit = false }):toggle()
end

---Opens the pull request of the current branch in a snacks gh buffer.
function M.open_pull_request()
  M.gh({ "pr", "view", "--json", "number,url" }, function(stdout)
    local pr = vim.json.decode(stdout)

    vim.cmd.edit(("gh://%s/pr/%d"):format(pr.url:match("^https?://[^/]+/([^/]+/[^/]+)"), pr.number))
  end)
end

---Diffs the working tree against the merge base of the current pull request, so a stale local target branch does not leak into the diff.
function M.diff_pull_request()
  local pr = vim.system({ "gh", "pr", "view", "--json", "baseRefName,baseRefOid" }, { text = true }):wait()
  if pr.code ~= 0 then
    log:error("Can not find a pull request for the current branch: %s", vim.trim(pr.stderr or ""))

    return
  end

  local base = vim.json.decode(pr.stdout)

  if vim.system({ "git", "cat-file", "-e", base.baseRefOid .. "^{commit}" }):wait().code ~= 0 then
    local fetch = vim.system({ "git", "fetch", "origin", base.baseRefOid }, { text = true }):wait()
    if fetch.code ~= 0 then
      log:error("Can not fetch %s: %s", base.baseRefOid, vim.trim(fetch.stderr or ""))

      return
    end
  end

  local merge_base = vim.system({ "git", "merge-base", base.baseRefOid, "HEAD" }, { text = true }):wait()
  if merge_base.code ~= 0 then
    log:error("Can not find merge base with %s: %s", base.baseRefName, vim.trim(merge_base.stderr or ""))

    return
  end

  log:info("Comparing with pull request target: %s", base.baseRefName)

  vim.cmd(":DiffviewOpen " .. vim.trim(merge_base.stdout))
end

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "h", "f" }),
          function()
            require("snacks").picker.gh_issue()
          end,
          desc = "github issues",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "F" }),
          function()
            require("snacks").picker.gh_issue({ state = "all" })
          end,
          desc = "github issues [all]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "p" }),
          function()
            require("snacks").picker.gh_pr()
          end,
          desc = "github pull requests",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "P" }),
          function()
            require("snacks").picker.gh_pr({ state = "all" })
          end,
          desc = "github pull requests [all]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "r" }),
          function()
            require("snacks").picker.gh_actions()
          end,
          desc = "github current commands",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "d" }),
          function()
            M.diff_pull_request()
          end,
          desc = "github pr diff",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "s" }),
          function()
            M.open_pull_request()
          end,
          desc = "github pr summary",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "o" }),
          function()
            M.gh({ "pr", "view", "--web" })
          end,
          desc = "github pr open in browser",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "u" }),
          function()
            M.gh({ "pr", "view", "--json", "url", "--jq", ".url" }, function(url)
              vim.fn.setreg("+", url)
              log:info("Copied pull request url: %s", url)
            end)
          end,
          desc = "github pr copy url",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "m" }),
          function()
            M.terminal("gh pr create")
          end,
          desc = "github create pr",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "M" }),
          function()
            M.terminal("gh pr merge --delete-branch")
          end,
          desc = "github merge branch through pr",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "a" }),
          function()
            M.terminal("gh pr merge --auto --delete-branch")
          end,
          desc = "github pr auto-merge",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "A" }),
          function()
            M.gh({ "pr", "review", "--approve" }, function()
              log:info("Approved pull request.")
            end)
          end,
          desc = "github pr approve",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "b" }),
          function()
            M.gh({ "pr", "update-branch", "--rebase" }, function()
              log:info("Rebased pull request onto its target.")
            end)
          end,
          desc = "github pr rebase",
        },
        {
          fn.wk_keystroke({ categories.GIT, "h", "O" }),
          function()
            M.terminal("gh pr checks --watch")
          end,
          desc = "github pr checks",
        },
      }
    end,
  })
end

return M
