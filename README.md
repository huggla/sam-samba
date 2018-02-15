# samba-alpine
A secure and minimal docker image with Samba server (share) on Alpine.

## Environment variables
### Pre-set variables (can be set at runtime)
* SHARES_DIR (/shares): Root directory for shares.
* SHARE_USERS (shareuser): Semi colon separated list of user names that should have access the the shares.
* DELETE_PASSWORD_FILES (no): A security feature that deletes mounted password files. NOTE! Take backup of passwords, you might loose the source file. Should be safe to use with secrets.
#### Default global configuration
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


### Mandatory runtime variables
* 

### Optional runtime variables
* 

## Volumes
* 

## Capabilities
### Can drop
