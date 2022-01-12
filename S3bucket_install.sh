#!/bin/bash

echo "Author:	Abdullah Manzoor"
echo "Email: 	abdullah.itdeft@gmail.com"

yum install python-dateutil python-dateutil python-magic -y
if [ $? == 0 ]; then
sudo yum install python-pip -y
else
echo "package installation error"
fi
if [ $? == 0 ]; then
sudo pip install s3cmd
else
echo "package installation error"
fi

if [ $? == 0 ]; then
touch /var/local/backup.php
touch /var/log/Intelli_Backup.log
mkdir -p /usr/local/backups/file_backups
echo "Directories and file has been created" 
else
echo "package installation error"
fi

if [ $? == 0 ]; then
touch /root/.s3cfg
echo "[default]
access_key = {ACCESS_KEY}
access_token = 
add_encoding_exts = 
add_headers = 
bucket_location = US
ca_certs_file = 
cache_file = 
check_ssl_certificate = True
check_ssl_hostname = True
cloudfront_host = cloudfront.amazonaws.com
content_disposition = 
content_type = 
default_mime_type = binary/octet-stream
delay_updates = False
delete_after = False
delete_after_fetch = False
delete_removed = False
dry_run = False
enable_multipart = True
encrypt = False
expiry_date = 
expiry_days = 
expiry_prefix = 
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = C0nt3gr!$
guess_mime_type = True
host_base = ams3.digitaloceanspaces.com
host_bucket = %(bucket)s.ams3.digitaloceanspaces.com
human_readable_sizes = False
invalidate_default_index_on_cf = False
invalidate_default_index_root_on_cf = True
invalidate_on_cf = False
kms_key = 
limit = -1
limitrate = 0
list_md5 = False
log_target_prefix = 
long_listing = False
max_delete = -1
mime_type = 
multipart_chunk_size_mb = 15
multipart_max_chunks = 10000
preserve_attrs = True
progress_meter = True
proxy_host = 
proxy_port = 0
put_continue = False
recursive = False
recv_chunk = 65536
reduced_redundancy = False
requester_pays = False
restore_days = 1
restore_priority = Standard
secret_key = {SECRET_KEY}
send_chunk = 65536
server_side_encryption = False
signature_v2 = False
signurl_use_https = False
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 300
stats = False
stop_on_error = False
storage_class = 
throttle_max = 100
upload_id = 
urlencoding_mode = normal
use_http_expect = False
use_https = True
use_mime_magic = True
verbosity = WARNING
website_endpoint = http://%(bucket)s.s3-website-%(location)s.amazonaws.com/
website_error = 
website_index = index.html" > /root/.s3cfg
clear
echo "############################   Installed successfull   ############################"
echo "Add cron Job with the help of (crontab -e) 0 0 * * * /usr/bin/php /var/local/backup.php >> /var/log/Intelli_Backup.log"
echo "Putt the password in /var/local/backup.php file"
echo "Run the following command and check the directory on s3bucket for remote directory with the help of this command (s3cmd ls s3://cnt-backups/Backups/)"
echo "Copy the path against the client and putt this path in /var/local/backup.php in remotedir"
else
echo "package installation error"
fi
