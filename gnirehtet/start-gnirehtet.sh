#!/bin/bash

# Function to handle SIGINT (Ctrl+C) and SIGTSTP (Ctrl+Z)
cleanup() {
    echo "Signal received, cleaning up..."
    # Kill the gnirehtet process if it's running
    if ps -p $GNIREHTET_PID >/dev/null; then
        kill $GNIREHTET_PID
        echo "Gnirehtet process killed."
    fi
    exit 1 # Exit the script with an error status
}

# Trap SIGINT and SIGTSTP, calling 'cleanup' function when they're received
trap cleanup SIGINT SIGTSTP

echo '------------- Starting adb daemon -------------'
adb devices

echo '------------- Starting gnirehtet -------------'
${GNIREHTET_CMD:-gnirehtet run} 2>&1 | tee gnirehtetlog.txt &
GNIREHTET_PID=$!

sleep 5

echo "Checking for Gnirehtet error..."
if grep -q -E '(E Gnirehtet|Exception in thread)' gnirehtetlog.txt; then
    echo "Error found, attempting to kill Gnirehtet"
    if ps -p $GNIREHTET_PID >/dev/null; then
        kill $GNIREHTET_PID
        echo "Gnirehtet process killed due to error."
    else
        echo "Gnirehtet process not found."
    fi
    # Exit with an error status when gnirehtet fails to start correctly.
    exit 1
else
    echo "No Gnirehtet error found, continuing"
fi

wait $GNIREHTET_PID
