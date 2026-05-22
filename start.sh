#!/usr/bin/env bash
set -euo pipefail

mkdir -p /workspace/.pi/agent/skills /workspace/articles /workspace/apps /workspace/bin

if [ -n "${SSH_PUBLIC_KEY:-}" ]; then
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
  printf '%s\n' "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
fi

if [ ! -f /workspace/AGENTS.md ]; then
  cat > /workspace/AGENTS.md <<'EOF'
# Pi Workspace Instructions

- Keep all durable work inside `/workspace`.
- Use `/workspace/articles` for article drafts, outlines, briefs, and exports.
- Use `/workspace/apps` for small helper apps or experiments.
- Ask before destructive operations outside `/workspace`.
- Prefer concise, practical outputs with clear next actions.
EOF
fi

if [ ! -f /workspace/.pi/agent/settings.json ]; then
  cat > /workspace/.pi/agent/settings.json <<'EOF'
{
  "enableSkillCommands": true
}
EOF
fi

rsync -a --ignore-existing /opt/pi-bootstrap/skills/ /workspace/.pi/agent/skills/

cat > /workspace/README.md <<'EOF'
# Remote Pi Workspace

This is the persistent workspace for Pi Agent.

Useful commands:

```bash
cd /workspace
pi
pi -p "Create an SEO outline for an article about ..."
pi -p "/skill:article-writing Draft a 1200 word article about ..."
```

Persistent folders:

- `/workspace/articles`
- `/workspace/apps`
- `/workspace/.pi/agent`
EOF

/usr/sbin/sshd

if [ -n "${WEB_TERMINAL_AUTH:-}" ]; then
  gotty \
    --address 0.0.0.0 \
    --port "${WEB_TERMINAL_PORT:-7681}" \
    --credential "$WEB_TERMINAL_AUTH" \
    --permit-write \
    bash -lc 'cd /workspace && exec bash -l' &
else
  echo "WEB_TERMINAL_AUTH is not set; browser terminal is disabled."
fi

echo "Pi workspace ready."
echo "Workdir: /workspace"
echo "Try: pi --version"

tail -f /dev/null
