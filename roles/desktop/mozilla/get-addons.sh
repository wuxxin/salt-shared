if test "$1" != "firefox" -a "$1" != "thunderbird"; then
    cat <<EOF
Usage:
  $0 {firefox|thunderbird} exported-extension-list-file
EOF
    exit 1
fi

baseurl="https://versioncheck.addons.mozilla.org/update/VersionCheck.php?reqVersion=2"
thunderbird="&appID={3550f703-e582-4d05-9a08-453d09bdfdc6}&appVersion=24.5.0&appOS=Linux&appABI=x86_64-gcc3&locale=de-AT&currentappVersion=24.5.0"
firefox="&appID={ec8030f7-c20a-464f-9b0e-13a3a9e97384}&appVersion=29.0&appOS=Linux&appABI=x86_64-gcc3&locale=de-AT&currentappVersion=29.0"
# &updateType=97&compatMode=normal

if test "$1" == "firefox"; then
    appid=$firefox
else
    appid=$thunderbird
fi

for uuid in `cat $2 | dos2unix | grep -v -- "- "| tr -d " \t"`; do
    echo "uuid: ${uuid}"
    updatelink="${baseurl}&id=${uuid}${firefox}"
    #echo "updatelink: $updatelink"
    rdf=`wget -O - --quiet "$updatelink"`
    #echo "rdf: $rdf"
    if test "$rdf" != ""; then
        pkg=`echo "$rdf" | xmlstarlet sel -t -v "//em:updateLink"`
        if test "$pkg" != ""; then
            echo "pkg: $pkg"
            wget --quiet "$pkg"
        else
            echo "not found pkg with uuid: $uuid"
        fi
    else
        echo "not found updatelink in rdf: $rdf"
    fi
done

