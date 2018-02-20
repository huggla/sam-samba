FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV CONFIG_DIR="/etc/samba"
ENV SHARES_DIR="/shares" \
    LOG_DIR="/var/log/samba" \
    SUDO_DIR="$BIN_DIR/sudo" \
    CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    USER="samba" \
    SUDOERS_FILE="/etc/sudoers.d/samba" \
    global_smb_passwd_file="$CONFIG_DIR/smbpasswd"
    
RUN apk add --no-cache samba-server sudo \
 && mv "$CONFIG_FILE" "$CONFIG_FILE.old" \
 && touch "$global_smb_passwd_file" \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && chmod u=rx,go= "$SUDO_DIR/"* \
 && chmod u=rwx,g=wx,o= "$CONFIG_DIR" \
 && addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && chown root:$USER "$CONFIG_DIR" "$BIN_DIR/"* \
 && echo 'Defaults lecture="never"' > "$SUDOERS_FILE" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDO_DIR/,/usr/sbin/nmbd,/usr/sbin/smbd" >> "$SUDOERS_FILE" \
 && chmod u=rw,go= "$global_smb_passwd_file" "$SUDOERS_FILE"

ENV global_dns_proxy="no" \
    global_username_map="$CONFIG_DIR/usermap.txt" \
    global_log_file="$LOG_DIR/log.%m" \
    global_max_log_size="0" \
    global_syslog="0" \
    global_panic_action="killall smbd" \
    global_server_role="standalone" \
    global_map_to_guest="bad user" \
    global_load_printers="no" \
    global_printing="bsd" \
    global_printcap_name="/dev/null" \
    global_disable_spoolss="yes" \
    SHARE_USERS="shareuser" \
    DELETE_PASSWORD_FILES="no"

USER ${USER}

CMD ["/usr/local/bin/start.sh"]
