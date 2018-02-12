FROM alpine:3.7

COPY ./bin/* /usr/local/bin/

ENV CONFIG_DIR "/etc/samba"
ENV SECRET_DIR "$CONFIG_DIR/secret"
ENV SHARES_DIR="/shares" \
    SMBPASSWD_FILE="$SECRET_DIR/smbpasswd" \
    LOG_DIR="/var/log/samba"

RUN apk add --no-cache samba-server sudo \
 && mv "$CONFIG_DIR/smb.conf" "$CONFIG_DIR/smb.conf.old" \
 && chmod 500 /usr/local/bin/procremount /usr/local/bin/chown2root /usr/local/bin/mkdir2root /usr/local/bin/addlinuxusers /usr/local/bin/addshareuser /usr/local/bin/smbpasswd /usr/local/bin/sudoremove /usr/local/bin/runsmbd \
 && chmod +x /usr/local/bin/start.sh \
 && mkdir -p "$SECRET_DIR" \
 && touch "$SMBPASSWD_FILE" \
 && adduser -D -S -H -s /bin/false -u 100 samba \
 && chown samba "$CONFIG_DIR" "$SECRET_DIR" /usr/local/bin/runsmbd \
 && echo "samba ALL=(root) NOPASSWD: /usr/local/bin/procremount, /usr/local/bin/chown2root, /usr/local/bin/addlinuxusers, /usr/local/bin/mkdir2root, /usr/local/bin/addshareuser, /usr/local/bin/sudoremove, /usr/sbin/nmbd, /usr/sbin/smbd" > /etc/sudoers.d/samba

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
    SHARE_USERS="shareuser"

USER samba

CMD ["env -i start.sh `env`"]
