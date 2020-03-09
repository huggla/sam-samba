# sam-samba
A secure and minimal docker image with Samba server (share) on Alpine edge. Runs as non-privileged user.

## Default internal container ports (expose externally as 445 if you wish)
* UDP 4450 (VAR_NMBD_PORT)
* TCP 4450 (VAR_SMBD_PORTS)

## Pre-set environment variables (can be set at runtime)
* VAR_LINUX_USER (root)
* VAR_CONFIG_FILE (/etc/samba/smb.conf)
* VAR_FINAL_COMMAND (nmbd --daemon -p \$VAR_NMBD_PORT --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group && smbd -p \$VAR_SMBD_PORTS --foreground --log-stdout --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group)
* VAR_SHARES_DIR (/shares): Root directory for shares.
* VAR_SHARE_USERS (shareuser): Comma separated list of user names that should have access the the shares.
* VAR_DEBUGLEVEL (1)
* VAR_NMBD_PORT (4450)
* VAR_SMBD_PORTS (4450)

### Default global configuration
* VAR_global_smb_passwd_file (/etc/samba/smbpasswd): Encrypted passwords for all Samba users.
* VAR_global_dns_proxy (no)
* VAR_global_username_map (/etc/samba/usermap.txt)
* VAR_global_log_file (/var/log/samba/log.%m)
* VAR_global_max_log_size (0)
* VAR_global_panic_action (killall nmdb smbd)
* VAR_global_server_role (standalone)
* VAR_global_map_to_guest (bad user)
* VAR_global_load_printers (no)
* VAR_global_printing (bsd)
* VAR_global_printcap_name (/dev/null)
* VAR_global_disable_spoolss (yes)
* VAR_global_disable_netbios (yes)
* VAR_global_smb_encrypt (desired)
* VAR_global_lanman_auth (no)

## Runtime environment variables
* VAR_SHARES: Comma separated list of share names. Might also contain homes, printers.
### Global configuration
* VAR_global_&lt;parameter name with space replaced by underscore&gt;: f ex global_allow_nt4_crypto.
### Share configuration
* VAR_&lt;share name from SHARES&gt;_&lt;parameter name with space replaced by underscore&gt;: f ex public_guest_ok.
### User configuration
* VAR_password&#95;file_&lt;user name from USERS&gt;: Path to file containing password for named user.
* VAR_password_&lt;user name from USERS&gt;: Password for named user. Slightly less secure.

## Runtime environment example (recommended)
* VAR_SHARE_USERS=user1
* VAR_password_user1=1goodPa$$word
* VAR_SHARES=user1share
* VAR_user1share_browsable=yes
* VAR_user1share_guest_ok=no
* VAR_user1share_read_only=yes
* VAR_user1share_write_list=user1
* VAR_user1share_create_mask=0660
* VAR_user1share_directory_mask=0770

## Capabilities
Can drop all but CHOWN, SETPCAP, SETGID and SETUID.

## Note!
Connecting from Windows 10 can be tricky. Make sure smb support is turned on, then use the "map to drive letter" tool. An alternative to guest shares (which by default doesn't work on Windows 10) is to create a shortcut with the following target:
>cmd /c net use &#92;\\&lt;host&gt;\&lt;share&gt; /user:&lt;username&gt; &lt;password&gt; /savecred /persistent:yes & start \\&lt;host&gt;\&lt;share&gt;
