#!/bin/bash
set -euo pipefail

INSTALL_DIR="/opt/hermes"
source "${INSTALL_DIR}/.venv/bin/activate"

DASHBOARD_HOST="${HERMES_DASHBOARD_HOST:-0.0.0.0}"
DASHBOARD_PORT="${HERMES_DASHBOARD_PORT:-9119}"
CONTROL_DIR="${HERMES_HOME:-/opt/data}/run"
RESTART_FLAG="${CONTROL_DIR}/gateway.restart"
PID_FILE="${CONTROL_DIR}/gateway.pid"

gateway_pid=""
supervisor_pid=""

mkdir -p "${CONTROL_DIR}"
rm -f "${RESTART_FLAG}"
rm -f "${PID_FILE}"

start_gateway() {
    echo "Starting Hermes gateway..."
    hermes gateway run --replace &
    gateway_pid=$!
    printf '%s\n' "${gateway_pid}" > "${PID_FILE}"
}

stop_gateway() {
    if [ -z "${gateway_pid}" ] && [ -f "${PID_FILE}" ]; then
        gateway_pid="$(cat "${PID_FILE}" 2>/dev/null || true)"
    fi
    if [ -n "${gateway_pid}" ] && kill -0 "${gateway_pid}" 2>/dev/null; then
        kill "${gateway_pid}" 2>/dev/null || true
        wait "${gateway_pid}" 2>/dev/null || true
    fi
    gateway_pid=""
    rm -f "${PID_FILE}"
}

cleanup() {
    if [ -n "${supervisor_pid}" ] && kill -0 "${supervisor_pid}" 2>/dev/null; then
        kill "${supervisor_pid}" 2>/dev/null || true
        wait "${supervisor_pid}" 2>/dev/null || true
    fi
    stop_gateway
    rm -f "${RESTART_FLAG}"
    rm -f "${PID_FILE}"
}

trap cleanup EXIT INT TERM

start_gateway

(
    while true; do
        if [ -f "${RESTART_FLAG}" ]; then
            rm -f "${RESTART_FLAG}"
            echo "Restarting Hermes gateway..."
            stop_gateway
            start_gateway
        elif [ -n "${gateway_pid}" ] && ! kill -0 "${gateway_pid}" 2>/dev/null; then
            echo "Hermes gateway exited unexpectedly; restarting..."
            start_gateway
        fi
        sleep 1
    done
) &
supervisor_pid=$!

echo "Starting Hermes dashboard on ${DASHBOARD_HOST}:${DASHBOARD_PORT}..."
export HERMES_DASHBOARD_STACK=1
export HERMES_GATEWAY_RESTART_FLAG="${RESTART_FLAG}"
hermes dashboard \
    --host "${DASHBOARD_HOST}" \
    --port "${DASHBOARD_PORT}" \
    --no-open \
    --insecure \
    --tui
