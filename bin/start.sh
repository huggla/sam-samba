#!/bin/sh
set -e
set +a
set +m
set +s
set +i

env > "$ENVIRONMENT_FILE"
exec env -i sudo "$SUDO_DIR/run.sh"
