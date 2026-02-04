# Claude Code Slack Notify

Get Slack notifications when [Claude Code](https://claude.ai/code) needs your attention.

Stop checking your terminal every few minutes. Get notified instantly when Claude Code needs permission to run a command.

## Features

- Rich Slack messages with project context
- Visual indicators for notification types
- Secure configuration via environment variables
- Error handling and input validation
- Easy installation

## Prerequisites

- [Claude Code](https://claude.ai/code) installed
- A Slack workspace with permission to create webhooks
- `jq` and `curl` installed

## Installation

### Quick Install

```bash
# Clone the repo
git clone https://github.com/SreedharAvvari/claude-code-slack-notify.git
cd claude-code-slack-notify

# Run the installer
./install.sh
```

### Manual Install

1. Copy the script:
```bash
mkdir -p ~/.claude/hooks
cp slack-notify.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/slack-notify.sh
```

2. Set up your webhook URL (see [Configuration](#configuration))

3. Add hooks to your Claude Code settings (see [Claude Code Settings](#claude-code-settings))

## Configuration

### 1. Create a Slack Webhook

1. Go to [Slack API Apps](https://api.slack.com/apps)
2. Click **Create New App** > **From scratch**
3. Name it (e.g., "Claude Code Notifier") and select your workspace
4. Go to **Incoming Webhooks** > Toggle **Activate** to On
5. Click **Add New Webhook to Workspace**
6. Select a channel and click **Allow**
7. Copy the webhook URL

### 2. Set Environment Variable

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export CLAUDE_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `CLAUDE_SLACK_WEBHOOK_URL` | Yes | - | Your Slack webhook URL |

## Claude Code Settings

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/slack-notify.sh"
          }
        ]
      },
    ]
  }
}
```

After editing, restart Claude Code or run `/hooks` to reload.

## Testing

Test the webhook directly:

```bash
echo '{"message":"Claude wants to use Bash","cwd":"'"$PWD"'","notification_type":"permission_prompt"}' | ~/.claude/hooks/slack-notify.sh
```

You should see a message in your Slack channel.

## Example Notifications

**Permission Required:**
> :shield: **Permission Check**
>
> Hey **Sreedhar**! Claude wants to use `Bash`
>
> :file_folder: `my-project` · :seedling: `main` · :clock1: Feb 04, 10:30 AM

## Troubleshooting

### "CLAUDE_SLACK_WEBHOOK_URL is not set"
Make sure you've exported the environment variable and restarted your terminal.

### "jq is required but not installed"
Install jq:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt install jq`
- Fedora: `sudo dnf install jq`

### Notifications not appearing
1. Check that your webhook URL is correct
2. Test the script manually (see [Testing](#testing))
3. Verify hooks are loaded: run `/hooks` in Claude Code
4. Check that the Slack channel exists and the webhook has access

## Security

- Never commit your webhook URL to version control
- The webhook URL is stored as an environment variable, not in the script
- Webhook URLs are write-only (cannot read Slack data)

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! Please open an issue or PR.

---

*P.S. This entire repo was coded by Claude Code. Yes, an AI built its own notification system because it got tired of being ignored. The irony is not lost on us.*
