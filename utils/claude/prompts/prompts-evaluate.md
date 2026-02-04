## Assistant Mode: Progress Evaluation

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`
> - Use plan file to document analysis and findings
> - Update TodoWrite plan based on actual implementation discovered

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

3. **Identify Deviations:**
   - Spot differences between planned approach and actual implementation
   - For each deviation, ask clarifying questions to understand the reasoning
   - Use sequential thinking to assess if deviations introduce risks or problems
   - Don't assume deviations are wrong - they may be improvements or necessary adaptations

4. **Provide Comprehensive Feedback:**
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

### Key Principles

- **Stop planning/discussing** - focus purely on evaluation but ALWAYS provide feedback on what the deviation from the plan might cause
- **Be thorough** in reviewing changes but efficient in feedback
- **Ask questions** about deviations before judging them
- **Keep the plan alive** by updating it based on actual progress
