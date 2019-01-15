# samba-alpine
A secure and minimal docker image with Samba server (share) on Alpine.

## Container ports (expose if you wish)
* UDP 137
* UDP 138
* TCP 139
* TCP 445

## Pre-set environment variables (can be set at runtime)
* REV_SHARES_DIR (/shares): Root directory for shares.
* REV_SHARE_USERS (shareuser): Comma separated list of user names that should have access the the shares.
### Default global configuration
* REV_global_smb_passwd_file (/shares/smbpasswd): Encrypted passwords for all Samba users.
* REV_global_dns_proxy (no)
* REV_global_username_map (/etc/samba/usermap.txt)
* REV_global_log_file (/var/log/samba/log.%m)
* REV_global_max_log_size (0)
* REV_global_syslog (0)
* REV_global_panic_action (killall smbd)
* REV_global_server_role (standalone)
* REV_global_map_to_guest (bad user)
* REV_global_load_printers (no)
* REV_global_printing (bsd)
* REV_global_printcap_name (/dev/null)
* REV_global_disable_spoolss (yes)

## Runtime environment variables
* REV_SHARES: Comma separated list of share names. Might also contain homes, printers.
### Global configuration
* REV_global_&lt;parameter name with space replaced by underscore&gt;: f ex global_allow_nt4_crypto.
### Share configuration
* REV_&lt;share name from SHARES&gt;_&lt;parameter name with space replaced by underscore&gt;: f ex public_guest_ok.
### User configuration
* REV_password&#95;file_&lt;user name from USERS&gt;: Path to file containing password for named user. **Note! This file will be deleted unless write protected.**
* REV_password_&lt;user name from USERS&gt;: Password for named user. Slightly less secure.

## Capabilities
Can drop all but CHOWN, DAC_OVERRIDE, NET_BIND_SERVICE, SETGID and SETUID.
