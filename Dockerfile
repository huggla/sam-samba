FROM alpine:3.7

# Image-specific BEV_NAME variable.
# ---------------------------------------------------------------------
ENV BEV_NAME="samba"
# ---------------------------------------------------------------------

ENV BIN_DIR="/usr/local/bin" \
    SUDOERS_DIR="/etc/sudoers.d" \
    CONFIG_DIR="/etc/$BEV_NAME" \
    LANG="en_US.UTF-8"
ENV BUILDTIME_ENVIRONMENT="$BIN_DIR/buildtime_environment" \
    RUNTIME_ENVIRONMENT="$BIN_DIR/runtime_environment"

# Image-specific buildtime environment variables.
# ---------------------------------------------------------------------
ENV BEV_CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    BEV_SMBUSERS_FILE="$CONFIG_DIR/smbusers"
# ---------------------------------------------------------------------

COPY ./bin ${BIN_DIR}

# Image-specific COPY commands.
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
    
RUN env | grep "^BEV_" > "$BUILDTIME_ENVIRONMENT" \
 && addgroup -S sudoer \
 && adduser -D -S -H -s /bin/false -u 100 -G sudoer sudoer \
 && (getent group $BEV_NAME || addgroup -S $BEV_NAME) \
 && (getent passwd $BEV_NAME || adduser -D -S -H -s /bin/false -u 101 -G $BEV_NAME $BEV_NAME) \
 && touch "$RUNTIME_ENVIRONMENT" \
 && apk add --no-cache sudo \
 && echo 'Defaults lecture="never"' > "$SUDOERS_DIR/docker1" \
 && echo "Defaults secure_path = \"$BIN_DIR\"" >> "$SUDOERS_DIR/docker1" \
 && echo 'Defaults env_keep = "REV_*"' > "$SUDOERS_DIR/docker2" \
 && echo "sudoer ALL=(root) NOPASSWD: $BIN_DIR/start" >> "$SUDOERS_DIR/docker2"

# Image-specific RUN commands.
# ---------------------------------------------------------------------
RUN apk add --no-cache samba-server \
 && mv "$BEV_CONFIG_FILE" "$BEV_CONFIG_FILE.old"
# ---------------------------------------------------------------------
    
RUN chmod go= /bin /sbin /usr/bin /usr/sbin \
 && chown root:$BEV_NAME "$BIN_DIR/"* \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && ln /usr/bin/sudo "$BIN_DIR/sudo" \
 && chown root:sudoer "$BIN_DIR/sudo" "$BUILDTIME_ENVIRONMENT" "$RUNTIME_ENVIRONMENT" \
 && chown root:root "$BIN_DIR/start"* \
 && chmod u+s "$BIN_DIR/sudo" \
 && chmod u=rw,g=w,o= "$RUNTIME_ENVIRONMENT" \
 && chmod u=rw,go= "$BUILDTIME_ENVIRONMENT" "$SUDOERS_DIR/docker"*
 
USER sudoer

# Image-specific runtime environment variables.
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
