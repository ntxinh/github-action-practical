# Repository Dispatch

```bash
curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.github.com/repos/ntxinh/github-action-practical/dispatches \
  -d '{"event_type": "run-ci"}'
```

# Workflow Dispatch

```bash
curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.github.com/repos/ntxinh/github-action-practical/actions/workflows/ci.yml/dispatches \
  -d '{"ref": "main"}'
```