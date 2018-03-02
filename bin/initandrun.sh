#!/bin/sh
set -e +a +m +s +i -f

readonly BIN_DIR="$(/usr/bin/dirname $0)"
. "$(/usr/bin/dirname "$0")/shellfunctions

env_list="$(listfromfile "$BIN_DIR/buildtime_environment")"
#setvarsfromlist "$env_list"
makealloftypefromlist "dir" "$env_list"
makealloftypefromlist "file" "$env_list"


???readonly SUDOERS_FILE="$(var - SUDOERS_FILE)"???
???readonly USER="$(var - USER)"???

readonly RUNTIME_ENVIRONMENT="$BIN_DIR/runtime_environment"
if [ -f "$RUNTIME_ENVIRONMENT" ]
then
   readonly env_list="$env_list""$(listfromfile "$BIN_DIR/buildtime_environment")"
   #setvarsfromlist "$env_list"
   makealloftypefromlist "dir" "$env_list"
   makealloftypefromlist "file" "$env_list"
   
   ???IFS=$(echo -en "\n\b,")???
   
   /bin/rm "$RUNTIME_ENVIRONMENT"

# Image-specific code
# --------------------------------------------
   CONFIG_FILE="$(var - CONFIG_FILE)"
   if [ ! -s "$CONFIG_FILE" ]
   then
      readonly global_smb_passwd_file="$(var global smb_passwd_file)"
      readonly global_passdb_backend="smbpasswd:$global_smb_passwd_file"
      readonly SHARES="global"$'\n'"$(var - SHARES)"
      readonly SHARES_DIR="$(var - SHARES_DIR)"
      for share in $SHARES
      do
         share="$(trim "$share")"
         share_lc="$(tolower "$share")"
         echo >> "$CONFIG_FILE"
         echo "[$share]" >> "$CONFIG_FILE"
         share_parameters="$(var $share_lc)"
         path_value="$SHARES_DIR/$share"
         for param in $share_parameters
         do
            param_value="$(var $share_lc $param)"
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
      readonly share_paths="$(/bin/cat "$CONFIG_FILE" | /bin/grep 'path=' | /usr/bin/awk -F= '{print $2}')"
      for path in $share_paths
      do
         /bin/mkdir -p "$path"
      done
   fi
   makefile "$global_smb_passwd_file"
   readonly SHARE_USERS="$(var - SHARE_USERS)"
   readonly SMBUSERS_FILE="$(var - SMBUSERS_FILE)"
   for user in $SHARE_USERS
   do
      user="$(trim "$user")"
      if [ ! "$(/usr/bin/id $user 2>/dev/null)" ]
      then
         /usr/sbin/adduser -D -H -s /bin/false "$user"
      fi
   done
   if [ ! -s "$global_smb_passwd_file" ]
   then
      for user in $SHARE_USERS
      do
         user="$(trim "$user")"
         user_lc="$(tolower "$user")"
         userpwfile="$(var - password_file_$user_lc)"
         if [ -z "$userpwfile" ]
         then
            userpwfile="$SUDOS_DIR/$user_lc"
         fi
         makefile "$userpwfile"
         if [ ! -s "$userpwfile" ]
         then
            user_pw="$(var - password_$user_lc)"
            if [ -n "$user_pw" ]
            then
               echo -n "$user_pw" > $userpwfile
               unset user_pw
            else
               echo "No password given for $user."
               exit 1
            fi
         fi
         echo | /bin/cat "$userpwfile" - "$userpwfile" | "$SUDOS_DIR/smbpasswd" -s -a "$user"
         set +e
         /bin/rm -f "$userpwfile"
         set -e
         echo "$user = $user" >> "$SMBUSERS_FILE"
      done
   fi
   readonly global_username_map="$(var - global_username_map)"
   if [ -n "$global_username_map" ] 
   then
      makefile "$global_username_map"
      if [ ! -s "$global_username_map" ]
      then
         readonly USERNAME_MAP="$(var - USERNAME_MAP)"
         for user in $USERNAME_MAP
         do
            user="$(trim "$user")"
            echo "$user" >> "$global_username_map"
         done
      fi
   fi
   readonly global_log_file="$(var - global_log_file)"
   if [ -n "$global_log_file" ] 
   then
      makefile "$global_log_file"
   fi
fi
/usr/bin/env -i "$BIN_DIR/sudo" /usr/sbin/nmbd -D
exec /usr/bin/env -i "$BIN_DIR/sudo" /usr/sbin/smbd -FS
