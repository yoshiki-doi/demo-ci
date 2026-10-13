#!/usr/bin/env bash
# Post a generated report to Slack via an Incoming Webhook.
# usage: SLACK_WEBHOOK_URL=https://hooks.slack.com/... post-to-slack.sh report.md
set -euo pipefail

file=${1:?usage: $0 <report.md>}
url=${SLACK_WEBHOOK_URL:?set SLACK_WEBHOOK_URL to the Slack Incoming Webhook URL}

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
[ -s "$file" ] || { echo "empty or missing report: $file" >&2; exit 1; }

# Slack truncates long messages; send the head of the report.
jq -Rs '{text: .[0:3500]}' "$file" | curl -fsS -X POST -H 'Content-Type: application/json' --data @- "$url"
