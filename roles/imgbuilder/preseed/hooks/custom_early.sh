#!/bin/sh

cmd="$1"

if test "$cmd" = "copy" -o "$cmd" = "fetch"; then
    # phase 0
    # earliest hook
    logger -t custom_early.sh "begin custom_early.sh"
    shift

    if test -f /reboot.seconds -a -f /watch; then
        # if activated: watch daemon that reboots the system after reboot.seconds,
        # must be killed by hand if activated
        logger -t custom_early.sh "activated automatic reboot in `cat /reboot.seconds` seconds"
        chmod 0755 /watch
        /watch `cat /reboot.seconds` < /dev/null &>/dev/null &
    fi

    if test "$cmd" = "fetch"; then
        logger -t custom_early.sh "fetch custom.lst and all files included in it"
        preseed_fetch /custom/custom.lst /tmp/mycustom.lst
        for a in `cat /tmp/mycustom.lst`; do
            preseed_fetch /custom/$a /tmp/`basename $a`
        done
    else
        cp /custom/* /tmp/
    fi
    chmod 755 /tmp/custom*

    # write all parameter to /tmp/custom.env
    if test "$#" -ne 0; then
        logger -t custom_early.sh "write /tmp/custom.env with startup parameter of custom_early.sh"
        while test "$#" -ne 0; do
            echo "$1" >> /tmp/custom.env
            shift
        done
    fi

    anna-install parted-udeb
    logger -t custom_early.sh "add hooks (custom_early.sh installer) to download-installer and load-cdrom postinst"
    echo /tmp/custom_early.sh installer >> /var/lib/dpkg/info/download-installer.postinst
    echo /tmp/custom_early.sh installer >> /var/lib/dpkg/info/load-cdrom.postinst

elif test "$cmd" = "installer"; then
    # phase 1
    # runs in addition to download-installer.postinst
    # we should have d-i downloaded by now
    # partman comes in a udeb from the network so we have to hook here
    # and replace the partman-base.postinst file
    sed -i 's/partman/\/tmp\/custom_early.sh partman/' /var/lib/dpkg/info/partman-base.postinst
    logger -t custom_early.sh modified partman-base.postinst

    # execute /tmp/custom_early*installer_hook
    for a in `ls /tmp/custom_early*installer_hook | sort -n`; do
        logger -t custom_installer_hook $a
        log-output -t custom_installer_hook sh $a
    done

elif test "$cmd" = "partman"; then
    # phase 2
    # replaces calling of partman
    # do filesystem stuff: detect our config, fdisk, lvms, mount /target
    logger -t custom_early.sh partition configuration starting

    # execute /tmp/custom_early*partman_hook
    for a in `ls /tmp/custom_early*partman_hook | sort -n`; do
        logger -t custom_partman_hook $a
        log-output -t custom_partman_hook sh $a
    done

fi
