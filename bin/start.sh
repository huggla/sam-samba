#!/bin/sh
set -e
set +a
set +m
set +s
set +i

IFS=";"
smbconf="$CONFIG_DIR/smb.conf"
sudo mkdir2root "$SHARES_DIR"
PASSDB_BACKEND="smbpasswd:$SMBPASSWD_FILE"
if [ -z "$USERNAME_MAP_FILE" ]
then
   USERNAME_MAP_FILE="$CONFIG_DIR/usermap.txt"
fi
if [ ! -e "$smbconf" ]
then
   parameters="NETBIOS_NAME;WORKGROUP;SERVER_STRING;DNS_PROXY;PASSDB_BACKEND;LOG_FILE;MAX_LOG_SIZE;SYSLOG;PANIC_ACTION;SERVER_ROLE;MAP_TO_GUEST;LOAD_PRINTERS;PRINTING;PRINTCAP_NAME;DISABLE_SPOOLSS;USERSHARE_ALLOW_GUESTS"
   echo "[global]" >> $smbconf
   echo "smb passwd file=$SMBPASSWD_FILE" >> $smbconf
   echo "username map=$USERNAME_MAP_FILE" >> $smbconf
   for param in $parameters
   do
      eval "param_value=\$$param"
      if [ -n "$param_value" ]
      then
         echo -n "$param" | tr '_' ' ' | tr '[:upper:]' '[:lower:]' >> $smbconf
         echo "=$param_value" >> $smbconf
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
         sudo mkdir2root "$path_value"
         echo "path=$path_value" >> $smbconf
         for param in $share_parameters
         do
            param_var="$(echo $share | tr '[:lower:]' '[:upper:]')_$param"
            eval "param_value=\$$param_var"
            if [ -n "$param_value" ]
            then
               echo -n "$param" | tr '_' ' ' | tr '[:upper:]' '[:lower:]' >> $smbconf
               echo "=$param_value" >> $smbconf
            fi
         done
      done
   fi
fi
if [ ! -e "$USERNAME_MAP_FILE" ]
then
   username_dir="$(dirname "$USERNAME_MAP_FILE")"
   mkdir -p "$username_dir"
   touch "$USERNAME_MAP_FILE"
   for user in $USERNAME_MAP
   do
      echo "$user" >> "$USERNAME_MAP_FILE"
   done
   sudo chown2root -R "$username_dir"
fi
for user in $SHARE_USERS
do
   user_uc=$(echo $user | tr '[:lower:]' '[:upper:]')
   envvar=$user_uc"_PASSWORD_FILE"
   eval "userpwfile=\$$envvar"
   if [ -z $userpwfile ]
   then
      envvar=$user_uc"_PASSWORD"
      userpwfile=$SECRET_DIR/$user"_pw"
      eval "echo \$$envvar > $userpwfile"
      eval "echo -n \$$envvar >> $userpwfile"
   fi
   sudo addshareuser "$user" "$userpwfile" "$CONFIG_DIR/smbusers"
done
sudo chown2root -R "$SECRET_DIR"
sudo chown2root -R "$CONFIG_DIR"
sudo chown2root "$SHARES_DIR"
sudo nmbd -D && sudo smbd -FS
exit 0
