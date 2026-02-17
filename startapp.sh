#!/bin/sh
export HOME=/config
cd /opt/QQ

# AppRun in Linux QQ is broken in some envs, so we find and run the binary directly.
BINARY=""
if [ -f "qq" ]; then
    BINARY="./qq"
elif [ -f "QQ" ]; then
    BINARY="./QQ"
elif [ -f "linuxqq" ]; then
    BINARY="./linuxqq"
else
    # Fallback: Find largest executable file (likely the binary)
    BINARY=$(find . -maxdepth 1 -type f -executable ! -name "AppRun" ! -name "*.sh" -printf "%s\t%p\n" | sort -n | tail -1 | cut -f2)
fi

if [ -z "$BINARY" ]; then
    echo "Error: Could not find executable in /opt/QQ"
    ls -la
    exit 1
fi

# Determine number of instances
QQ_INSTANCE_COUNT=${QQ_INSTANCE_COUNT:-1}
if [ "$QQ_INSTANCE_COUNT" -lt 1 ]; then
    QQ_INSTANCE_COUNT=1
fi

echo "Starting $QQ_INSTANCE_COUNT instance(s) of QQ..."

# Start secondary instances in background
i=2
while [ "$i" -le "$QQ_INSTANCE_COUNT" ]; do
    echo "Starting QQ instance $i..."
    # Isolate user data to prevent white screen/crashes
    # Default user data is in ~/.config/QQ
    DATA_DIR="$HOME/.config/QQ_$i"
    "$BINARY" --no-sandbox --disable-gpu --disable-dev-shm-usage --user-data-dir="$DATA_DIR" &
    i=$((i + 1))
    sleep 5
done

echo "Starting main QQ instance..."
exec "$BINARY" --no-sandbox --disable-gpu --disable-dev-shm-usage
