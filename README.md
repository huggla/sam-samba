# samba-alpine
A secure and minimal docker image with Samba server (share) on Alpine edge.

## Internal container ports (expose externally as 137, 139 and 445 if you wish)
* UDP 1370
* TCP 1390
* TCP 4450

## Pre-set environment variables (can be set at runtime)
* VAR_LINUX_USER (root)
* VAR_CONFIG_FILE (/etc/samba/smb.conf"
* VAR_FINAL_COMMAND (/usr/sbin/nmbd --daemon --log-stdout --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group && /usr/sbin/smbd --foreground --log-stdout --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group)
* VAR_SHARES_DIR (/shares): Root directory for shares.
* VAR_SHARE_USERS (shareuser): Comma separated list of user names that should have access the the shares.
* VAR_DEBUGLEVEL (1)

### Default global configuration
* VAR_global_smb_passwd_file (/etc/samba/smbpasswd): Encrypted passwords for all Samba users.
* VAR_global_dns_proxy (no)
* VAR_global_username_map (/etc/samba/usermap.txt)
* VAR_global_log_file (/var/log/samba/log.%m)
* VAR_global_max_log_size (0)
* VAR_global_panic_action (killall smbd)
* VAR_global_server_role (standalone)
* VAR_global_map_to_guest (bad user)
* VAR_global_load_printers (no)
* VAR_global_printing (bsd)
* VAR_global_printcap_name (/dev/null)
* VAR_global_disable_spoolss (yes)

## Runtime environment variables
* VAR_SHARES: Comma separated list of share names. Might also contain homes, printers.
### Global configuration
* VAR_global_&lt;parameter name with space replaced by underscore&gt;: f ex global_allow_nt4_crypto.
### Share configuration
* VAR_&lt;share name from SHARES&gt;_&lt;parameter name with space replaced by underscore&gt;: f ex public_guest_ok.
### User configuration
* VAR_password&#95;file_&lt;user name from USERS&gt;: Path to file containing password for named user.
* VAR_password_&lt;user name from USERS&gt;: Password for named user. Slightly less secure.

## Capabilities
Can drop all but CHOWN, SETPCAP, SETGID and SETUID.
