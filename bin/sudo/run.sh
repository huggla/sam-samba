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
   $environment=`printf "$environment\nglobal_passdb_backend=smbpasswd:$global_smb_passwd_file"`
echo $environment
fi
#exec env -i "$BIN_DIR/runsmbd" "$SUDO_DIR"
exit 0
