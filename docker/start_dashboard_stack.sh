#!/bin/bash
set -euo pipefail

INSTALL_DIR="/opt/hermes"
source "${INSTALL_DIR}/.venv/bin/activate"

DASHBOARD_HOST="${HERMES_DASHBOARD_HOST:-0.0.0.0}"
DASHBOARD_PORT="${HERMES_DASHBOARD_PORT:-9119}"

gateway_pid=""

cleanup() {
    if [ -n "${gateway_pid}" ] && kill -0 "${gateway_pid}" 2>/dev/null; then
        kill "${gateway_pid}" 2>/dev/null || true
        wait "${gateway_pid}" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

echo "Starting Hermes gateway..."
hermes gateway run --replace &
gateway_pid=$!

echo "Starting Hermes dashboard on ${DASHBOARD_HOST}:${DASHBOARD_PORT}..."
hermes dashboard \
    --host "${DASHBOARD_HOST}" \
    --port "${DASHBOARD_PORT}" \
    --no-open \
    --insecure \
    --tui
