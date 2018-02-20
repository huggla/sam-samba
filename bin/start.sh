#!/bin/sh
set -e
set +a
set +m
set +s
set +i

env > "$CONFIG_DIR/environment"
exec env -i $sudo "$SUDO_DIR/run.sh"
exit
