#!/bin/bash
# Claude Model Router — Installer
# Installs the model routing plugin for Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
RULES_DIR="$CLAUDE_DIR/rules/common"
HOOKS_DIR="$CLAUDE_DIR/hooks"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║   Claude Model Router — Installer     ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""

# Check prerequisites
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "  [ERROR] ~/.claude directory not found."
  echo "  Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
  exit 1
fi

# Create directories
mkdir -p "$RULES_DIR" "$HOOKS_DIR" "$COMMANDS_DIR"

# Copy files
echo "  [1/6] Installing routing rule..."
cp "$SCRIPT_DIR/rules/08-model-routing.md" "$RULES_DIR/08-model-routing.md"

echo "  [2/6] Installing model config..."
cp "$SCRIPT_DIR/model-routing.json" "$CLAUDE_DIR/model-routing.json"

echo "  [3/6] Installing hooks..."
cp "$SCRIPT_DIR/hooks/routing-reminder.sh" "$HOOKS_DIR/routing-reminder.sh"
cp "$SCRIPT_DIR/hooks/pre-agent-routing.sh" "$HOOKS_DIR/pre-agent-routing.sh"
chmod +x "$HOOKS_DIR/routing-reminder.sh" "$HOOKS_DIR/pre-agent-routing.sh"

echo "  [4/6] Installing commands..."
cp "$SCRIPT_DIR/commands/route.md" "$COMMANDS_DIR/route.md"
cp "$SCRIPT_DIR/commands/routing-stats.md" "$COMMANDS_DIR/routing-stats.md"
cp "$SCRIPT_DIR/commands/design.md" "$COMMANDS_DIR/design.md"

echo "  [5/6] Checking Gemini CLI..."
if command -v gemini &>/dev/null; then
  echo "  Gemini CLI found — frontend design routing enabled"
else
  echo "  Gemini CLI not found — frontend tasks will fallback to Opus"
  echo "  Install later: npm install -g @google/gemini-cli"
fi

echo "  [6/6] Registering hooks in settings.json..."

# Register hooks using python (safe JSON manipulation)
if command -v python3 &>/dev/null; then
  python3 << 'PYEOF'
import json, sys, os

settings_path = os.path.expanduser("~/.claude/settings.json")
hooks_dir = os.path.expanduser("~/.claude/hooks")

# Load or create settings
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

if "hooks" not in settings:
    settings["hooks"] = {}

# Add UserPromptSubmit hook (routing reminder)
reminder_hook = {
    "hooks": [{
        "type": "command",
        "command": f"{hooks_dir}/routing-reminder.sh",
        "timeout": 5
    }]
}

if "UserPromptSubmit" not in settings["hooks"]:
    settings["hooks"]["UserPromptSubmit"] = []

# Check if already registered
existing_cmds = [h.get("command", "") for entry in settings["hooks"]["UserPromptSubmit"] for h in entry.get("hooks", [])]
if not any("routing-reminder.sh" in cmd for cmd in existing_cmds):
    settings["hooks"]["UserPromptSubmit"].append(reminder_hook)

# Add PreToolUse hook (agent guard)
agent_hook = {
    "matcher": "Agent",
    "hooks": [{
        "type": "command",
        "command": f"{hooks_dir}/pre-agent-routing.sh",
        "timeout": 5
    }]
}

if "PreToolUse" not in settings["hooks"]:
    settings["hooks"]["PreToolUse"] = []

existing_cmds = [h.get("command", "") for entry in settings["hooks"]["PreToolUse"] for h in entry.get("hooks", [])]
if not any("pre-agent-routing.sh" in cmd for cmd in existing_cmds):
    settings["hooks"]["PreToolUse"].append(agent_hook)

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("  Hooks registered successfully.")
PYEOF
else
  echo "  [WARN] python3 not found. Please manually add hooks to settings.json."
  echo "  See README.md for manual hook registration."
fi

echo ""
echo "  ✓ Installation complete!"
echo ""
echo "  Files installed:"
echo "    $RULES_DIR/08-model-routing.md"
echo "    $CLAUDE_DIR/model-routing.json"
echo "    $HOOKS_DIR/routing-reminder.sh"
echo "    $HOOKS_DIR/pre-agent-routing.sh"
echo "    $COMMANDS_DIR/route.md"
echo "    $COMMANDS_DIR/design.md"
echo "    $COMMANDS_DIR/routing-stats.md"
echo ""
echo "  Commands available:"
echo "    /route          — orchestrate multi-model task routing"
echo "    /design         — dispatch frontend/UI tasks to Gemini"
echo "    /routing-stats  — view cost savings dashboard"
echo ""
echo "  Start a new Claude Code session to activate."
echo ""
