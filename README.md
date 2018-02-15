# samba-alpine
A secure and minimal docker image with Samba server (share) on Alpine. Runs by default as non-privileged user.

## Container ports (expose if you wich)
* UDP 137
* UDP 138
* TCP 139
* TCP 445

## Pre-set environment variables (can be set at runtime)
* SHARES_DIR (/shares): Root directory for shares.
* SHARE_USERS (shareuser): Semi colon separated list of user names that should have access the the shares.
* DELETE_PASSWORD_FILES (no): A security feature that deletes mounted password files. NOTE! Take backup of passwords, you might loose the source file. Should be safe to use with secrets.
### Default global configuration
* global_smb_passwd_file (/shares/smbpasswd): Encrypted passwords for all Samba users.
* global_dns_proxy (no)
* global_log_file (/var/log/samba/log.%m)
* global_max_log_size (0)
* global_syslog (0)
* global_panic_action (killall smbd)
* global_server_role (standalone)
* global_map_to_guest (bad user)
* global_load_printers (no)
* global_printing (bsd)
* global_printcap_name (/dev/null)
* global_disable_spoolss (yes)

## Runtime environment variables
* SHARES: Semi colon separated list of share names. Might also contain homes, printers.
### Global configuration
* global_\<parameter name with space replaced by underscore\>: f ex global_allow_nt4_crypto.
### Share configuration
* \<share name from SHARES\>_\<parameter name with space replaced by underscore\>: f ex public_guest_ok.
### User configuration
* password_file_\<user name from USERS\>: Path to file containing password for named user.
* password_\<user name from USERS\>: Password for named user. Less secure!

## Capabilities
### Can drop
* All but CHOWN, DAC_OVERRIDE, NET_BIND_SERVICE, SETGID and SETUID.
