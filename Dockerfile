FROM alpine:3.7

# Image-specific BEV_NAME variable.
# ---------------------------------------------------------------------
ENV BEV_NAME="samba"
# ---------------------------------------------------------------------

ENV BIN_DIR="/usr/local/bin" \
    SUDOERS_DIR="/etc/sudoers.d" \
    CONFIG_DIR="/etc/$BEV_NAME"
ENV BUILDTIME_ENVIRONMENT="$BIN_DIR/buildtime_environment" \
    RUNTIME_ENVIRONMENT="$BIN_DIR/runtime_environment"

# Image-specific buildtime environment variables, prefixed with "BEV_".
# ---------------------------------------------------------------------
ENV BEV_CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    BEV_SMBUSERS_FILE="$CONFIG_DIR/smbusers"
# ---------------------------------------------------------------------

COPY ./bin ${BIN_DIR}
    
RUN env | grep "^BEV_" > "$BUILDTIME_ENVIRONMENT" \
 && addgroup -S $BEV_NAME \
 && adduser -D -S -H -s /bin/false -u 100 -G $BEV_NAME $BEV_NAME \
 && mkdir -p "$CONFIG_DIR" \
 && touch "$RUNTIME_ENVIRONMENT" \
 && apk add --no-cache sudo \
 && echo 'Defaults lecture="never"' > "$SUDOERS_DIR/docker1" \
 && echo "Defaults secure_path = \"$BIN_DIR\"" >> "$SUDOERS_DIR/docker1" \
 && echo 'Defaults env_keep = "REV_*"' > "$SUDOERS_DIR/docker2" \
 && echo "$BEV_NAME ALL=(root) NOPASSWD: $BIN_DIR/start" >> "$SUDOERS_DIR/docker2" \
 && chmod go= /bin /sbin /usr/bin /usr/sbin \
 && chmod u=rx,go= "$BIN_DIR/"* \
 && chmod u=rw,go= "$BUILDTIME_ENVIRONMENT" \
 && chown root:$BEV_NAME "$RUNTIME_ENVIRONMENT" \
 && chmod u=rw,g=w,o= "$RUNTIME_ENVIRONMENT" \
 && chmod u=rw,go= "$SUDOERS_DIR/docker"* \
 && ln /usr/bin/sudo "$BIN_DIR/sudo"

# Image-specific RUN commands.
# ---------------------------------------------------------------------
RUN apk add --no-cache samba-server \
 && mv "$BEV_CONFIG_FILE" "$BEV_CONFIG_FILE.old"
# ---------------------------------------------------------------------
    
USER ${BEV_NAME}

# Image-specific runtime environment variables, prefixed with "REV_".
# ---------------------------------------------------------------------
ENV REV_SHARES_DIR="/shares" \
    REV_SHARE_USERS="shareuser" \
    REV_global_smb_passwd_file="$CONFIG_DIR/smbpasswd" \
    REV_global_dns_proxy="no" \
    REV_global_username_map="$CONFIG_DIR/usermap.txt" \
    REV_global_log_file="/var/log/samba/log.%m" \
    REV_global_max_log_size="0" \
    REV_global_syslog="0" \
    REV_global_panic_action="killall smbd" \
    REV_global_server_role="standalone" \
    REV_global_map_to_guest="bad user" \
    REV_global_load_printers="no" \
    REV_global_printing="bsd" \
    REV_global_printcap_name="/dev/null" \
    REV_global_disable_spoolss="yes"
# ---------------------------------------------------------------------

ENV PATH="$BIN_DIR"

CMD ["sudo","start"]
