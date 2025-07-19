#!/bin/bash

# Input parameters
branchSource="$1"
commitId="$2"
commitMsg="$3"
webhookUrl="$4"
title="$5"
# color="$6"
chatId="$6"
authorName="$7"
authorIcon="$8"
actionUrl="$9"

# Validate inputs
if [ -z "$webhookUrl" ]; then
  echo "Error: webhookUrl is empty or not provided"
  exit 1
fi
if [ -z "$chatId" ]; then
  echo "Error: chatId is empty or not provided"
  exit 1
fi
if [[ ! "$webhookUrl" =~ ^https?:// ]]; then
  echo "Error: webhookUrl is malformed, must start with http:// or https://"
  exit 1
fi

# Escape special characters for MarkdownV2
# Telegram MarkdownV2 requires escaping: _ * [ ] ( ) ~ ` # + - = | { } . !
escape_markdownv2() {
  echo "$1" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g'
}

# Apply MarkdownV2 escaping
commitMsg_escaped=$(escape_markdownv2 "$commitMsg")
branchSource_escaped=$(escape_markdownv2 "$branchSource")
commitId_escaped=$(escape_markdownv2 "$commitId")
authorName_escaped=$(escape_markdownv2 "$authorName")
actionUrl_escaped=$(escape_markdownv2 "$actionUrl")

# Debug: Print escaped inputs before JSON escaping
echo "Debug: Escaped commitMsg: $commitMsg_escaped"
echo "Debug: Escaped branchSource: $branchSource_escaped"
echo "Debug: Escaped commitId: $commitId_escaped"
echo "Debug: Escaped authorName: $authorName_escaped"
echo "Debug: Escaped actionUrl: $actionUrl_escaped"

# Escape double quotes for JSON safety
commitMsg_escaped=$(echo "$commitMsg_escaped" | sed 's/"/\\"/g')
branchSource_escaped=$(echo "$branchSource_escaped" | sed 's/"/\\"/g')
commitId_escaped=$(echo "$commitId_escaped" | sed 's/"/\\"/g')
authorName_escaped=$(echo "$authorName_escaped" | sed 's/"/\\"/g')
actionUrl_escaped=$(echo "$actionUrl_escaped" | sed 's/"/\\"/g')

# Debug: Print final inputs after JSON escaping
echo "Debug: Final commitMsg: $commitMsg_escaped"
echo "Debug: Final branchSource: $branchSource_escaped"
echo "Debug: Final commitId: $commitId_escaped"
echo "Debug: Final authorName: $authorName_escaped"
echo "Debug: Final actionUrl: $actionUrl_escaped"

# Create JSON payload using jq
webhookJSON=$(jq -n \
  --arg title "$title" \
  --arg chatId "$chatId" \
  --arg authorName "$authorName" \
  --arg authorIcon "$authorIcon" \
  --arg branchSource "$branchSource" \
  --arg commitId "$commitId" \
  --arg commitMsg "$commitMsg" \
  --arg actionUrl "$actionUrl" \
  '{
    chat_id: $chatId,
    text: "Author: \($authorName), Actions URL: \($actionUrl), Ref: \($branchSource), Msg: \($commitMsg), Commit: \($commitId)",
    parse_mode: "MarkdownV2"
  }')

echo "Sending request to $webhookUrl $chatId"

# Debug: Print JSON payload (avoid exposing sensitive data in production)
echo "Debug: JSON payload: $webhookJSON"

# Send POST request using curl
curl -X POST \
  -H "Content-Type: application/json" \
  -d "$webhookJSON" \
  "$webhookUrl"