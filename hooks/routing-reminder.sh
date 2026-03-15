#!/bin/bash

cat <<'EOF'
<user-prompt-submit-hook>
Start EVERY reply with: [HOOK_ON]

ROUTING (highest priority — do this FIRST):
Classify this user message before responding:

A) WORK (code changes, multi-file task, review, debug, build, refactor, new feature):
   → Show routing table BEFORE any code or tool calls
   → Auto-dispatch clear-cut tasks, ask only if ambiguous or expensive (Opus subagent)
   → Log every dispatch: [Route] task → model (reason)

B) CHAT (question, confirm, greeting, single quick answer):
   → Answer directly. No routing needed.

If in doubt between A and B → treat as A.

Handle end-to-end, never skip quality gates.
Before claiming done: run verification and show actual output.
</user-prompt-submit-hook>
EOF
