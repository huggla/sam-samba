FROM alpine:3.7

COPY ./bin/start.sh /usr/local/bin/start.sh

ENV CONFIG_DIR=/etc/samba \
    SHARES_DIR="/shares" \
    SECRET_DIR="$CONFIG_DIR/secret" \
    SMBPASSWD_FILE="$SECRET_DIR/smbpasswd" \
    LOG_DIR=/var/log/samba

RUN apk add --no-cache samba-server \
 && chmod 6555 /usr/sbin/nmbd /usr/sbin/smbd \
 && mv "$CONFIG_DIR/smb.conf" "$CONFIG_DIR/smb.conf.old" \
 && chmod +x /usr/local/bin/start.sh \
 && adduser -D -S -u 100 samba \
 && mkdir -p "$SECRET_DIR" "$SHARES_DIR" \
 && touch "$SMBPASSWD_FILE" \
 && chmod -R 400 "$SECRET_DIR" \
 && chown samba "$CONFIG_DIR" "$SHARES_DIR"

ENV DNS_PROXY=no \
    LOG_FILE="$LOG_DIR/log.%m" \
    MAX_LOG_SIZE=0 \
    SYSLOG=0 \
    PANIC_ACTION="killall start.sh" \
    SERVER_ROLE=standalone \
    MAP_TO_GUEST="bad user" \
    LOAD_PRINTERS=no \
    PRINTING=bsd \
    PRINTCAP_NAME="/dev/null" \
    DISABLE_SPOOLSS=yes

USER samba

CMD ["start.sh"]
