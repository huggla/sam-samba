#!/bin/sh
set -e
set +a
set +m
set +s
set +i

SUDO_DIR="`dirname $0`"
ENVIRONMENT_FILE="$SUDO_DIR/environment"
if [ -f "$ENVIRONMENT_FILE" ]
then
   environment=`cat "$ENVIRONMENT_FILE" | /usr/bin/tr -dc '[:alnum:]_ %.=/\n'`
   rm "$ENVIRONMENT_FILE"
   var(){
      IFS_bak=$IFS
      IFS=?
      if [ "$1" == "-" ]
      then
         tmp="$environment"
      else
         tmp="$(echo $environment | awk -v section=$1 -F_ '$1==section{s= ""; for (i=2; i < NF; i++) s = s $i "_"; print s $NF}')"
      fi
      if [ -z "$2" ]
      then
         echo "$(echo $tmp | awk -F= '{print $1}')"
      else
         echo "$(echo $tmp | awk -v param=$2 -F= '$1==param{print $2}')"
      fi
      IFS=$IFS_bak
   }
   CONFIG_FILE="`var - CONFIG_FILE`"
   if [ ! -s "$CONFIG_FILE" ]
   then
      global_smb_passwd_file="`var global smb_passwd_file`"
      environment=$environment$'\n'"global_passdb_backend=smbpasswd:$global_smb_passwd_file"
      SHARES="global"$'\n'"`var - SHARES`"
      for share in $SHARES
      do
         echo >> "$CONFIG_FILE"
         echo "[$share]" >> "$CONFIG_FILE"
         share_lc="$(echo $share | xargs | tr '[:upper:]' '[:lower:]')"
         share_parameters="`var $share`"
         SHARES_DIR="`var - SHARES_DIR`"
         path_value="$SHARES_DIR/$share"
         for param in $share_parameters
         do
            param_value="`var $share_lc $param`"
            if [ -n "$param_value" ]
            then
               if [ "$param" == "path" ]
               then
                  path_value=$param_value
               else
                  echo -n "$param" | tr '_' ' ' >> "$CONFIG_FILE"
                  echo "=$param_value" >> "$CONFIG_FILE"
               fi
            fi
         done
         mkdir -p "$path_value"
         echo "path=$path_value" >> "$CONFIG_FILE"
      done
   else
      global_smb_passwd_file="$(echo "$(cat "$CONFIG_FILE" | awk -v param="smb passwd file" -F= '$1==param{print $2}')")"
   fi
   smbpasswd_dir="$(dirname "$global_smb_passwd_file")"
   mkdir -p "$smbpasswd_dir"
   chmod u=rwx,go= "$smbpasswd_dir"
   touch "$global_smb_passwd_file"
   chmod u=rw,go= "$global_smb_passwd_file"
   SHARE_USERS="`var - SHARE_USERS`"
   SMBUSERS_FILE="`var - SMBUSERS_FILE`"
   chmod u=rw,go= "$SMBUSERS_FILE"
   for user in $SHARE_USERS
   do
      if [ ! "`/usr/bin/id $user 2>/dev/null`" ]
      then
         /usr/sbin/adduser -D -H -s /bin/false "$user"
      fi
   done
   if [ ! -s "$global_smb_passwd_file" ]
   then
      for user in $SHARE_USERS
      do
         user_lc=$(echo $user | xargs | tr '[:upper:]' '[:lower:]')
         userpwfile="`var - password_file_$user_lc`"
         if [ -n "$userpwfile" ]
         then
            chmod u=r,go= "$userpwfile"
         else
            user_pw="`var password $user_lc`"
            if [ -n "$user_pw" ]
            then
               userpwfile=$CONFIG_DIR/$user"_pw"
               chmod u=r,go= "$userpwfile"
               echo $user_pw > "$userpwfile"
               unset user_pw
            else
               echo "No password given for $user."
               exit 1
            fi
         fi
         echo | /bin/cat "$userpwfile" - "$userpwfile" | "`dirname $0`/smbpasswd" -s -a "$user"
         echo "$user = $user" >> "$SMBUSERS_FILE"
if [ "$4" == "yes" ]
then
   /bin/rm "$2"
fi
         env -i $sudo "$SUDO_DIR/addshareuser" "$user" "$userpwfile" "$SMBUSERS_FILE" $DELETE_PASSWORD_FILES
      done
   fi
   if [ -n "$global_username_map" ] 
   then
      if [ ! -e "$global_username_map" ]
      then
         username_dir="$(dirname "$global_username_map")"
         if [ ! -e "$username_dir" ]
         then
            /bin/mkdir -p "$username_dir"
         fi
         >"$global_username_map"
         for user in $USERNAME_MAP
         do
            echo "$user" >> "$global_username_map"
         done
      fi
      env -i $sudo "$SUDO_DIR/chown2root" "$global_username_map"
   fi
   env -i $sudo "$SUDO_DIR/chown2root" "$CONFIG_DIR"
   env -i $sudo "$SUDO_DIR/chown2root" "$SHARES_DIR"
fi
#exec env -i "$BIN_DIR/runsmbd" "$SUDO_DIR"
exit 0
