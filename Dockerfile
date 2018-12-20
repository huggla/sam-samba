ARG TAG="20181204"
ARG RUNDEPS="samba-server"
ARG EXECUTABLES="/usr/bin/smbpasswd"
ARG REMOVEFILES="/etc/samba"
ARG CONFIGDIR="/etc/samba"

#---------------Don't edit----------------
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${INITIMAGE:-${BASEIMAGE:-huggla/base:$TAG}} as init
FROM ${BUILDIMAGE:-huggla/build:$TAG} as build
FROM ${BASEIMAGE:-huggla/base:$TAG} as image
COPY --from=build /imagefs /
#-----------------------------------------

ENV VAR_LINUX_USER="root" \
    VAR_CONFIG_FILE="$CONFIGDIR/smb.conf" \
    VAR_SHARES_DIR="/shares" \
    VAR_SHARE_USERS="shareuser" \
    VAR_FINAL_COMMAND="/usr/sbin/nmbd -D && /usr/sbin/smbd -FS" \
    VAR_global_smb_passwd_file="$CONFIGDIR/smbpasswd" \
    VAR_global_dns_proxy="no" \
    VAR_global_username_map="$CONFIGDIR/usermap.txt" \
    VAR_global_log_file="/var/log/samba/log.%m" \
    VAR_global_max_log_size="0" \
    VAR_global_syslog="0" \
    VAR_global_panic_action="killall smbd" \
    VAR_global_server_role="standalone" \
    VAR_global_map_to_guest="bad user" \
    VAR_global_load_printers="no" \
    VAR_global_printing="bsd" \
    VAR_global_printcap_name="/dev/null" \
    VAR_global_disable_spoolss="yes"
     
#---------------Don't edit----------------
USER starter
ONBUILD USER root
#-----------------------------------------
