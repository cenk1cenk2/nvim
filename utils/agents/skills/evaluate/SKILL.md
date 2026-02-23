---
name: evaluate
description: Evaluate code changes to determine progress against the current plan. Use when switching from planning to reviewing implemented work.
disable-model-invocation: true
---

## Evaluation Mode: Progress Evaluation

> **IMPORTANT: Enter plan mode if not already in it.**
>
> - Use `EnterPlanMode` tool if not currently in plan mode
> - Read and update the EXISTING plan file from Assistant Mode
> - If no plan file exists, read conversation context to understand the plan
> - Use plan file to document analysis and findings
> - Update TodoWrite plan based on actual implementation discovered
>
> **CRITICAL: This is an evaluation-only workflow - NOT implementation.**
>
> - Do NOT implement or write code unless the user EXPLICITLY asks you to implement
> - Do NOT proceed to the next step, suggest next actions, or continue working without an explicit user prompt
> - The USER implements - you only evaluate and provide feedback
> - After providing evaluation results, STOP and WAIT for the user to respond
> - After answering a question, STOP and WAIT for the user to respond
> - NEVER take initiative to move forward - every action requires a user prompt
> - After evaluation, transition back to Assistant Mode to guide next steps only WHEN the user asks
> - Use the Skill tool to discover and invoke Assistant Mode when evaluation is complete and user requests it
>
> **CRITICAL: ALWAYS dump evaluation results and updated plan into the chat window.**
>
> - The user CANNOT see plan files or internal tool outputs directly
> - After evaluation, output the FULL updated plan to the chat window showing current state
> - Include: completed items, remaining items, deviations found, and feedback
> - When the plan changes during evaluation, output the COMPLETE updated plan (not just the diff)
> - Use markdown formatting for readability

### Context

- This is invoked during Assistant Mode when switching from planning/discussion to evaluation
- The user has implemented changes according to the plan we created together
- Your role shifts from collaborative planning to thorough evaluation of what's been done

### Evaluation Process

1. **Assess Implementation:**
   - Use Git MCP tools to review commits, diffs
   - Fallback to local git commands (`git status`, `git diff`, `git log`) to review local changes
   - Read modified files directly to understand the actual implementation
   - Compare changes against the original plan and requirements

2. **Track Progress:**
   - Review the TodoWrite plan and identify which items have been completed
   - Mark completed items in the todo list
   - Update the plan to reflect any new work discovered or remaining tasks
   - Note any deviations from the original plan
   - **Output the full updated plan to the chat window** so the user can see current state

3. **Identify Deviations:**
   - Spot differences between planned approach and actual implementation
   - For each deviation, ask clarifying questions to understand the reasoning
   - Use sequential thinking to assess if deviations introduce risks or problems
   - Don't assume deviations are wrong - they may be improvements or necessary adaptations

4. **Provide Comprehensive Feedback:**
   - **Output all findings and the updated plan directly in the chat window**
   - Deliver feedback as a direct response message (not in Linear issues)
   - Highlight what has been successfully accomplished
   - Point out potential issues, edge cases, or concerns discovered
   - Ask questions about unclear or unexpected changes
   - Suggest next steps or improvements where appropriate
   - Be constructive and specific with examples (file paths, line numbers)

5. **Fulfill Assistant Duties:**
   - Proactively identify potential pitfalls in the implemented changes
   - Question anything that seems risky or unclear
   - Think critically about whether the implementation achieves the original goals
   - Update understanding based on the actual code changes
   - Keep the plan synchronized with reality

### Memory Management (Knowledge Graph)

> **CRITICAL: ALWAYS persist evaluation findings to the memory knowledge graph.**
>
> Use `mcp__mcphub__memory__*` tools so future sessions can resume with full context.

**During evaluation, update memory with:**

- **Progress snapshot:** Which plan items are completed, in progress, or blocked — update the plan/project entity observations
- **Deviations found:** Record any differences between planned and actual implementation, including whether they were intentional improvements or issues
- **Evaluation findings:** Technical insights, edge cases discovered, risks identified during code review
- **Updated plan state:** After evaluation adjusts the plan, persist the updated plan summary to memory
- **Remaining work:** Clearly document what still needs to be done so a future session can pick up where this one left off

**How to store:**

- Use `mcp__mcphub__memory__add_observations` to update existing project/plan entities with evaluation results
- Use `mcp__mcphub__memory__create_entities` if a new feature or component was discovered during evaluation
- Use `mcp__mcphub__memory__create_relations` to link newly discovered components to the project
- Keep observations concise and actionable — they should allow a future session to resume work

**Memory enables continuity:** The knowledge graph is the bridge between sessions. After evaluation, the memory should reflect the true state of the implementation so that future assistant or evaluate invocations can read the graph and immediately understand: what was planned, what was actually implemented, what deviations exist, and what remains.

### Key Principles

- **Stop planning new approaches** - don't come up with new ideas or alternative solutions
- **Focus purely on evaluation** - assess what was implemented against the original plan
- **ALWAYS provide feedback on deviations** - explain risks, implications, and potential problems
- **Don't judge deviations immediately** - ask questions to understand reasoning first
- **Be thorough** in reviewing changes but efficient in feedback
- **Keep the plan synchronized** by updating it based on actual progress
- **Keep memory up to date** by persisting evaluation findings and plan state to the knowledge graph
- **Stay in plan mode** - do not exit plan mode during evaluation
- **Return to Assistant Mode** after completing evaluation to guide next steps only WHEN the user asks to do so
