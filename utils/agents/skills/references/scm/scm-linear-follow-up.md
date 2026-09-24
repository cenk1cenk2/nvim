# SCM Linear Follow-Up

Whether a branch, its commits, and its MR/PR may name a Linear issue at all. The keywords and surfaces for linking an issue are in `commit-trailers-linear`; this file decides whether to link before any of them is used.

**Linear moves every linked issue through the team's workflow statuses, and a Done issue is not exempt.** A follow-up MR whose title, branch, or `refs` trailer names a Done issue moves it back to In Progress the moment the MR opens. A non-closing word such as `refs` only withholds the **merge** status; Linear's docs say it "will still move the issue through other statuses per Workflow settings". So `refs` does not protect a closed issue.

## Pick the relationship first

Before naming the branch, writing a commit trailer, or drafting the title, fetch every issue the work touches with the workspace's Linear MCP `get_issue` and read its `statusType`. Never assume the state from memory or from earlier in the conversation.

| `statusType` | This work | Relationship |
|---|---|---|
| `triage`, `backlog`, `unstarted`, `started` | delivers or continues the issue's open work | **Link** — ID in the title and the branch, `closes` on the final MR/PR and `refs` on a partial one, per `commit-trailers` and `commit-trailers-linear`. |
| `completed`, `canceled` | a follow-up, fix-up, or tweak to work already closed | **Mention only** — nothing that links, per the next section. |

## A follow-up to a closed issue

- **No issue ID in the MR/PR title.**
- **No issue ID in the branch name.** Name the branch by what it does: `agent/<slug>`, never `agent/<ID>-<slug>`. A branch in Linear's branch format links on its own.
- **Mention the issue in the description as a plain markdown link** to its Linear URL, with no magic word in front: `Follow-up to [K-123 - <title>](https://linear.app/<workspace>/issue/K-123)`. On GitLab only the title, the branch, and a magic word in the description link, so a bare ID or URL does not.
- **Never `ref`, `refs`, `references`, `part of`, `contributes to`, `toward`, or `towards`** in front of a closed issue, and never `related to` on GitLab, where Linear lists it among those words.
- **On GitHub**, write `Related to <ID>` to link with no status change, or `Ignore <ID>` (or `skip <ID>`) when no link is wanted at all.
- **Commit trailers follow the same rule on GitHub.** Linear on GitLab ignores commit messages. On GitHub, commit linking moves the issue when a magic word precedes its ID, so a GitHub commit carries no magic word in front of a closed issue.
- **When the follow-up genuinely reopens the work**, open a new Linear issue for it and link that one by the rule above. Never revive the closed issue through an MR.

An issue linked to several MRs/PRs updates when the **final** one reaches the state, so the issue follows whichever linked MR is still moving.

## What Linear documents

From [linear.app/docs/gitlab](https://linear.app/docs/gitlab) and [linear.app/docs/github](https://linear.app/docs/github):

- Links come from the issue ID in the MR/PR title, the ID in the branch name, or a magic word plus the ID in the description. On GitLab, "the integration cannot link MRs via comments or commit messages".
- Closing words move the issue through the workflow and apply the merge status. Non-closing words move it through the other statuses and skip only the merge status.
- On GitHub, relation words `relates to` and `related to` mark the PR related "with no status changes", and `skip` or `ignore` with an ID prevents the link.

Unverified on GitLab: relation words and `skip` / `ignore`. The GitLab page lists `related to` as a contributing word and does not mention `skip` or `ignore`, so neither is relied on there.
