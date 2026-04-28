# Northflank Deployment Notes

This repo is prepared to run Hermes on Northflank as a long-running Slack gateway.

## Recommended setup

- Resource type: service
- Build source: this repo's `Dockerfile`
- Runtime: continuous
- Persistent volume mount: `/opt/data`

The container now defaults to:

```bash
hermes gateway run
```

So no custom start command is required for the first service.

## Required environment variables

```env
GEMINI_API_KEY=
SLACK_APP_TOKEN=
SLACK_BOT_TOKEN=
SLACK_ALLOWED_USERS=
```

## Optional dashboard

If you want a second Northflank service for the dashboard later, override the
start command to:

```bash
dashboard --host 0.0.0.0 --port 9119 --no-open --insecure
```

Only expose that behind authentication. The dashboard can reveal secrets and
session data.
