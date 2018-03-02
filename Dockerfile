FROM alpine:3.7

# Buildtime environment variables (can't be modified at runtime).
ENV BEV_BIN_DIR="/usr/local/bin" \
    BEV_CONFIG_DIR="/etc/samba"
ENV BEV_SUDOS_DIR="$BEV_BIN_DIR/sudos"
ENV BEV_BUILDTIME_ENVIRONMENT="$BEV_SUDOS_DIR/buildtime_environment" \
    BEV_RUNTIME_ENVIRONMENT="$BEV_SUDOS_DIR/runtime_environment" \
    BEV_CONFIG_FILE="$BEV_CONFIG_DIR/smb.conf" \
    BEV_USER="samba" \
    BEV_SMBUSERS_FILE="$BEV_CONFIG_DIR/smbusers"
    
COPY ./bin ${BEV_BIN_DIR}
    
RUN addgroup -S $BEV_USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $BEV_USER $BEV_USER \
    && chmod go= /bin /sbin /usr/bin /usr/sbin \
 && env | grep "^BEV_" > "$BEV_BUILDTIME_ENVIRONMENT" \
 && touch "$BEV_RUNTIME_ENVIRONMENT" \
    && chmod u=rw,go= "$BEV_BUILDTIME_ENVIRONMENT" \
    && chown root:$USER "$BEV_RUNTIME_ENVIRONMENT" \
    && chmod u=rw,g=w,o= "$BEV_RUNTIME_ENVIRONMENT" \
 && apk add --no-cache samba-server sudo \
 && mv "$BEV_CONFIG_FILE" "$BEV_CONFIG_FILE.old" \
 && touch "$BEV_CONFIG_FILE" \
    && chown root:$BEV_USER "$BEV_CONFIG_DIR" "$BEV_CONFIG_FILE" \
    && chmod u=rx,g=rx,o= "$BEV_CONFIG_DIR" \
    && chmod u=rw,g=r,o= "$BEV_CONFIG_FILE" \
 && ln /usr/bin/sudo "$BEV_BIN_DIR/sudo" \
 && echo 'Defaults lecture="never"' > /etc/sudoers.d/docker1 \
 && echo "Defaults secure_path = \"$BEV_SUDOS_DIR\"" >> /etc/sudoers.d/docker1 \
 && echo 'Defaults env_keep = "REV_*"' > /etc/sudoers.d/docker2 \
 && echo "$BEV_USER ALL=(root) NOPASSWD: $BEV_SUDOS_DIR/readenvironment.sh" >> /etc/sudoers.d/docker2 \
    && chmod u=rw,go= /etc/sudoers.d/docker? "$BEV_SMBUSERS_FILE" \
    && chmod u=rx,go= "$BEV_SUDOS_DIR/readenvironment.sh" "$BEV_SUDOS_DIR/initsamba.sh"

USER ${BEV_USER}

# Runtume environment variables.
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

ENV PATH="$BEV_BIN_DIR:$BEV_SUDOS_DIR"

CMD ["sudo","readenvironment.sh"]
