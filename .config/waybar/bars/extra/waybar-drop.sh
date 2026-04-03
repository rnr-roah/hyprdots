#!/usr/bin/env bash
# toggle-waybar-drop.sh
# Toggle a Waybar instance launched with the given config & style.
# Uses a PID file and verifies the process cmdline before killing.

CONFIG="/home/roah/.config/waybar/extra/config"
STYLE="/home/roah/.config/waybar/extra/style.css"
CMD=(waybar -c "$CONFIG" -s "$STYLE")
PIDFILE="/tmp/waybar-drop.pid"

# Helper: check if PID corresponds to our exact command line
is_our_waybar() {
    local pid=$1
    [ -d "/proc/$pid" ] || return 1
    # read the process cmdline (null-separated)
    local cmdline
    cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null) || return 1
    # ensure it contains both config and style paths
    [[ "$cmdline" == *"$CONFIG"* && "$cmdline" == *"$STYLE"* ]]
}

# If pidfile exists and process alive -> kill it
if [ -f "$PIDFILE" ]; then
    pid=$(<"$PIDFILE")
    if is_our_waybar "$pid"; then
        echo "Stopping waybar (pid $pid)..."
        kill "$pid" && sleep 0.2
        # if still alive, escalate
        if [ -d "/proc/$pid" ]; then
            echo "Process didn't exit, sending SIGKILL..."
            kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$PIDFILE"
        echo "Stopped."
        exit 0
    else
        echo "PID file exists but does not match expected Waybar instance. Removing stale pidfile."
        rm -f "$PIDFILE"
        # fall through to start
    fi
fi

# Start waybar detached and save PID
echo "Starting waybar..."
# Use setsid to detach from the terminal and allow it to keep running.
# Redirect output to /dev/null; adjust if you want logs.
setsid "${CMD[@]}" >/dev/null 2>&1 &
newpid=$!
# give it a moment to start
sleep 0.15

# verify started and commandline matches
if is_our_waybar "$newpid"; then
    echo "$newpid" > "$PIDFILE"
    echo "Started waybar (pid $newpid)."
    exit 0
else
    echo "Failed to start waybar correctly. Process $newpid exists but doesn't match expected command."
    # cleanup if process is not our waybar
    if [ -d "/proc/$newpid" ]; then kill "$newpid" 2>/dev/null || true; fi
    exit 1
fi

