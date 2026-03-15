<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-8B5CF6?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjIiPjxwYXRoIGQ9Ik0xMiAyTDIgN2wxMCA1IDEwLTV6Ii8+PHBhdGggZD0iTTIgMTdsMTAgNSAxMC01Ii8+PHBhdGggZD0iTTIgMTJsMTAgNSAxMC01Ii8+PC9zdmc+" alt="Claude Code Plugin">
  <img src="https://img.shields.io/badge/Save-60--80%25_Cost-10B981?style=for-the-badge" alt="Save 60-80% Cost">
  <img src="https://img.shields.io/badge/Multi--Model-Haiku_Sonnet_Opus_Gemini-F59E0B?style=for-the-badge" alt="Multi-Model">
</p>

<h1 align="center">
<br>
<code>claude-model-router</code>
<br>
<sub>Stop paying Opus prices for Haiku work.</sub>
</h1>

<p align="center">
An intelligent model routing orchestrator for Claude Code.<br>
Opus leads. Haiku, Sonnet, and Gemini do the grunt work.<br>
<b>You save 60-80% on API costs.</b>
</p>

---

```
User: "Review auth code, add tests, and redesign the login page"

┌─────────────────────────────────────────────────────┐
│  Opus 4.6 (Leader)                                  │
│                                                     │
│  Routing plan:                                      │
│  ┌───┬──────────────────┬────────┬────────────────┐ │
│  │ # │ Subtask          │ Model  │ Reason         │ │
│  ├───┼──────────────────┼────────┼────────────────┤ │
│  │ 1 │ Review auth code │ sonnet │ code review    │ │
│  │ 2 │ Write auth tests │ sonnet │ test writing   │ │
│  │ 3 │ Redesign login   │ gemini │ UI design      │ │
│  └───┴──────────────────┴────────┴────────────────┘ │
│                                                     │
│  Launch subagents for this task?                     │
└─────────────────────────────────────────────────────┘

User: "yes"

  ┌─────────┐  ┌─────────┐  ┌─────────┐
  │ Sonnet  │  │ Sonnet  │  │ Gemini  │
  │ review  │  │ tests   │  │ design  │
  │ $0.02   │  │ $0.02   │  │ ~free   │
  └────┬────┘  └────┬────┘  └────┬────┘
       └────────────┼────────────┘
                    ▼
              Opus aggregates
              Total: ~$0.04
              vs all-Opus: ~$0.32
              Saved: 87%
```

## How It Works

**Opus is always the leader.** It analyzes your request, decomposes it into subtasks, and routes each to the cheapest model that can handle it:

| Tier | Model | Cost | Tasks |
|------|-------|------|-------|
| `SIMPLE` | Haiku 4.5 | $0.002/task | Search, grep, format, boilerplate, docs |
| `MEDIUM` | Sonnet 4.6 | $0.021/task | Code review, refactor, bug fix, tests |
| `COMPLEX` | Opus 4.6 | $0.105/task | Architecture, debug, security, planning |
| `FRONTEND` | Gemini 3.1 Pro | Google billing | UI design, CSS, animations, layouts |

**Anti-collision** prevents parallel agents from conflicting:
- File ownership — each agent gets assigned specific files
- Worktree isolation — each agent works on an isolated repo copy
- Sequential fallback — overlapping tasks run one after another

**Smart dispatching** — clear-cut tasks (search, code review) auto-dispatch instantly. Ambiguous or expensive tasks ask for confirmation first.

## Quick Install

```bash
git clone https://github.com/riftzen-bit/claude-model-router.git
cd claude-model-router
./install.sh
```

Then start a new Claude Code session. The router activates automatically.

## What Gets Installed

```
~/.claude/
├── rules/common/08-model-routing.md    ← Auto-loaded routing brain (every session)
├── model-routing.json                  ← Customizable task→model mapping
├── hooks/
│   ├── routing-reminder.sh             ← Reminds Opus to route (every message)
│   └── pre-agent-routing.sh            ← Guards against unauthorized dispatch
└── commands/
    ├── route.md                        ← /route — full orchestrator
    ├── design.md                       ← /design — Gemini design dispatch
    └── routing-stats.md                ← /routing-stats — cost dashboard
```

## Commands

| Command | What it does |
|---------|-------------|
| `/route` | Invoke the full orchestrator for complex multi-step tasks |
| `/design` | Dispatch frontend/UI tasks to Gemini with project context and anti-slop rules |
| `/routing-stats` | View routing statistics and cost savings for your session |

## Manual Installation

If you prefer to install manually:

**Step 1** — Copy files (from inside the cloned repo):
```bash
cd claude-model-router
cp rules/08-model-routing.md ~/.claude/rules/common/
cp model-routing.json ~/.claude/
cp hooks/routing-reminder.sh ~/.claude/hooks/
cp hooks/pre-agent-routing.sh ~/.claude/hooks/
cp commands/route.md ~/.claude/commands/
cp commands/design.md ~/.claude/commands/
cp commands/routing-stats.md ~/.claude/commands/
chmod +x ~/.claude/hooks/routing-reminder.sh ~/.claude/hooks/pre-agent-routing.sh
```

**Step 2** — Register hooks in `~/.claude/settings.json`:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/routing-reminder.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-agent-routing.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Step 3** — Start a new Claude Code session.

## AI Auto-Setup Prompt

Copy and paste this prompt into Claude Code, Cursor, or any AI assistant to auto-install:

<details>
<summary><b>Click to expand the setup prompt</b></summary>

```
I need you to install the claude-model-router plugin. Follow these steps EXACTLY — do not skip or modify any step:

1. Clone the repo:
   git clone https://github.com/riftzen-bit/claude-model-router.git /tmp/claude-model-router

2. Create required directories (skip if they exist):
   mkdir -p ~/.claude/rules/common ~/.claude/hooks ~/.claude/commands

3. Copy these files (overwrite if they exist):
   cp /tmp/claude-model-router/rules/08-model-routing.md ~/.claude/rules/common/08-model-routing.md
   cp /tmp/claude-model-router/model-routing.json ~/.claude/model-routing.json
   cp /tmp/claude-model-router/hooks/routing-reminder.sh ~/.claude/hooks/routing-reminder.sh
   cp /tmp/claude-model-router/hooks/pre-agent-routing.sh ~/.claude/hooks/pre-agent-routing.sh
   cp /tmp/claude-model-router/commands/route.md ~/.claude/commands/route.md
   cp /tmp/claude-model-router/commands/design.md ~/.claude/commands/design.md
   cp /tmp/claude-model-router/commands/routing-stats.md ~/.claude/commands/routing-stats.md

4. Make hooks executable:
   chmod +x ~/.claude/hooks/routing-reminder.sh ~/.claude/hooks/pre-agent-routing.sh

5. Register hooks in ~/.claude/settings.json:
   - Read the current settings.json
   - Add to hooks.UserPromptSubmit array: {"hooks": [{"type": "command", "command": "~/.claude/hooks/routing-reminder.sh", "timeout": 5}]}
   - Add to hooks.PreToolUse array: {"matcher": "Agent", "hooks": [{"type": "command", "command": "~/.claude/hooks/pre-agent-routing.sh", "timeout": 5}]}
   - Do NOT remove or modify any existing hooks — only ADD these entries
   - Write the updated settings.json back

6. Verify installation:
   - Run: bash ~/.claude/hooks/routing-reminder.sh
   - Run: bash ~/.claude/hooks/pre-agent-routing.sh
   - Run: python3 -c "import json; json.load(open('$HOME/.claude/settings.json'))"
   - All three must succeed with no errors

7. Clean up:
   rm -rf /tmp/claude-model-router

8. Report results:
   - List all installed files with line counts
   - Confirm hooks are registered in settings.json
   - Confirm all verification checks passed

IMPORTANT:
- Do NOT modify any existing settings or hooks — only ADD new ones
- Do NOT edit the plugin files — install them exactly as-is
- If settings.json doesn't exist, create it with only the hooks section
- If any step fails, STOP and report the error — do not continue
```

</details>

## Gemini Design Dispatch (v2.1)

Frontend tasks are automatically detected and routed to Gemini 3.1 Pro with `--sandbox false`:

```
User: "redesign the dashboard with a dark theme"

  [Design] dashboard redesign → gemini (frontend auto-detected)

  ┌──────────────────────────────────┐
  │  Gemini 3.1 Pro (--sandbox off)  │
  │  • Reads project styles/tokens   │
  │  • Generates with anti-slop rules│
  │  • 180s timeout                  │
  └──────────┬───────────────────────┘
             ▼
  ┌──────────────────────────────────┐
  │  Opus validates before applying  │
  │  • Syntax check                  │
  │  • Anti-slop check               │
  │  • Accessibility (WCAG 2.1 AA)   │
  │  • Framework match               │
  └──────────────────────────────────┘
```

**Auto-detected keywords:** design, redesign, style, UI, layout, CSS, Tailwind, animation, theme, color, typography, font, landing page, responsive

**Anti-slop rules enforced:** No Inter/Roboto fonts, no purple gradients, no generic layouts, no AI-looking patterns. Distinctive, characterful design only.

**Fallback:** If Gemini CLI is not installed, frontend tasks automatically fallback to Opus.

## Gemini Integration (Optional)

To enable Gemini for frontend/UI design tasks:

1. Install [Gemini CLI](https://github.com/google-gemini/gemini-cli):
   ```bash
   npm install -g @google/gemini-cli
   ```

2. Authenticate:
   ```bash
   gemini  # Follow the OAuth flow on first run
   ```

3. Test:
   ```bash
   gemini -m gemini-3.1-pro-preview --sandbox false -p "say OK"
   ```

If Gemini is not installed, frontend tasks automatically fallback to Opus.

## Customization

Edit `~/.claude/model-routing.json` to customize routing:

```json
{
  "routing_rules": [
    {
      "task_pattern": "your_custom_pattern",
      "description": "What this pattern matches",
      "model": "haiku",
      "examples": ["example prompt 1", "example prompt 2"]
    }
  ]
}
```

Available models: `haiku`, `sonnet`, `opus`, `gemini`

## Enforcement Layers

The router enforces at 4 levels — you can't accidentally skip it:

| Layer | When | Guarantee |
|-------|------|-----------|
| Rule file | Session start | Loaded into context |
| UserPromptSubmit hook | Every message | Injected before response |
| PreToolUse hook | Every Agent call | Checked before dispatch |
| `/route` command | On demand | Full orchestrator |

## Cost Comparison

| Scenario | All-Opus | With Router | Savings |
|----------|----------|-------------|---------|
| 10 file searches | $1.05 | $0.02 | 98% |
| 5 code reviews | $0.53 | $0.11 | 79% |
| Mixed session (20 tasks) | $2.10 | $0.42 | 80% |

## Uninstall

```bash
cd claude-model-router
./uninstall.sh
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Claude Code session running with Opus model (recommended as leader)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) (optional, for frontend routing)

## License

MIT
