#!/bin/sh
set -e

IFS=";"
smbconf="$CONFIG_DIR/smb.conf"
sudo mksmbdir "$SHARES_DIR"
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
         path_var="$(echo $share | tr '[:lower:]' '[:upper:]')_PATH"
         eval "path_value=\$$path_var"
         if [ -z "$path_value" ]
         then
            path_value="$SHARES_DIR/$share"
         fi
         mkdir -p "$path_value"
         echo "path=$path_value" >> $smbconf
         for param in $share_parameters
         do
            param_var="$(echo $share | tr '[:lower:]' '[:upper:]')_$param"
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
echo "$USERNAME_MAP_FILE"
if [ ! -e "$USERNAME_MAP_FILE" ]
then
   username_dir="$(dirname "$USERNAME_MAP_FILE")"
   sudo mkdir -p "$username_dir"
   touch "$USERNAME_MAP_FILE"
   for user in $USERNAME_MAP
   do
      echo "$user" >> "$USERNAME_MAP_FILE"
   done
   sudo chown2root -R "$username_dir"
fi
sudo chown2root -R "$CONFIG_DIR"
sudo chown2root -R "$SHARES_DIR"
echo hej
sudo nmbd -D && echo hej2 && sudo smbd -FS && echo hej3
exit 0
