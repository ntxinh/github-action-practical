#!/bin/bash

# Input parameters
branchSource="$1"
commitId="$2"
commitMsg="$3"
webhookUrl="$4"
title="$5"
color="$6"
authorName="$7"
authorIcon="$8"
actionUrl="$9"
chatId="$10"

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
commitMsg=$(echo "$commitMsg" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')
branchSource=$(echo "$branchSource" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')
commitId=$(echo "$commitId" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')
authorName=$(echo "$authorName" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')
actionUrl=$(echo "$actionUrl" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')

# Also escape double quotes for JSON safety
commitMsg=$(echo "$commitMsg" | sed 's/"/\\"/g')
branchSource=$(echo "$branchSource" | sed 's/"/\\"/g')
commitId=$(echo "$commitId" | sed 's/"/\\"/g')
authorName=$(echo "$authorName" | sed 's/"/\\"/g')
actionUrl=$(echo "$actionUrl" | sed 's/"/\\"/g')

# Create JSON payload using jq
webhookJSON=$(jq -n \
  --arg title "$title" \
  --arg color "$color" \
  --arg authorName "$authorName" \
  --arg authorIcon "$authorIcon" \
  --arg branchSource "$branchSource" \
  --arg commitId "$commitId" \
  --arg commitMsg "$commitMsg" \
  --arg actionUrl "$actionUrl" \
  --arg chatId "$chatId" \
  '{
    chat_id: $chatId,
    text: "Author: \($authorName), Actions URL: \($actionUrl), Ref: \($branchSource), Msg: \($commitMsg), Commit: \($commitId)",
    parse_mode: "MarkdownV2"
  }')

echo "Sending request to $webhookUrl $chatId"

# Send POST request using curl
curl -X POST \
  -H "Content-Type: application/json" \
  -d "$webhookJSON"