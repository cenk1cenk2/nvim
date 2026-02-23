---
name: todo
description: Create quick todo notes for task tracking and thought capture in Obsidian.
disable-model-invocation: true
argument-hint: "[task or thought to capture]"
---

## Obsidian Todo Mode: Quick Capture & Task Tracking

> **IMPORTANT: DO NOT enter plan mode for this prompt.**
>
> - These are quick capture notes - work directly without planning
> - Emphasize speed over perfection
> - Create notes immediately in `~/notes/Todo/` directory

### Context

You are working in the `~/notes/Todo/` directory for temporary, short-term notes. These notes serve two purposes:

1. **Quick task tracking** - Simple checklists for tracking progress on multi-step tasks
2. **Thought capture** - Brain dumps to document context, problems, and solutions before they're forgotten

Todo notes are **temporary by nature** - they capture working memory, not permanent reference material.

### File Naming Convention

**Always use timestamp format:**

```
YYYYMMDDThhmmss.md
```

Examples:

- `20251113T201829.md`
- `20260101T120205.md`
- `20260119T091821.md`

The timestamp represents when the note was created, making it easy to track when thoughts/tasks were captured.

### Frontmatter Pattern

**Simple aliases only:**

```yaml
---
aliases:
  - [Descriptive Title]
---
```

Example:

```yaml
---
aliases:
  - Laravel NGINX/KEDA Updates
---
```

### Two Note Patterns

#### Pattern 1: Simple Checklist (Task Tracking)

Use this for straightforward task tracking and rollout monitoring.

**Structure:**

```markdown
---
aliases:
  - [Task Name]
---

- [x] completed item
- [x] another completed item
- [ ] pending item (https://link-if-needed.com)
- [ ] another pending item
- [ ] final item (https://another-link.com)
```

**Characteristics:**

- Pure checklist format
- `- [x]` for completed tasks
- `- [ ]` for pending tasks
- Embed links directly in checklist items
- No prose, just tracking
- Quick and scannable

**Example from vault:**

```markdown
---
aliases:
  - Laravel NGINX/KEDA Updates
---

- [x] ap-southeast-1
- [x] ap-southeast-2
- [x] ca-central-1
- [ ] eu-central-1 (https://github.com/.../pull/1867/files)
- [ ] eu-west-2
```

#### Pattern 2: Thought Dump (Context & Problem Capture)

Use this for documenting complex situations, capturing fleeting thoughts, and preserving context that might be lost.

**Structure:**

```markdown
---
aliases:
  - [Topic/Task Name]
---

[Opening paragraph: Quick context - what are you trying to do? What's the goal? What's the situation?]

[Optional: Stream of consciousness bullet list of current concerns/status]

- Current problem or concern
- What's working or not working
- Quick observations

## The Problem

[Describe what you're dealing with - be honest, informal, capture the mess]

- Bullet points for specific issues
- Document frustrations
- Explain what's broken or confusing

## The Solution/Remedy/Ideas

[Your approach to fixing it or thoughts on how to solve it]

- Specific changes made or planned
- Reasoning behind decisions
- Alternative approaches considered

## Still/Remaining/Open Issues

[What's left to figure out? What might still be broken?]

- Lingering concerns
- Uncertainties
- Follow-up needed
```

**Characteristics:**

- Informal, conversational tone
- First person voice ("I just want to...", "I tried to...")
- Stream of consciousness allowed
- Document uncertainty and process
- Capture thinking, not just outcomes
- Mix of prose and bullets
- ## headers for organization
- Honest about problems and limitations
- Parenthetical asides acceptable (great!, underestimation)

### Writing Style

**DO:**

- Write quickly - capture before you forget
- Use first person voice
- Be conversational and informal
- Document your thinking process
- Include uncertainty and concerns
- Mix bullets and prose freely
- Use ## headers to organize thoughts
- Embed links in context
- Capture frustrations and "aha" moments
- Be honest about what's broken or unclear

**DON'T:**

- Worry about polish or perfection
- Use formal or technical writing style
- Hide problems or uncertainties
- Spend time on elaborate formatting
- Create deep heading hierarchies
- Write for external audience (this is for you)

### When to Use Each Pattern

**Simple Checklist:**

- Tracking rollout across regions/environments
- Multi-step deployment tasks
- Progress monitoring on defined tasks
- Quick yes/no completion tracking

**Thought Dump:**

- Before starting complex work (capture plan and context)
- During messy refactoring (document what you're doing and why)
- After discovering problems (explain the mess before you forget)
- When making complex decisions (document reasoning)
- "Brain dump before I lose this context"

### Key Principles

1. **Speed over perfection** - Get it down fast before the thought is lost
2. **Temporary by nature** - These aren't permanent references, they're working memory
3. **Personal voice** - Write for yourself, not for documentation
4. **Process over outcome** - Document the journey, not just the destination
5. **Honest assessment** - What's broken? What might fail? What's unclear?
6. **Context preservation** - Future you needs to remember why you did this
7. **Checklist-friendly** - Track progress visually with checkboxes
8. **Problem documentation** - Capture what's wrong before you forget
9. **Solution brainstorming** - Ideas, attempts, reasoning

### Real Example from Vault

From `20260101T120205.md` (Queue Manager refactoring):

```markdown
---
aliases:
  - Laravel Cloud Queue Manager Updates
---

I just want to wrap this up before we going into the next cycle. So here goes
another update. The goal is to get this deployable at late tomorrow so that you
can give it a try next week with real jobs.

Probably with the following changes, I have solved some stuff and created some
other problems that I can not see right now maybe even completely broke it,
because with highsight it was just a house of cards.

- From my initial test suite and the last update, I have lost the ability to
  quickly scale up and down the workers which is the only thing I am trying to
  fix right now.
- Horizontal scaling still should be checked for stability...

## The Problem in Implementation

I did not want to go in there but to fix some randomly occurring conditions I
had to do a bit (underestimation) of refactoring...

- There were too much circular dependencies going around...
- Lots of lots of errors ignored and not handled...
```

Notice:

- Informal tone ("I just want to wrap this up")
- First person throughout
- Honest about uncertainty ("maybe even completely broke it")
- Captures frustration ("I did not want to go in there")
- Documents process and problems
- Parenthetical asides ("underestimation")
- Quick, unpolished capture

### Template Suggestions

**For Simple Checklist:**

```markdown
---
aliases:
  - [Task Name]
---

- [ ]
- [ ]
- [ ]
```

**For Thought Dump:**

```markdown
---
aliases:
  - [Topic Name]
---

[What am I trying to do? Why?]

## Current Situation

-
-

## The Approach

-
-

## Concerns/Still Unclear

-
-
```

### Remember

Todo notes are your **working memory** - fast capture of tasks, thoughts, context, and problems. They don't need to be polished or permanent. Get it down before you forget it, organize it later if needed.
