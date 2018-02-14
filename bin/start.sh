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
   env -i $sudo "$SUDO_DIR/mkdir2root" "$(dirname "$global_smb_passwd_file")"
   global_passdb_backend="smbpasswd:$global_smb_passwd_file"
   if [ -z "$global_username_map" ]
   then
      global_username_map="$CONFIG_DIR/usermap.txt"
   fi
   if [ ! -e "$smbconf" ]
   then
      SHARES="global;$SHARES"
      for share in $SHARES
      do
         echo >> $smbconf
         echo "[$share]" >> $smbconf
         share_lc="$(echo $share | xargs | tr '[:upper:]' '[:lower:]')"
         echo $share_lc
         share_parameters=`env | /bin/grep "${share_lc}_" | /bin/sed "s/^${share_lc}_//g" | /bin/grep -oE '^[^=]+'`
         echo $share_parameters
         path_value="$SHARES_DIR/$share"
         for param in $share_parameters
         do
            param_var="${share_lc}_${param}"
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
      env -i $sudo "$SUDO_DIR/addlinuxusers" $SHARE_USERS
      if [ ! -s $global_smb_passwd_file ]
      then
         for user in $SHARE_USERS
         do
            user_lc=$(echo $user | xargs | tr '[:upper:]' '[:lower:]')
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
      if [ ! -e "$global_username_map" ]
      then
         username_dir="$(dirname "$global_username_map")"
         /bin/mkdir -p "$username_dir"
         >"$global_username_map"
         for user in $USERNAME_MAP
         do
            echo "$user" >> "$global_username_map"
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
