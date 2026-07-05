#!/bin/bash

INTERFACE="enp8s0"
TARGET_PING="2400:3200::1"
TARGET_CURL="https://ipv6.ustc.edu.cn"
PING_COUNT=3
LOG_FILE="/Disk/Local/NetworkKeepLive/ipv6_keepalive.log"
MAX_LOG_LINES=500

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local lines
        lines=$(wc -l < "$LOG_FILE")
        if [ "$lines" -gt "$MAX_LOG_LINES" ]; then
            tail -n $((MAX_LOG_LINES / 2)) "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
        fi
    fi
}

rotate_log

if curl -6 --interface "$INTERFACE" \
        --connect-timeout 10 \
        --max-time 15 \
        --silent --output /dev/null \
        "$TARGET_CURL"; then
    log "[OK] curl via $INTERFACE -> $TARGET_CURL success"
else
    log "[FAIL] curl via $INTERFACE -> $TARGET_CURL failed"
fi

if ping -6 -I "$INTERFACE" -c "$PING_COUNT" -W 5 "$TARGET_PING" &>/dev/null; then
    log "[OK] ping6 via $INTERFACE -> $TARGET_PING success"
else
    log "[FAIL] ping6 via $INTERFACE -> $TARGET_PING failed"
fi
