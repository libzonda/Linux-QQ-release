#!/bin/sh
export HOME=/config
cd /opt/QQ

# AppRun in Linux QQ is broken in some envs (calculates path to /qq), 
# so we find and run the binary directly.
if [ -f "qq" ]; then
    exec ./qq --no-sandbox
elif [ -f "QQ" ]; then
    exec ./QQ --no-sandbox
elif [ -f "linuxqq" ]; then
    exec ./linuxqq --no-sandbox
else
    # Fallback: Find largest executable file (likely the binary)
    BINARY=$(find . -maxdepth 1 -type f -executable ! -name "AppRun" ! -name "*.sh" -printf "%s\t%p\n" | sort -n | tail -1 | cut -f2)
    if [ -n "$BINARY" ]; then
        echo "Found likely executable: $BINARY"
        exec "$BINARY" --no-sandbox
    else
        echo "Error: Could not find executable in /opt/QQ"
        ls -la
        exit 1
    fi
fi
