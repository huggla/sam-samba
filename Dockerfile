FROM alpine:3.7

COPY ./bin/start.sh /usr/local/bin/start.sh

RUN apk add --no-cache samba-server \
    chmod 6555 /usr/sbin/nmbd /usr/sbin/smbd \
    mv /etc/samba/smb.conf /etc/samba/smb.conf.old \
    chmod +x /usr/local/bin/start.sh

ENV DNS_PROXY no \
    SMBPASSWD_FILE "\etc\samba\smbpasswd"
    PASSDB_BACKEND "smbpasswd $SMBPASSWD_FILE" \
    LOG_FILE "/var/log/samba/log.%m" \
    MAX_LOG_SIZE 0 \
    SYSLOG 0 \
    PANIC_ACTION "killall start.sh" \
    SERVER_ROLE standalone \
    MAP_TO_GUEST "bad user" \
    LOAD_PRINTERS no \
    PRINTING bsd \
    PRINTCAP_NAME "/dev/null" \
    DISABLE_SPOOLSS yes

CMD ["start.sh"]
#CMD nmbd -D && smbd -FS
