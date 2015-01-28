if type apt-get >/dev/null 2>&1; then
    echo "grub modifications (debian)"
    # make sure if recordfail has some issue, do not wait endless
    mkdir -p /etc/default/grub.d
    echo "GRUB_RECORDFAIL_TIMEOUT=5" > /etc/default/grub.d/record_fail.cfg

    # update/compile settings
    update-grub
fi

