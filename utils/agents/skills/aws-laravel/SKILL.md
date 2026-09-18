---
name: aws-laravel
description: aws-laravel Manual for the aws-laravel MCP server - read-only AWS account inspection through Granted SSO, the profile-and-region rule, and the approval every command waits on. Load before the first call to that server. Not for AWS documentation lookups, and not for anything that changes an AWS resource.
argumentHint: "[account] [what you want to look at]"
---

## The aws-laravel Server

Read-only inspection of the Laravel Cloud AWS accounts, running AWS CLI commands under Granted SSO credentials. **Load this before the first call to it.**

- **Transport:** local stdio.
- **Credentials:** a filtered AWS config holding only the `ReadOnlyAccessPlusK8s` profiles. Admin roles are absent from it, so no command can reach one.
- **Registered tools:** `suggest_aws_commands` and `call_aws`. Nothing else.

Edits to the catalog entry go through `config-mcp`.

## The Gate - Every `call_aws` Waits

**`call_aws` needs explicit approval, every invocation.** No general go reaches it - not `g` / `go` / `yolo`, not autopilot, not approval of an earlier command.

The reason is the tool's shape. `call_aws` takes an arbitrary CLI command string, so unlike a server registering one tool per operation, nothing about the tool name says what a given call does. The captain approves the **command**, not the tool.

**An approval covers the command it named and no other.** A different account, a different region, or a different command against the same account is a new ask.

**`suggest_aws_commands` is blessed.** It maps a natural-language query onto candidate CLI commands and touches no account. Use it to settle a command before asking to run one.

## Every Call Carries `--profile` and `--region`

**`--profile`** - omitted, the filtered config has no default and the call fails outright. Supply it anyway rather than reading an error.

**`--region`** - omitted, the command silently answers about `us-east-1`. That is the dangerous one: right shape, wrong region, nothing errors. Pass it on every call and name it in the answer.

Profiles are `<AccountName>/<RoleName>`, every one `.../ReadOnlyAccessPlusK8s`. The region is carried in the account name - `...-EU-London-...` is `eu-west-2`; `tools/add-all-eks-clusters.sh` in `cloud-infrastructure` holds the full label-to-region map.

## Startup - the SSO Session Is the Captain's

The server holds no credentials of its own. It reads `~/.aws/config-readonly`, whose profiles resolve through Granted's `credential_process`.

**There is no auto-login.** An expired SSO token makes every `call_aws` fail with a credential error rather than opening a browser, which is deliberate. When calls start failing that way, say so and let the captain run `assume`; do not work around it.

**A wedged server is the other failure mode, and it looks nothing like the first.** `call_aws` stops responding entirely - no error, no credential message, just silence past the foreground window and then an idle-timeout abort. It is the server, not the query: a command that hung for the full timeout returned in under a second once the server was reconnected. So when a call goes quiet, say so and ask the captain to reconnect the server; do not narrow the query, split it, or wait out the timeout.

Both files are written by scripts in the `cloud-infrastructure` repository, and both fetch the account set live from AWS IAM Identity Center rather than reading each other:

| Script                           | Writes                                          |
| -------------------------------- | ----------------------------------------------- |
| `tools/aws-populate.sh`          | `~/.aws/config` - every account and role        |
| `tools/aws-populate-readonly.sh` | `~/.aws/config-readonly` - the read-only subset |

A local config can be stale while the other is current, so a profile missing from one is not evidence it does not exist. Regenerating is the captain's call.

## Read-Only Is Enforced, Secrecy Is Not

Three layers block a write: the filtered config carries no admin role, `READ_OPERATIONS_ONLY` refuses any command AWS classifies above Read, and the IAM role is read-only. A mutating command returns `Execution of this operation is denied by security policy.` - that is the layer working, not something to route around.

**What none of them block is a read that returns a secret.** `secretsmanager get-secret-value` and its relatives are classified Read. Report paths, names and shapes; when a task genuinely needs a value, name what you need and why, then stop - it is the captain's to run.

## Documentation Lives Elsewhere

`aws-docs` answers what a service does and how its API is shaped. This server answers what is actually in the accounts. A question about AWS behaviour goes to `aws-docs` and costs no approval.

## Process

1. Settle the command, using `suggest_aws_commands` when unsure.
2. Resolve the account to a profile and the region, and say how you resolved them.
3. Ask for approval naming the profile, the region and the exact command. Wait.
4. Run it once, as approved.
5. Report the finding, not the transcript, naming the profile and region it came from.
