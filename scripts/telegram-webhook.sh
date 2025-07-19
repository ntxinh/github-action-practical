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

# Escape special characters in commit message for jq
# authorName=$(echo "$authorName" | sed 's/"/\\"/g')
# actionUrl=$(echo "$actionUrl" | sed 's/"/\\"/g')
# branchSource=$(echo "$branchSource" | sed 's/"/\\"/g')
# commitMsg=$(echo "$commitMsg" | sed 's/"/\\"/g')
# commitId=$(echo "$commitId" | sed 's/"/\\"/g')

# Escape special characters in commit message for MarkdownV2
# Telegram MarkdownV2 requires escaping: _ * [ ] ( ) ~ ` # + - = | { } . !
commitMsg=$(echo "$commitMsg" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')

# Also escape double quotes for JSON safety
commitMsg=$(echo "$commitMsg" | sed 's/"/\\"/g')

# Escape branchSource and commitId for MarkdownV2 safety
branchSource=$(echo "$branchSource" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')
commitId=$(echo "$commitId" | sed 's/[_*[\]()~`#+-=|{.}!]/\\&/g')

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

# Send POST request using curl
curl --fail -X POST \
  -H "Content-Type: application/json" \
  -d "$webhookJSON" \
  "$webhookUrl" || {
  echo "Error: curl failed to send request to $webhookUrl"
  exit 1
}