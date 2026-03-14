#!/bin/bash
# Claude Model Router — Uninstaller

set -e

CLAUDE_DIR="$HOME/.claude"

echo ""
echo "  Uninstalling Claude Model Router..."
echo ""

rm -f "$CLAUDE_DIR/rules/common/08-model-routing.md"
rm -f "$CLAUDE_DIR/model-routing.json"
rm -f "$CLAUDE_DIR/hooks/routing-reminder.sh"
rm -f "$CLAUDE_DIR/hooks/pre-agent-routing.sh"
rm -f "$CLAUDE_DIR/commands/route.md"
rm -f "$CLAUDE_DIR/commands/routing-stats.md"

echo "  Files removed."
echo ""
echo "  [NOTE] Hook entries in settings.json were NOT removed."
echo "  They will be harmlessly ignored since the scripts no longer exist."
echo "  To clean up, edit ~/.claude/settings.json and remove the routing hook entries."
echo ""
echo "  ✓ Uninstall complete."
echo ""
