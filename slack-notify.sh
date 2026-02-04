#!/bin/bash
# https://github.com/SreedharAvvari/claude-code-slack-notify

set -euo pipefail

die() { echo "Error: $1" >&2; exit 1; }
require() { command -v "$1" &>/dev/null || die "$1 is required but not installed"; }

SLACK_WEBHOOK_URL="${CLAUDE_SLACK_WEBHOOK_URL:-}"
[[ -n "$SLACK_WEBHOOK_URL" ]] || die "CLAUDE_SLACK_WEBHOOK_URL environment variable is not set"

require jq
require curl

INPUT=$(cat)
echo "$INPUT" | jq empty 2>/dev/null || die "Invalid JSON input"

MESSAGE=$(echo "$INPUT" | jq -r '.message // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // ""')

PROJECT=$(basename "$CWD")
TIMESTAMP=$(date +"%b %d, %I:%M %p")
GIT_BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
FULL_NAME=$(id -F 2>/dev/null || git config user.name 2>/dev/null || whoami)
FIRST_NAME=$(echo "$FULL_NAME" | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')

TOOL_NAME=""
if [[ -n "$MESSAGE" ]]; then
  TOOL_NAME=$(echo "$MESSAGE" | sed -n 's/.*use \([A-Za-z_]*\).*/\1/p')
fi

PERMISSION_NUDGES=(
  "Head over and approve to keep things rolling :rocket:"
  "Claude's waiting on your green light :traffic_light:"
  "Drop what you're doing, your AI needs you :robot_face:"
  "Approve it before Claude gets impatient :fire:"
  "Your AI assistant requires your blessing :pray:"
  "Claude promised to behave, just hit approve :innocent:"
)

pick_random() {
  local arr=("$@")
  echo "${arr[$((RANDOM % ${#arr[@]}))]}"
}

[[ "$NOTIFICATION_TYPE" == "permission_prompt" ]] || exit 0

COLOR="#FF6B35"
HEADER=":shield:  Permission Check"
NUDGE=$(pick_random "${PERMISSION_NUDGES[@]}")
BODY="$(printf "Hey *%s*! :wave: Claude wants to use \`%s\`\n%s" "$FIRST_NAME" "${TOOL_NAME:-a tool}" "$NUDGE")"

PAYLOAD=$(jq -n \
  --arg header "$HEADER" \
  --arg body "$BODY" \
  --arg project "$PROJECT" \
  --arg branch "$GIT_BRANCH" \
  --arg timestamp "$TIMESTAMP" \
  --arg color "$COLOR" \
  '{
    attachments: [
      {
        color: $color,
        fallback: $header,
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*\($header)*"
            }
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: $body
            }
          },
          {
            type: "divider"
          },
          {
            type: "context",
            elements: [
              {
                type: "mrkdwn",
                text: ":file_folder: `\($project)`"
              },
              {
                type: "mrkdwn",
                text: ":seedling: `\($branch)`"
              },
              {
                type: "mrkdwn",
                text: ":clock1: \($timestamp)"
              }
            ]
          }
        ]
      }
    ]
  }'
)

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  -H 'Content-type: application/json' \
  --data "$PAYLOAD" \
  "$SLACK_WEBHOOK_URL")

[[ "$HTTP_STATUS" == "200" ]] || die "Slack webhook returned HTTP $HTTP_STATUS"
