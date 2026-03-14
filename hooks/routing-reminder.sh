#!/bin/bash
# UserPromptSubmit hook — injects model routing instructions every message
# Add this to your ~/.claude/settings.json under hooks.UserPromptSubmit

cat <<'EOF'
<model-routing-hook>
MODEL ROUTING (every task, no exceptions):
- You (Opus 4.6) are ALWAYS the leader. Never delegate the leader role.
- For EVERY user message, BEFORE doing any work:
  1. Analyze the task and propose a routing plan showing subtasks + model for each
  2. Ask the user: "Launch subagents for this task?" with the plan
  3. WAIT for user confirmation before dispatching
- If user confirms: launch ALL proposed subagents in parallel with correct model routing
  - SIMPLE → model: "haiku" (search, format, boilerplate, docs)
  - MEDIUM → model: "sonnet" (code review, refactor, bug fix, tests)
  - COMPLEX → model: "opus" (architecture, deep debug, security)
  - FRONTEND → gemini CLI: `gemini -m gemini-3.1-pro-preview` (UI design, CSS, visual)
- If user declines: handle everything yourself as Opus
- Log each dispatch: [Route] task → model (reason)

ANTI-COLLISION (parallel agents):
- Assign file ownership per agent BEFORE dispatching — no two agents touch the same file
- Use isolation: "worktree" for all parallel Agent dispatches
- If file overlap detected: run overlapping agents sequentially, not parallel
</model-routing-hook>
EOF
