#!/bin/sh
set -e +a +m +s +i -f

readonly SUDO_USER
readonly BIN_DIR="$(/usr/bin/dirname $0)"
readonly RUNTIME_ENVIRONMENT="$BIN_DIR/runtime_environment"
if [ -f "$RUNTIME_ENVIRONMENT" ]
then
   echo "$SUDO_USER $(/bin/hostname)=(root) NOPASSWD: $BIN_DIR/readenvironment.sh" > /etc/sudoers.d/docker2
   /usr/bin/env | grep "^REV_" > "$RUNTIME_ENVIRONMENT"
fi
if [ -n "$REV_password_$SUDO_USER" ]
then
   unset "$REV_password_$SUDO_USER"
fi
exec /usr/bin/env -i "$BIN_DIR/initandrun.sh"
