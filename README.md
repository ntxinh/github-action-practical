# Repository Dispatch

```bash
curl -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer YOUR_TOKEN" \
    --request POST \
    --data '{"event_type": "run-ci"}' \
    https://api.github.com/repos/ntxinh/github-action-practical/dispatches
```