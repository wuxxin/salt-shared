#!/bin/bash

. /usr/local/share/appliance/env.functions.sh

prepare_extra_files () {
    # ### write out extra files from env
    if test "$APPLIANCE_EXTRA_FILES_LEN" != ""; then
        for i in $(seq 0 $(( $APPLIANCE_EXTRA_FILES_LEN -1 )) ); do
            fieldname="APPLIANCE_EXTRA_FILES_${i}_PATH"; fname="${!fieldname}"
            fieldname="APPLIANCE_EXTRA_FILES_${i}_OWNER"; fowner="${!fieldname}"
            fieldname="APPLIANCE_EXTRA_FILES_${i}_PERMISSIONS"; fperm="${!fieldname}"
            fieldname="APPLIANCE_EXTRA_FILES_${i}_CONTENT"; fcontent="${!fieldname}"
            echo "$fcontent" > $fname
            if test "$fowner" != ""; then chown $fowner $fname; fi
            if test "$fperm" != ""; then chmod $fperm $fname; fi
        done
    fi
}

prepare_extra_packages () {
    # ### check and install additional packages
    if test "$APPLIANCE_EXTRA_PACKAGES_LEN" != ""; then
        for i in $(seq 0 $(( $APPLIANCE_EXTRA_PACKAGES_LEN -1 )) ); do
            fieldname="APPLIANCE_EXTRA_PACKAGES_${i}"; pkgname="${!fieldname}"
            dpkg-query -W -f='${Status}\n' $pkgname | head -n1 | awk '{print $3;}' | grep -q '^installed$'
            if test $? -ne 0; then
                echo "Information: Package $pkgname is not installed, installing"
                DEBIAN_FRONTEND=noninteractive apt-get install -y $pkgname
                if test $? -ne 0; then
                    echo "Error: Package $pkgname could not be installed"
                    exit 1
                fi
            fi
        done
    fi
}

userdata_to_env appliance || exit $?
prepare_extra_files
prepare_extra_packages
