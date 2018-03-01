#!/bin/sh
set -e +a +m +s +i -f

readonly SUDOS_DIR="$(/usr/bin/dirname $0)"
readonly RUNTIME_ENVIRONMENT="$SUDOS_DIR/runtime_environment"
if [ -f "$RUNTIME_ENVIRONMENT" ]
then
   echo "$SUDO_USER $(/bin/hostname)=(root) NOPASSWD: $SUDOS_DIR/readenvironment.sh" > "$SUDOERS_DIR/docker2"
   /usr/bin/env > "$RUNTIME_ENVIRONMENT"
fi
unset password_$SUDO_USER
exec /usr/bin/env -i "$SUDOS_DIR/initsamba.sh"
