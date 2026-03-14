#!/bin/bash
# PreToolUse hook for Agent tool — routing guard + collision check

cat <<'EOF'
<routing-guard>
BEFORE launching this subagent, verify ALL of the following:

1. ROUTING APPROVAL: Did the user explicitly confirm the routing plan?
   - If NO: STOP. Present routing plan table first and wait for confirmation.

2. MODEL ASSIGNMENT: Is the model parameter correct?
   - SIMPLE tasks → model: "haiku"
   - MEDIUM tasks → model: "sonnet"
   - COMPLEX tasks → model: "opus"
   - FRONTEND tasks → use Bash with gemini CLI instead (not Agent tool)

3. COLLISION CHECK: Does this agent's file set overlap with any other parallel agent?
   - If YES: do NOT dispatch in parallel. Run sequentially after the conflicting agent completes.
   - If NO: safe to dispatch in parallel.

4. ISOLATION: Is isolation: "worktree" set for parallel dispatches?
   - All parallel agents MUST use worktree isolation.
   - Solo agents (no parallel peers) may skip worktree.

Opus 4.6 is ALWAYS the leader. Never delegate without user approval.
</routing-guard>
EOF
