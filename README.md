# backup-script

Backup a list of paths to a server as compressed archive file.

## Usage

Define config parameters in `backup.conf` like this:
```conf
REMOTE_USER=username
REMOTE_HOST=example.com
REMOTE_PATH=private/backups
TMP_BACKUP_PATH_WITH_FILE_PREFIX=/tmp/my_backup-
MAX_BACKUPS=7
```

Define backup paths in `paths.txt` like this:
```
/etc/letsencrypt
/etc/rc.local
/etc/samba
...
```
