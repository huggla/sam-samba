# samba-alpine
A secure and minimal docker image with Samba server (share) on Alpine.

## Environment variables
### pre-set variables (can be set at runtime)
* SHARES_DIR (/shares): Root directory for shares.
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
* SHARE_USERS (shareuser)
* DELETE_PASSWORD_FILES (no)

### Mandatory runtime variables
* 

### Optional runtime variables
* 

## Volumes
* 

## Capabilities
### Can drop
