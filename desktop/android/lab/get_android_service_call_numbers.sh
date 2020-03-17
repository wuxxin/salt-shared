#!/bin/bash

ADBShell () { adb ${2+-s }$2 shell "$1" | tr -d '\r'
}

GetAndroidVersion () {
    local ALL_TAGS=$(wget -qO - "$GOOGLE_SOURCE/$REPO/+refs/tags/?format=text" | \
    tr -d '^{}' | cut -d/ -f3 | sort -u | grep -vE -- '-(cts|sdk)-' | grep -v "_r0")
    TAG=${1:-$(ADBShell 'getprop ro.build.version.release')}
    echo -e "ANDROID_SERIAL=$ANDROID_SERIAL\nro.build.version.release=$TAG" 1>&2
    TAG=$(echo "$ALL_TAGS" | grep -- "android-${TAG//./\.}" | head -n 1)
    echo -e "TAG=$TAG" 1>&2
    [ "-$TAG" != "-"  ] && return 0
    echo -e "TAG not valid!\n\nList of valid tags: "$ALL_TAGS 1>&2
    exit 1
}

GetServicePackageName () {
    SERVICE_PACKAGE=$(ADBShell 'service list' | grep "\s$1: \[" | head -n 1 | tr '[]' '""' | cut -d\" -f2)
    echo -e "SERVICE=$1\nSERVICE_PACKAGE=$SERVICE_PACKAGE" 1>&2
}

GetGoogleSourceFile () {
    #echo -e "\t\E[31mdownloading\E[0m $GOOGLE_SOURCE/$REPO/+/$1/$2" 1>&2
    [ "-$1" == "-" ] && return 1
    wget -qO - "$GOOGLE_SOURCE/$REPO/+/$1/$2?format=text" | base64 -d
}

GetAllServices () {
    ALL_SERVICES=$(GetGoogleSourceFile "$TAG" "Android.mk" | tr -d ' \\\t' | grep "\.aidl$" | \
    sort -u | grep -v "^gen:")
}

ParseServiceAIDL () {
    GetGoogleSourceFile "$TAG" $(echo "$ALL_SERVICES" | grep "${SERVICE_PACKAGE//.//}\.aidl$" | head -n 1) | \
    gcc -P -E - | tr '{};\n\r' '\n\n\n  ' | grep -v ^$ | sed -e '1,/interface\s/ d' | cat -n
}

AbortIfExecutableMissing () {
    BIN=($@)
    MISSINGBIN=$(for B in ${BIN[@]}; do [ "$(which $B 2>/dev/null)-" == "-" ] && echo $B; done)
    [ "${MISSINGBIN}-" == "-" ] && return 0
    echo -e "Can't find the following executables: "$MISSINGBIN
    exit 1
}

AbortIfExecutableMissing "adb wget gcc tr sed awk cut grep basename dirname head base64"

GOOGLE_SOURCE="https://android.googlesource.com"
REPO="platform/frameworks/base"

GetAndroidVersion
GetAllServices
GetServicePackageName $1

ParseServiceAIDL

exit 0
