FROM node:22-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/workspace
ENV PI_HOME=/workspace/.pi/agent
ENV PATH=/workspace/.local/bin:/usr/local/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash ca-certificates curl git jq less nano openssh-client openssh-server \
      procps ripgrep rsync sudo tmux unzip vim wget && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/yudai/gotty/releases/latest/download/gotty_linux_amd64.tar.gz \
      -o /tmp/gotty.tar.gz && \
    mkdir -p /tmp/gotty && \
    tar -xzf /tmp/gotty.tar.gz -C /tmp/gotty && \
    find /tmp/gotty -type f -name gotty -exec mv {} /usr/local/bin/gotty \; && \
    chmod +x /usr/local/bin/gotty && \
    rm -rf /tmp/gotty /tmp/gotty.tar.gz

RUN npm install -g @earendil-works/pi-coding-agent && \
    npm cache clean --force

WORKDIR /workspace

COPY skills/ /opt/pi-bootstrap/skills/
COPY start.sh /usr/local/bin/pi-workspace-start

RUN chmod +x /usr/local/bin/pi-workspace-start && \
    mkdir -p /run/sshd /workspace

VOLUME ["/workspace"]
EXPOSE 22/tcp
EXPOSE 7681/tcp

CMD ["pi-workspace-start"]
