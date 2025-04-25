#!/bin/bash

SELF_AVDID="$(basename $0)"
SELF_AVDID="${SELF_AVDID%.sh}"
SELF_AVDCFG="$HOME/.android/avd/${SELF_AVDID}.ini"
ANDROID_EMULATOR_LAUNCHER_ARGS=""
export LC_ALL=C
export PATH="${PATH}:${ANDROID_HOME}/emulator"
export QT_QPA_PLATFORM="wayland;xcb"
export QT_LOGGING_RULES=default.warning=false
# ANDROID_EMULATOR_FEATURES=""
# LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64/qt/lib:$ANDROID_HOME/emulator/lib64/libstdc++:$ANDROID_HOME/emulator/lib64/gles_swiftshader:$ANDROID_HOME/emulator/lib64
# LD_PRELOAD=$ANDROID_HOME/emulator/lib64/qt/lib/libfreetype.so.6

usage() {
  cat <<EOF

Usage: $(basename $0) [-avd avdid] [\$EMULATOR_LAUNCH_ARGS] [opt android emulator args]

Customized android emulator start of device <avdid>
  if no "-avd <avdid>" is specified, script tries to use basename of \$0 ($SELF_AVDID)
  as <avdid>. symlink "launch-android.sh" as "avdidname.sh" for argument less usage

script will parse an optional <avdid>.env in the same directory as <avdid>.ini
put additional emulator launcher args there. Eg.:

ANDROID_EMULATOR_LAUNCHER_ARGS="-no-snapshot -no-boot-anim -allow-host-audio -camera-back virtualscene -camera-front webcam0 -camera-hq-edge -phone-number 43664123456789 -dns-server 1.1.1.1"

EOF
  exit 1

}

if test "$ANDROID_HOME" = ""; then
  echo "Error: script needs \$ANDROID_HOME (place of the android sdk) to be set" >&2
  usage >&2
fi
if test ! -e "$SELF_AVDCFG" -a "$1" = ""; then
  echo "Error: no explicit avdid set, and no inplicit avdid found in self name $SELF_AVDID" >&2
  usage >&2
fi
if test "$1" = "-h" -o "$1" = "--help"; then usage; fi
if test "$1" = "-avd" -a "$2" != ""; then
  AVDID="$2"
  shift 2
  AVDCFG="$HOME/.android/avd/${AVDID}.ini"
  if test ! -e $AVDCFG; then
    echo "Error: specified avdid '$AVDID' but config '$AVDCFG' does not exist" >&2
    usage >&2
  fi
else
  AVDID=$SELF_AVDID
  AVDCFG=$SELF_AVDCFG
fi

AVDENV="${AVDCFG%.ini}.env"
if test -e "$AVDENV"; then
  echo "Info: Parsing environment file $AVDENV" >&2
  . "$AVDENV"
fi
$ANDROID_HOME/emulator/emulator -avd $AVDID $ANDROID_EMULATOR_LAUNCHER_ARGS "$@"
