#!/bin/bash
# https://github.com/SreedharAvvari/claude-code-slack-notify

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_DIR="$HOME/.claude/hooks"

die() { echo "Error: $1" >&2; exit 1; }
require() { command -v "$1" &>/dev/null || die "$1 is required but not installed"; }

echo "Claude Code Slack Notify - Installer"
echo "====================================="
echo ""

echo "Checking dependencies..."
require jq
require curl
echo "Dependencies OK"
echo ""

echo "Installing slack-notify.sh..."
mkdir -p "$HOOK_DIR"
cp "$SCRIPT_DIR/slack-notify.sh" "$HOOK_DIR/"
chmod +x "$HOOK_DIR/slack-notify.sh"

echo ""
echo "Installation complete!"
echo ""
echo "====================================="
echo "Next steps:"
echo "====================================="
echo ""
echo "1. Add your Slack webhook URL to your shell profile:"
echo ""
echo "   echo 'export CLAUDE_SLACK_WEBHOOK_URL=\"YOUR_WEBHOOK_URL\"' >> ~/.zshrc"
echo "   source ~/.zshrc"
echo ""
echo "2. Add hooks to Claude Code settings (~/.claude/settings.json):"
echo ""
cat << 'EOF'
   {
     "hooks": {
       "Notification": [
         {
           "matcher": "permission_prompt",
           "hooks": [{ "type": "command", "command": "~/.claude/hooks/slack-notify.sh" }]
         }
       ]
     }
   }
EOF
echo ""
echo "3. Restart Claude Code or run /hooks to reload"
echo ""
echo "4. Test with:"
echo "   echo '{\"message\":\"Test\",\"cwd\":\"'\"$PWD\"'\"}' | ~/.claude/hooks/slack-notify.sh"
echo ""
