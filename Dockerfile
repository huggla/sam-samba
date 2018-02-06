FROM alpine:3.7

COPY ./bin/start.sh /usr/local/bin/start.sh

ENV CONFIG_DIR "/etc/samba"
ENV SECRET_DIR "$CONFIG_DIR/secret"
ENV SHARES_DIR="/shares" \
    SMBPASSWD_FILE="$SECRET_DIR/smbpasswd" \
    LOG_DIR="/var/log/samba"

RUN apk add --no-cache samba-server sudo \
 && chmod 6555 /usr/sbin/nmbd /usr/sbin/smbd \
 && mv "$CONFIG_DIR/smb.conf" "$CONFIG_DIR/smb.conf.old" \
 && chmod 500 /usr/local/bin/start.sh \
 && mkdir -p "$SECRET_DIR" "$SHARES_DIR" \
 && chmod -R 700 "$CONFIG_DIR" "$SHARES_DIR" \
 && touch "$SMBPASSWD_FILE" \
 && chmod -R 500 "$SECRET_DIR" \
 && adduser -D -S -u 100 samba \
 && echo "samba ALL=(root) NOPASSWD:SETENV: /usr/local/bin/start.sh" > /etc/sudoers.d/samba

ENV DNS_PROXY="no" \
    LOG_FILE="$LOG_DIR/log.%m" \
    MAX_LOG_SIZE="0" \
    SYSLOG="0" \
    PANIC_ACTION="killall start.sh" \
    SERVER_ROLE="standalone" \
    MAP_TO_GUEST="bad user" \
    LOAD_PRINTERS="no" \
    PRINTING="bsd" \
    PRINTCAP_NAME="/dev/null" \
    DISABLE_SPOOLSS="yes"

USER samba

CMD ["sudo", "-E", "start.sh"]
