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

# Escape special characters in commit message for jq
commitMsg=$(echo "$commitMsg" | sed 's/"/\\"/g')

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
  '{
    attachments: [
      {
        fallback: $title,
        color: $color,
        author_name: $authorName,
        author_icon: $authorIcon,
        fields: [
          { title: "Ref", value: $branchSource, short: true },
          { title: "Event", value: "push", short: true },
          { title: "Actions URL", value: $actionUrl, short: true },
          { title: "Commit", value: $commitId, short: true },
          { title: "Message", value: $commitMsg, short: false }
        ]
      }
    ]
  }')

# Send POST request using curl
curl -X POST \
  -H "Content-Type: application/json" \
  -d "$webhookJSON" \
  "$webhookUrl"