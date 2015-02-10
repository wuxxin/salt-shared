#!/bin/bash

if test "$3" == ""; then
  echo "Usage: $0 target master minion"
  exit 1
fi

target=$1
master=$2
minion=$3
installer="Salt-Minion-2014.7.2-AMD64-Setup.exe"

smbclient.py "$target" << EOF
use C\$
cd \\Windows\\temp
put /usr/local/share/windows/$installer
exit
EOF

smbexec.py -mode SHARE -share C\$ "$target" << EOF
del /F /Q C:\salt\conf\pki\minion\*
c:\\windows\\temp\\$installer /S /master=$master /minion-name=$minion
exit
EOF
