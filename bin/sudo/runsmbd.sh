#!/bin/sh
set -e
set +a
set +m
set +s
set +i

readonly PATH=""
readonly SUDO_DIR="`/usr/bin/dirname $0`"
readonly ENVIRONMENT_FILE="$SUDO_DIR/environment"
if [ -f "$ENVIRONMENT_FILE" ]
then
   IFS=$(echo -en "\n\b,")
   environment=`/bin/cat "$ENVIRONMENT_FILE" | /usr/bin/tr -dc '[:alnum:]_ %.=/\n'`
   /bin/rm "$ENVIRONMENT_FILE"
   var(){
      IFS_bak=$IFS
      IFS=?
      if [ "$1" == "-" ]
      then
         tmp="$environment"
      else
         tmp="$(echo $environment | /usr/bin/awk -v section=$1 -F_ '$1==section{s= ""; for (i=2; i < NF; i++) s = s $i "_"; print s $NF}')"
      fi
      if [ -z "$2" ]
      then
         echo "$(echo $tmp | /usr/bin/awk -F= '{print $1}')"
      else
         echo "$(echo $tmp | /usr/bin/awk -v param=$2 -F= '$1==param{print $2}')"
      fi
      IFS=$IFS_bak
   }
   readonly CONFIG_FILE="`var - CONFIG_FILE`"
   readonly SHARES_DIR="`var - SHARES_DIR`"
   /bin/mkdir -p "$SHARES_DIR"
   set +e
   /bin/chown root "$SHARES_DIR"
   /bin/chmod u=rwx,go=x "$SHARES_DIR"
   set -e
   if [ ! -s "$CONFIG_FILE" ]
   then
      readonly global_smb_passwd_file="`var global smb_passwd_file`"
      readonly environment=$environment$'\n'"global_passdb_backend=smbpasswd:$global_smb_passwd_file"
      readonly SHARES="global"$'\n'"`var - SHARES`"
      for share in $SHARES
      do
         echo >> "$CONFIG_FILE"
         echo "[$share]" >> "$CONFIG_FILE"
         share_lc="$(echo $share | /usr/bin/xargs /bin/echo | /usr/bin/tr '[:upper:]' '[:lower:]')"
         share_parameters="`var $share`"
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
                  echo -n "$param" | /usr/bin/tr '_' ' ' >> "$CONFIG_FILE"
                  echo "=$param_value" >> "$CONFIG_FILE"
               fi
            fi
         done
         if [ "$share" != "global" ]
         then
            /bin/mkdir -p "$path_value"
            echo "path=$path_value" >> "$CONFIG_FILE"
         fi
      done
   else
      readonly environment
      readonly global_smb_passwd_file="$(echo "$(/bin/cat "$CONFIG_FILE" | /usr/bin/awk -v param="smb passwd file" -F= '$1==param{print $2}')")"
      readonly share_paths="`/bin/cat "$CONFIG_FILE" | /bin/grep 'path=' | /usr/bin/awk -F= '{print $2}'`"
      for path in $share_paths
      do
         /bin/mkdir -p "$path"
      done
   fi
   /bin/mkdir -p "$(/usr/bin/dirname "$global_smb_passwd_file")"
   set +e
   /bin/touch "$global_smb_passwd_file"
   /bin/chown root "$global_smb_passwd_file"
   /bin/chmod u=rw,go= "$global_smb_passwd_file"
   set -e
   readonly SHARE_USERS="`var - SHARE_USERS`"
   readonly SMBUSERS_FILE="`var - SMBUSERS_FILE`"
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
         user_lc=$(echo $user | /usr/bin/xargs /bin/echo | /usr/bin/tr '[:upper:]' '[:lower:]')
         userpwfile="`var - password_file_$user_lc`"
         if [ -z "$userpwfile" ]
         then
            userpwfile=$CONFIG_DIR/$user"_pw"
         fi
         /bin/mkdir -p "$(/usr/bin/dirname "$userpwfile")"
         set +e
         /bin/touch "$userpwfile"
         /bin/chown root "$userpwfile"
         /bin/chmod u=rw,go= "$userpwfile"
         set -e
         if [ ! -s "$userpwfile" ]
         then
            user_pw="`var password $user_lc`"
            if [ -n "$user_pw" ]
            then
               echo $user_pw > "$userpwfile"
               unset user_pw
            else
               echo "No password given for $user."
               exit 1
            fi
         fi
         echo | /bin/cat "$userpwfile" - "$userpwfile" | "$SUDO_DIR/smbpasswd" -s -a "$user"
         set +e
         /bin/rm -f "$userpwfile"
         set -e
         echo "$user = $user" >> "$SMBUSERS_FILE"
      done
   fi
   readonly global_username_map="`var - global_username_map`"
   if [ -n "$global_username_map" ] 
   then
      /bin/mkdir -p "$(/usr/bin/dirname "$global_username_map")"
      set +e
      /bin/touch "$global_username_map"
      /bin/chown root "$global_username_map"
      /bin/chmod u=rw,go= "$global_username_map"
      set -e
      if [ ! -s "$global_username_map" ]
      then
         readonly USERNAME_MAP="`var - USERNAME_MAP`"
         for user in $USERNAME_MAP
         do
            echo "$user" >> "$global_username_map"
         done
      fi
   fi
   if [ -n "$global_log_file" ] 
   then
      /bin/mkdir -p "$(/usr/bin/dirname "$global_log_file")"
      set +e
      /bin/touch "$global_log_file"
      /bin/chown root "$global_log_file"
      /bin/chmod u=rw,go= "$global_log_file"
      set -e
   fi
fi
/usr/bin/sudo /usr/sbin/nmbd -D
/usr/bin/sudo /usr/sbin/smbd -FS
exit 0
