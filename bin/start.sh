#!/bin/sh
set -e

smbconf="/etc/samba/smb.conf"
if [ ! -e $smbconf ]
then
   echo "[global]" >> $smbconf
   echo "dns proxy=$DNS_PROXY" >> $smbconf
   echo "passdb backend=$PASSDB_BACKEND" >> $smbconf
   echo "log file=$LOG_FILE" >> $smbconf
   echo "max log size=$MAX_LOG_SIZE" >> $smbconf
   echo "syslog=$SYSLOG" >> $smbconf
   echo "panic action=$PANIC_ACTION" >> $smbconf
   echo "server role=$SERVER_ROLE" >> $smbconf
   echo "map to guest=$MAP_TO_GUEST" >> $smbconf
   echo "load printers=$LOAD_PRINTERS" >> $smbconf
   echo "printing=$PRINTING" >> $smbconf
   echo "printcap name=$PRINTCAP_NAME" >> $smbconf
   echo "disable spoolss=$DISABLE_SPOOLSS" >> $smbconf
   IFS=";"
   for conf in $ADDITIONAL_CONFIGURATION
   do
      echo "$conf" >> $smbconf
   done
fi

nmbd -D && smbd -FS
exit 0
