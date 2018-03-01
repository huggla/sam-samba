FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDOS_DIR="$BIN_DIR/sudos"
ENV CONFIG_DIR="/etc/samba"
ENV BUILDTIME_ENVIRONMENT="$SUDOS_DIR/buildtime_environment" \
    RUNTIME_ENVIRONMENT="$SUDOS_DIR/runtime_environment" \
    CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    SUDOERS_DIR="/etc/sudoers.d" \
    USER="samba" \
    SMBUSERS_FILE="$CONFIG_DIR/smbusers"
    
RUN addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
    && chmod go= /bin /sbin /usr/bin /usr/sbin \
 && env > "$BUILDTIME_ENVIRONMENT" \
 && touch "$RUNTIME_ENVIRONMENT" \
    && chmod u=rw,go= "$BUILDTIME_ENVIRONMENT" \
    && chown root:$USER "$RUNTIME_ENVIRONMENT" \
    && chmod u=rw,g=w,o= "$RUNTIME_ENVIRONMENT" \
 && apk add --no-cache samba-server sudo \
 && mv "$CONFIG_FILE" "$CONFIG_FILE.old" \
 && touch "$CONFIG_FILE" \
    && chown root:$USER "$CONFIG_DIR" "$CONFIG_FILE" \
    && chmod u=rx,g=rx,o= "$CONFIG_DIR" \
    && chmod u=rw,g=r,o= "$CONFIG_FILE" \
 && ln /usr/bin/sudo "$BIN_DIR/sudo" \
 && echo 'Defaults lecture="never"' > "$SUDOERS_DIR/docker1" \
 && echo "Defaults secure_path = \"$SUDOS_DIR\"" >> "$SUDOERS_DIR/docker1" \
 && echo 'Defaults env_keep = "SUDOERS_DIR DATABASES DATABASE_USERS param_* AUTH_HBA password_*"' > "$SUDOERS_DIR/docker2" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDOS_DIR/readenvironment.sh" >> "$SUDOERS_DIR/docker2" \
    && chmod u=rw,go= "$SUDOERS_DIR/docker"* "$SMBUSERS_FILE" \
    && chmod u=rx,go= "$SUDOS_DIR/readenvironment.sh" "$SUDOS_DIR/initsamba.sh"

USER ${USER}

ENV LOG_DIR="/var/log/samba"
ENV PATH="$BIN_DIR:$SUDOS_DIR" \
    SHARES_DIR="/shares" \
    global_smb_passwd_file="$CONFIG_DIR/smbpasswd" \
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
    SHARE_USERS="shareuser"

CMD ["sudo","readenvironment.sh"]
