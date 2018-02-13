FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY "./bin/*" "${BIN_DIR}/"

ENV CONFIG_DIR="/etc/samba"
ENV SECRET_DIR="$CONFIG_DIR/secret"
ENV SHARES_DIR="/shares" \
    SMBPASSWD_FILE="$SECRET_DIR/smbpasswd" \
    LOG_DIR="/var/log/samba" \
    SUDO_DIR="$BIN_DIR/sudo"
    
RUN apk add --no-cache samba-server sudo \
 && mv "$CONFIG_DIR/smb.conf" "$CONFIG_DIR/smb.conf.old" \
 && chmod 500 "$SUDO_DIR/*" "$BIN_DIR/runsmbd" \
 && chmod go+rx "$BIN_DIR/start.sh" \
 && mkdir -p "$SECRET_DIR" \
 && touch "$SMBPASSWD_FILE" \
 && adduser -D -S -H -s /bin/false -u 100 samba \
 && chown samba "$CONFIG_DIR" "$SECRET_DIR" "$BIN_DIR/runsmbd" \
 && echo "samba ALL=(root) NOPASSWD: "$SUDO_DIR/*", /usr/sbin/nmbd, /usr/sbin/smbd" > /etc/sudoers.d/samba

ENV DNS_PROXY="no" \
    LOG_FILE="$LOG_DIR/log.%m" \
    MAX_LOG_SIZE="0" \
    SYSLOG="0" \
    PANIC_ACTION="killall smbd" \
    SERVER_ROLE="standalone" \
    MAP_TO_GUEST="bad user" \
    LOAD_PRINTERS="no" \
    PRINTING="bsd" \
    PRINTCAP_NAME="/dev/null" \
    DISABLE_SPOOLSS="yes" \
    SHARE_USERS="shareuser" \
    DELETE_PASSWORD_FILES="no"

USER samba

CMD ["$BIN_DIR/start.sh"]
