# make sure if recordfail has some issue, do not wait endless
echo "GRUB_RECORDFAIL_TIMEOUT=5" >> /etc/default/grub

# update/compile settings
update-grub

