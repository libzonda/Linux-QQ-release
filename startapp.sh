#!/bin/sh
export HOME=/config
# The main binary in the extracted AppImage is usually named 'qq'
exec /opt/QQ/AppRun --no-sandbox
