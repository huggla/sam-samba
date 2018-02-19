FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV CONFIG_DIR="/etc/samba"
ENV SECRET_DIR="$CONFIG_DIR/secret"
ENV SHARES_DIR="/shares" \
    LOG_DIR="/var/log/samba" \
    SUDO_DIR="$BIN_DIR/sudo" \
    CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    USER="samba" \
    PATH="$PATH:$BIN_DIR" \
    global_smb_passwd_file="$SECRET_DIR/smbpasswd"
    
RUN apk add --no-cache samba-server sudo \
 && mv "$CONFIG_FILE" "$CONFIG_FILE.old" \
 && mkdir -p "$SECRET_DIR" \
 && touch "$global_smb_passwd_file" \
 && chmod u=rw,go= "$global_smb_passwd_file" \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && chmod u=rx,go= "$SUDO_DIR/"* \
 && chmod u=rwx,g=wx,o= "$CONFIG_DIR" "$SECRET_DIR" \
 && addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && chown root:$USER "$CONFIG_DIR" "$SECRET_DIR" "$BIN_DIR/"* \
 && echo 'Defaults secure_path=""' > /etc/sudoers.d/samba \
 && echo 'Defaults requiretty' >> /etc/sudoers.d/samba \
 && echo 'Defaults use_pty' >> /etc/sudoers.d/samba \
 && echo "$USER HOST=(root) NOPASSWD: $(find "$SUDO_DIR" -type f | paste -d, -s ),/usr/sbin/nmbd,/usr/sbin/smbd" >> /etc/sudoers.d/samba

ENV global_dns_proxy="no" \
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
