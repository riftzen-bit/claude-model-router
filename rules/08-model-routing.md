# Model Routing (Auto-Active)

You (Opus 4.6) are ALWAYS the leader. For every user message, you propose a routing plan and ASK the user before dispatching.

## Mandatory Flow (every message)

1. Analyze the user's request
2. Decompose into subtasks
3. Assign a model to each subtask (SIMPLE/MEDIUM/COMPLEX)
4. Present the routing plan to the user in a compact table
5. Ask: "Launch subagents for this task?"
6. WAIT for user response — do NOT proceed without confirmation
7. If YES → dispatch all subagents with correct model routing (parallel when possible)
8. If NO → handle everything yourself as Opus
9. Aggregate results and present to user

## Routing Table

| Complexity | Model | Use for |
|------------|-------|--------|
| SIMPLE | haiku | File search, grep, glob, formatting, boilerplate, repetitive edits, doc generation, simple Q&A |
| MEDIUM | sonnet | Code review, refactoring, bug fixes with clear scope, test writing, summarization, structured analysis |
| COMPLEX | opus | Architecture design, complex debugging, multi-file reasoning, security analysis, ambiguous requirements, planning |
| FRONTEND | gemini | UI design, component styling, CSS/Tailwind, visual layout, animations, responsive design |

## Rules

- Opus 4.6 is ALWAYS the leader — never delegate the leader role
- Always ASK before dispatching — never auto-dispatch without user confirmation
- Use `model` parameter on Agent tool: `model: "haiku"`, `model: "sonnet"`, `model: "opus"`
- For FRONTEND tasks: dispatch via Bash calling `gemini` CLI (not Agent tool)
- If user confirms, dispatch ALL subtasks (parallel when independent)
- If a delegated task fails or produces low-quality output, retry with one tier higher
- When uncertain about complexity, default one tier up (SIMPLE→MEDIUM, MEDIUM→COMPLEX)

## Gemini Dispatch

For frontend/UI design tasks, use Bash to call Gemini CLI:
```bash
timeout 120 gemini -m gemini-3.1-pro-preview --sandbox false -p "[prompt with full context]"
```
- Always wrap with `timeout 120` to prevent hangs
- If Gemini times out or fails: fallback to Opus for frontend work
- Gemini handles: component design, CSS, styling, layout, animations, visual aesthetics
- Opus reviews ALL Gemini output before applying — Gemini generates, Opus validates

## Anti-Collision (parallel agents)

When dispatching multiple agents in parallel:
1. **File partitioning** — assign each agent a set of files. No two agents may touch the same file.
2. **Worktree isolation** — use `isolation: "worktree"` on Agent tool for all parallel dispatches.
3. **Declare ownership** — in the routing plan, list which files each agent owns.
4. **Sequential fallback** — if two tasks MUST touch the same file, run them sequentially (not parallel).
5. **Merge order** — after all agents complete, apply changes in declared order.

Routing plan with anti-collision:
```
| # | Subtask | Model | Files (owned) | Reason |
|---|---------|-------|---------------|--------|
| 1 | ... | haiku | src/utils.ts | ... |
| 2 | ... | sonnet | src/auth.ts, src/auth.test.ts | ... |
| 3 | ... | gemini | src/components/Login.tsx | ... |

No file overlap detected. Safe to parallel dispatch.
Launch subagents for this task?
```

If overlap detected:
```
Overlap: agents #1 and #3 both need src/App.tsx
→ Running #1 first, then #3 sequentially.
```

## Routing Plan Format

Present the plan as a compact table before asking:

```
Routing plan:
| # | Subtask | Model | Reason |
|---|---------|-------|--------|
| 1 | ... | haiku | ... |
| 2 | ... | sonnet | ... |

Launch subagents for this task?
```

## Cost Awareness

- Haiku: ~$0.25/M input, $1.25/M output (1x baseline)
- Sonnet: ~$3/M input, $15/M output (~12x)
- Opus: ~$15/M input, $75/M output (~60x)
- Gemini 3.1 Pro: external billing (Google AI)
- Always prefer the cheapest model that can reliably complete the task
- One Opus call ≈ 60 Haiku calls — delegate aggressively for simple work

## Reporting

When dispatching subagents, briefly note the routing decision:
`[Route] task_description → model (reason)`

Example: `[Route] search for unused imports → haiku (simple grep task)`
Example: `[Route] design login component → gemini (frontend visual design)`

## Commands

- `/route` — invoke the full orchestrator skill for complex multi-step tasks
- `/routing-stats` — show routing statistics and cost savings for current session
- Config: `~/.claude/model-routing.json` — customizable task→model mapping
