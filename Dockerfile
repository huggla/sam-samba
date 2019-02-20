ARG TAG="20190206"
ARG RUNDEPS="samba-server"
ARG STARTUPEXECUTABLES="/usr/bin/smbpasswd"
ARG REMOVEDIRS="/etc/samba"

#--------Generic template (don't edit)--------
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${INITIMAGE:-${BASEIMAGE:-huggla/base:$TAG}} as init
FROM ${BUILDIMAGE:-huggla/build} as build
FROM ${BASEIMAGE:-huggla/base:$TAG} as image
ARG CONTENTSOURCE1
ARG CONTENTSOURCE1="${CONTENTSOURCE1:-/}"
ARG CONTENTDESTINATION1
ARG CONTENTDESTINATION1="${CONTENTDESTINATION1:-/buildfs/}"
ARG CONTENTSOURCE2
ARG CONTENTSOURCE2="${CONTENTSOURCE2:-/}"
ARG CONTENTDESTINATION2
ARG CONTENTDESTINATION2="${CONTENTDESTINATION2:-/buildfs/}"
ARG CLONEGITSDIR
ARG DOWNLOADSDIR
ARG MAKEDIRS
ARG MAKEFILES
ARG EXECUTABLES
ARG STARTUPEXECUTABLES
ARG EXPOSEFUNCTIONS
COPY --from=build /imagefs /
#---------------------------------------------

ARG CONFIG_DIR="/etc/samba"

ENV VAR_LINUX_USER="root" \
    VAR_CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    VAR_DEBUGLEVEL="1" \
    VAR_SHARES_DIR="/shares" \
    VAR_SHARE_USERS="shareuser" \
    VAR_FINAL_COMMAND="/usr/sbin/nmbd --daemon --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group && /usr/sbin/smbd --foreground --log-stdout --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group" \
    VAR_global_smb_passwd_file="$CONFIG_DIR/smbpasswd" \
    VAR_global_dns_proxy="no" \
    VAR_global_username_map="$CONFIG_DIR/usermap.txt" \
    VAR_global_log_file="/var/log/samba/log.%m" \
    VAR_global_max_log_size="0" \
    VAR_global_panic_action="killall smbd" \
    VAR_global_server_role="standalone" \
    VAR_global_map_to_guest="bad user" \
    VAR_global_load_printers="no" \
    VAR_global_printing="bsd" \
    VAR_global_printcap_name="/dev/null" \
    VAR_global_disable_spoolss="yes"
     
#--------Generic template (don't edit)--------
USER starter
ONBUILD USER root
#---------------------------------------------
