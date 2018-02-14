#!/bin/sh
set -e
set +a
set +m
set +s
set +i

if [ -d "$SUDO_DIR" ]
then
   IFS="${IFS};"
   smbconf="$CONFIG_DIR/smb.conf"
   sudo="/usr/bin/sudo"
   env -i $sudo "$SUDO_DIR/mkdir2root" "$SHARES_DIR"
   PASSDB_BACKEND="smbpasswd:$SMBPASSWD_FILE"
   if [ -z "$USERNAME_MAP_FILE" ]
   then
      USERNAME_MAP_FILE="$CONFIG_DIR/usermap.txt"
   fi
   if [ ! -e "$smbconf" ]
   then
      parameters="netbios_name;workgroup;server_string;dns_proxy;passdb_backend;log_file;max_log_size;syslog;panic_action;server_role;map_to_guest;load_printers;printing;printcap_name;disable_spoolss;usershare_allow_guests"
      echo "[global]" >> $smbconf
      echo "smb passwd file=$SMBPASSWD_FILE" >> $smbconf
      echo "username map=$USERNAME_MAP_FILE" >> $smbconf
      for param in $parameters
      do
         eval "param_value=\$$param"
         if [ -n "$param_value" ]
         then
            echo -n "$param" | tr '_' ' ' >> $smbconf
            echo "=$param_value" >> $smbconf
         fi
      done
      if [ -n "$SHARES" ]
      then
         for share in $SHARES
         do
            echo >> $smbconf
            echo "[$share]" >> $smbconf
            share_lc="$(echo $share | tr '[:upper:]' '[:lower:]')"
            share_parameters=`env | /bin/grep "${share_lc}_" | /bin/sed "s/^${share_lc}_//g" | /bin/grep -oE '^[^=]+'`
            path_value="$SHARES_DIR/$share"
            for param in $share_parameters
            do
               param_var="${share_c}_${param}"
               eval "param_value=\$$param_var"
               if [ -n "$param_value" ]
               then
                  if [ "$param" == "path" ]
                  then
                     path_value=$param_value
                  else
                     echo -n "$param" | tr '_' ' ' >> $smbconf
                     echo "=$param_value" >> $smbconf
                  fi
               fi
            done
            env -i $sudo "$SUDO_DIR/mkdir2root" "$path_value"
            echo "path=$path_value" >> $smbconf
         done
      fi
      env -i $sudo "$SUDO_DIR/addlinuxusers" $SHARE_USERS
      if [ ! -s $SMBPASSWD_FILE ]
      then
         for user in $SHARE_USERS
         do
            user_lc=$(echo $user | tr '[:upper:]' '[:lower:]')
            envvar="password_file_$user_lc"
            eval "userpwfile=\$$envvar"
            if [ -z $userpwfile ]
            then
               envvar="password_$user_lc"
               eval "user_pw=\$$envvar"
               if [ -n "$user_pw" ]
               then
                  userpwfile=$SECRET_DIR/$user"_pw"
                  eval "echo \$$envvar > $userpwfile"
                  eval "unset $envvar"
               else
                  echo "No password given for $user."
                  exit 1
               fi
            fi
            env -i $sudo "$SUDO_DIR/addshareuser" "$user" "$userpwfile" "$CONFIG_DIR/smbusers" $DELETE_PASSWORD_FILES
         done
      fi
      if [ ! -e "$USERNAME_MAP_FILE" ]
      then
         username_dir="$(dirname "$USERNAME_MAP_FILE")"
         /bin/mkdir -p "$username_dir"
         >"$USERNAME_MAP_FILE"
         for user in $USERNAME_MAP
         do
            echo "$user" >> "$USERNAME_MAP_FILE"
         done
         env -i $sudo "$SUDO_DIR/chown2root" -R "$username_dir"
      fi
      env -i $sudo "$SUDO_DIR/chown2root" -R "$SECRET_DIR"
      env -i $sudo "$SUDO_DIR/chown2root" -R "$CONFIG_DIR"
      env -i $sudo "$SUDO_DIR/chown2root" "$SHARES_DIR"
   fi
fi
exec env -i "$BIN_DIR/runsmbd" "$SUDO_DIR"
exit 0
