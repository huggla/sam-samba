#!/bin/sh
set -e

environment_file="/etc/samba/environment"
if [ -f "$environment_file" ]
then
   environment=`cat "$environment_file" | /usr/bin/tr -dc '[:alnum:]_=/\n'`
   rm "$environment_file"
   var(){
      if [ "$1" == "-" ]
      then
         tmp="$environment"
      else
         tmp="$(echo $environment | awk -v section=$1 -F_ '$1==section{print $2}')"
      fi
      if [ "$2" == "*" ]
      then
         return $tmp
      else
         return "$(echo $tmp | awk -v param=$2 -F= '$1==param{print $2}')"
      fi
   }
   IFS="${IFS};"
   global_smb_passwd_file="var global smb_passwd_file"
   smbpasswd_dir="$(dirname "$global_smb_passwd_file")"
   mkdir -p "$smbpasswd_dir"
   chmod u=rwx,go= "$smbpasswd_dir"
   touch "$global_smb_passwd_file"
   chmod u=rwx,go= "$global_smb_passwd_file"
   $environment="$environment`echo global_passdb_backend=smbpasswd:$global_smb_passwd_file`"
   CONFIG_FILE="var - CONFIG_FILE"
echo $CONFIG_FILE
fi
#exec env -i "$BIN_DIR/runsmbd" "$SUDO_DIR"
exit 0
