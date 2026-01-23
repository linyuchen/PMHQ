#!/bin/sh
# If any command fails, the script will exit immediately
set -e
echo "$(date): Startup script initiated."

# Write environment variables to config file (only if set)

CONFIG_FILE="/opt/pmhq_config.json"
if [ -n "$ENABLE_HEADLESS" ]; then
    sed -i "s/\"headless\":\s*false/\"headless\": ${ENABLE_HEADLESS}/g" "$CONFIG_FILE"
    echo "$(date): Set headless to ${ENABLE_HEADLESS}"
fi
if [ -n "$AUTO_LOGIN_QQ" ]; then
    sed -i "s/\"quick_login_qq\":\s*\"\"/\"quick_login_qq\": \"${AUTO_LOGIN_QQ}\"/g" "$CONFIG_FILE"
    echo "$(date): Set quick_login_qq to ${AUTO_LOGIN_QQ}"
fi

# Set DISPLAY globally for the script
export DISPLAY=:99
echo "$(date): Global DISPLAY set to $DISPLAY"

# Extract the display number (e.g., "99" from ":99" or "1" from ":1.0")
# This is used to construct the lock file path
DISPLAY_NUM=$(echo "$DISPLAY" | cut -d':' -f2 | cut -d'.' -f1)

# Set LIBGL_ALWAYS_SOFTWARE globally
export LIBGL_ALWAYS_SOFTWARE=1
echo "$(date): Global LIBGL_ALWAYS_SOFTWARE set to 1"

# --- ADD THIS SECTION TO REMOVE STALE LOCK FILE ---
LOCK_FILE="/tmp/.X${DISPLAY_NUM}-lock"
if [ -f "$LOCK_FILE" ]; then
    echo "$(date): Found stale X server lock file: $LOCK_FILE. Removing it."
    if rm -f "$LOCK_FILE"; then
        echo "$(date): Successfully removed $LOCK_FILE."
    else
        echo "$(date): WARNING: Failed to remove $LOCK_FILE. Attempting to start Xvfb anyway..."
        # You might want to exit here if removal is critical and fails,
        # but often Xvfb might still start if the lock was truly stale and rm failed due to weird permissions
        # that Xvfb itself can overcome.
    fi
fi
# --- END OF SECTION TO REMOVE STALE LOCK FILE ---

echo "$(date): Starting Xvfb..."
# Use $DISPLAY variable
Xvfb "$DISPLAY" -screen 0 1280x720x24 -ac +extension GLX -noreset -dpi 96 &
XFB_PID=$!
echo "$(date): Xvfb started with PID $XFB_PID. Waiting for X server to be ready on $DISPLAY..."

# Loop to check if X server is ready (xdpyinfo check from previous advice)
RETRY_COUNT=0
MAX_RETRIES=15 # Wait for max 15 seconds
while ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -gt $MAX_RETRIES ]; then
        echo "$(date): ERROR: Xvfb failed to start or become ready on $DISPLAY after $MAX_RETRIES attempts."
        echo "$(date): Dumping process list and exiting."
        ps aux # Output current processes for debugging
        if ! kill -0 $XFB_PID 2>/dev/null; then
            echo "$(date): Xvfb process (PID $XFB_PID) is NOT running!"
        else
            echo "$(date): Xvfb process (PID $XFB_PID) is still running. Connection issue or xdpyinfo problem?"
        fi
        exit 1
    fi
    echo "$(date): X server on $DISPLAY not ready yet (attempt $RETRY_COUNT/$MAX_RETRIES)... waiting 1s."
    sleep 1
done
echo "$(date): X server on $DISPLAY is ready."

echo "$(date): Starting pmhq (QQ)..."
#/opt/pmhq
dbus-run-session sh -c "exec env DISPLAY='$DISPLAY' LIBGL_ALWAYS_SOFTWARE='$LIBGL_ALWAYS_SOFTWARE' /opt/pmhq" &
PMHQ_LAUNCHER_PID=$!
echo "$(date): pmhq (QQ) launched via dbus-run-session (PID $PMHQ_LAUNCHER_PID) with DISPLAY=$DISPLAY."

# 等待 QQ 进程启动（PMHQ 注入完成后会退出，但 QQ 进程会保持运行）
echo "$(date): Waiting for QQ process to start..."
RETRY_COUNT=0
MAX_RETRIES=30
QQ_PID=""
while [ -z "$QQ_PID" ]; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -gt $MAX_RETRIES ]; then
        echo "$(date): ERROR: QQ process not found after $MAX_RETRIES attempts. Exiting."
        exit 1
    fi
    # 获取所有 QQ 进程 PID，排序后取最小的（主进程）
    QQ_PID=$(pgrep -x "qq" 2>/dev/null | sort -n | head -n 1 || true)
    if [ -z "$QQ_PID" ]; then
        echo "$(date): QQ process not found yet (attempt $RETRY_COUNT/$MAX_RETRIES)... waiting 1s."
        sleep 1
    fi
done
echo "$(date): QQ main process found with PID $QQ_PID."

echo "$(date): All services launched. Monitoring critical processes..."

while true; do
    if ! kill -0 $XFB_PID 2>/dev/null; then
        echo "$(date): CRITICAL: Xvfb (PID $XFB_PID) has died. Exiting."
        exit 1
    fi
    if ! kill -0 $QQ_PID 2>/dev/null; then
        echo "$(date): CRITICAL: QQ main process (PID $QQ_PID) has died. Exiting."
        exit 1
    fi
    sleep 5
done
