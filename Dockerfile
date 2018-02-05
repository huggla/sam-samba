FROM alpine:3.7

COPY ./bin/start.sh /usr/local/bin/start.sh

ENV CONFIG_DIR /etc/samba
ENV SECRET_DIR "$CONFIG_DIR/secret"
ENV SMBPASSWD_FILE "$SECRET_DIR/smbpasswd"
ENV LOG_DIR /var/log/samba

RUN apk add --no-cache samba-server \
 && chmod 6555 /usr/sbin/nmbd /usr/sbin/smbd \
 && mv "$CONFIG_DIR/smb.conf" "$CONFIG_DIR/smb.conf.old" \
 && chmod +x /usr/local/bin/start.sh \
 && adduser -D -S -u 100 samba \
 && mkdir -p "$SECRET_DIR" "$LOG_DIR/cores" \
 && touch "$SMBPASSWD_FILE" \
 && chmod -R 400 "$SECRET_DIR" \
 && chown samba "$CONFIG_DIR" \
 && chown -R samba "$LOG_DIR" \
 && chmod -R 0700 "$LOG_DIR"

ENV DNS_PROXY no \
    PASSDB_BACKEND "smbpasswd $SMBPASSWD_FILE" \
    LOG_FILE "$LOG_DIR/log.%m" \
    MAX_LOG_SIZE 0 \
    SYSLOG 0 \
    PANIC_ACTION "killall start.sh" \
    SERVER_ROLE standalone \
    MAP_TO_GUEST "bad user" \
    LOAD_PRINTERS no \
    PRINTING bsd \
    PRINTCAP_NAME "/dev/null" \
    DISABLE_SPOOLSS yes

USER samba

CMD ["start.sh"]
