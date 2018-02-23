FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDO_DIR="$BIN_DIR/sudo"
ENV CONFIG_DIR="/etc/samba"
ENV SHARES_DIR="/shares" \
    LOG_DIR="/var/log/samba" \
    ENVIRONMENT_FILE="$SUDO_DIR/environment" \
    CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    USER="samba" \
    SUDOERS_FILE="/etc/sudoers.d/samba" \
    SMBUSERS_FILE="$CONFIG_DIR/smbusers"
    
RUN apk add --no-cache samba-server sudo \
 && mv "$CONFIG_FILE" "$CONFIG_FILE.old" \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && chmod u=rx,go= "$SUDO_DIR/"* \
 && touch "$ENVIRONMENT_FILE" "$SMBUSERS_FILE" \
 && chmod u=rw,g=w,o= "$ENVIRONMENT_FILE" \
 && addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && chown root:$USER "$ENVIRONMENT_FILE" "$BIN_DIR/start.sh" \
 && echo 'Defaults lecture="never"' > "$SUDOERS_FILE" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDO_DIR/runsmbd.sh" >> "$SUDOERS_FILE" \
 && chmod u=rwX,go= "$CONFIG_FILE" "$SMBUSERS_FILE" "$SUDOERS_FILE"

ENV global_smb_passwd_file="$CONFIG_DIR/smbpasswd" \
    global_dns_proxy="no" \
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

CMD ["start.sh"]
