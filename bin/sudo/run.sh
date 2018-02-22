#!/bin/sh
set -e

environment_file="/etc/samba/environment"
if [ -f "$environment_file" ]
then
   IFS=";"
   environment=`cat "$environment_file" | /usr/bin/tr -dc '[:alnum:]_ =/\n'`
   rm "$environment_file"
   var(){
      if [ "$1" == "-" ]
      then
         tmp="$environment"
      else
         tmp="$(echo $environment | awk -v section=$1 -F_ '$1==section{s= ""; for (i=2; i < NF; i++) s = s $i "_"; print s $NF}')"
      fi
      if [ "$2" == "*" ]
      then
         echo "$tmp"
      else
         echo "$(echo $tmp | awk -v param=$2 -F= '$1==param{print $2}')"
      fi
   }
   global_smb_passwd_file="`var global smb_passwd_file`"
   smbpasswd_dir="$(dirname "$global_smb_passwd_file")"
   mkdir -p "$smbpasswd_dir"
   chmod u=rwx,go= "$smbpasswd_dir"
   touch "$global_smb_passwd_file"
   chmod u=rwx,go= "$global_smb_passwd_file"
   $environment=$environment$'\n'"global_passdb_backend=smbpasswd:$global_smb_passwd_file"
   CONFIG_FILE="`var - CONFIG_FILE`"
   if [ ! -s "$CONFIG_FILE" ]
   then
      SHARES="global;`var - SHARES`"
      for share in $SHARES
      do
         echo >> "$CONFIG_FILE"
         echo "[$share]" >> "$CONFIG_FILE"
         share_lc="$(echo $share | xargs | tr '[:upper:]' '[:lower:]')"
         share_parameters="`var $share *`"
         SHARES_DIR="`var - SHARES_DIR`"
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
                  echo -n "$param" | tr '_' ' ' >> "$CONFIG_FILE"
                  echo "=$param_value" >> "$CONFIG_FILE"
               fi
            fi
         done
         mkdir -p "$path_value"
         echo "path=$path_value" >> "$CONFIG_FILE"
      done
   fi
   cat "$CONFIG_FILE"
   SHARE_USERS="`var - SHARE_USERS`"
   for user in $SHARE_USERS
   do
      if [ ! "`/usr/bin/id $user 2>/dev/null`" ]
      then
         /usr/sbin/adduser -D -H -s /bin/false "$user"
      fi
   done
fi
#exec env -i "$BIN_DIR/runsmbd" "$SUDO_DIR"
exit 0
