#!/bin/sh
set -e

IFS=";"
smbconf="$CONFIG_DIR/smb.conf"
mkdir -p "$CONFIG_DIR" "$SHARES_DIR"
PASSDB_BACKEND="smbpasswd:$SMBPASSWD_FILE"
if [ -z "$USERNAME_MAP_FILE" ]
then
   USERNAME_MAP_FILE="$CONFIG_DIR/usermap.txt"
fi
if [ ! -e "$smbconf" ]
then
   parameters="NETBIOS_NAME;WORKGROUP;SERVER_STRING;DNS_PROXY;PASSDB_BACKEND;LOG_FILE;MAX_LOG_SIZE;SYSLOG;PANIC_ACTION;SERVER_ROLE;MAP_TO_GUEST;LOAD_PRINTERS;PRINTING;PRINTCAP_NAME;DISABLE_SPOOLSS;USERSHARE_ALLOW_GUESTS"
   echo "[global]" >> $smbconf
   echo "username map=\"$USERNAME_MAP_FILE\"" >> $smbconf
   for param in $parameters
   do
      eval "param_value=\$$param"
      if [ -n "$param_value" ]
      then
         echo -n "$param" | tr '_' ' ' | tr '[:upper:]' '[:lower:]' >> $smbconf
         echo "=\"$param_value\"" >> $smbconf
      fi
   done
   if [ -n "$SHARES" ]
   then
      share_parameters="BROWSEABLE;READ_ONLY;GUEST_OK;ADMIN_USERS"
      for share in $SHARES
      do
         echo >> $smbconf
         echo "[$share]" >> $smbconf
         share_uc="$(echo $share | tr '[:lower:]' '[:upper:]')"
         pathstr='-PATH'
         path_var="$share_uc$pathstr"
         echo "path_var=$path_var"
         echo "path_value=$path_value"
         eval "path_value=\"\$$path_var\""
         echo "path_value=$path_value"
         echo $path_value
         if [ -z "$path_value" ]
         then
            path_value="$SHARES_DIR/$share"
            echo $path_value
         fi
         mkdir -p "$path_value"
         echo "path=$path_value" >> $smbconf
         for param in $share_parameters
         do
            param_var="$(echo $share | tr '[:lower:]' '[:upper:]')-$param"
            eval "param_value=\$$param_var"
            if [ -n "$param_value" ]
            then
               echo -n "$param" | tr '_' ' ' | tr '[:upper:]' '[:lower:]' >> $smbconf
               echo "=\"$param_value\"" >> $smbconf
            fi
         done
      done
   fi
fi
if [ ! -e "$USERNAME_MAP_FILE" ]
then
   mkdir -p "$(dirname "$USERNAME_MAP_FILE")"
   touch "$USERNAME_MAP_FILE"
   for user in $USERNAME_MAP
   do
      echo "$user" >> "$USERNAME_MAP_FILE"
   done
fi

nmbd -D && smbd -FS
exit 0
