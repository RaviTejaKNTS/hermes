# Pi Workspace

Remote OS-like workspace for running Pi Agent on Northflank.

## Browser Workspace

Open:

```text
https://hermes.ravitejaknts.com
```

After login, use the integrated terminal:

```bash
cd /workspace
pi
```

Useful folders:

- `/workspace/articles`
- `/workspace/apps`
- `/workspace/.pi/agent/skills`

## Northflank Exec

```bash
npx -y @northflank/cli exec service --project pi-workspace --service pi-workspace --cmd bash
cd /workspace
pi
```

## Private SSH Forwarding

Start the local tunnel:

```bash
npx -y @northflank/cli forward service --project pi-workspace --service pi-workspace --skipHostnames
```

Then connect from another terminal using the printed local port:

```bash
ssh -p <printed-port> root@127.0.0.1
cd /workspace
pi
```

All durable files live in `/workspace`.
