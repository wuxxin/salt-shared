#!/bin/sh
#
# Copyright 2019 - The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# 2020.10.18 wuxxin@gmail.com: modification to be executed as user instead of root
#   - changed default options, add some new environment Vars, support headless and desktop

VERBOSE=3


# Return the value of a given named variable.
# $1: variable name
#
# example:
#    FOO=BAR
#    BAR=ZOO
#    echo `var_value $FOO`
#    will print 'ZOO'
#
var_value () {
    eval printf %s \"\$$1\"
}


# Return success if variable $1 is set and non-empty, failure otherwise.
# $1: Variable name.
# Usage example:
#   if var_is_set FOO; then
#      .. Do something the handle FOO condition.
#   fi
var_is_set () {
    test -n "$(var_value $1)"
}

_var_quote_value () {
    printf %s "$1" | sed -e "s|'|\\'\"'\"\\'|g"
}


# Append a space-separated list of items to a given variable.
# $1: Variable name.
# $2+: Variable value.
# Example:
#   FOO=
#   var_append FOO foo    (FOO is now 'foo')
#   var_append FOO bar    (FOO is now 'foo bar')
#   var_append FOO zoo    (FOO is now 'foo bar zoo')
var_append () {
    local _var_append_varname
    _var_append_varname=$1
    shift
    if test "$(var_value $_var_append_varname)"; then
        eval $_var_append_varname=\$$_var_append_varname\'\ $(_var_quote_value "$*")\'
    else
        eval $_var_append_varname=\'$(_var_quote_value "$*")\'
    fi
}

# Run a command, output depends on verbosity level
run () {
    if [ "$VERBOSE" -lt 0 ]; then
        VERBOSE=0
    fi
    if [ "$VERBOSE" -gt 1 ]; then
        echo "COMMAND: $@"
    fi
    case $VERBOSE in
        0|1)
             eval "$@" >/dev/null 2>&1
             ;;
        2)
            eval "$@" >/dev/null
            ;;
        *)
            eval "$@"
            ;;
    esac
}


show_info() {
  # This function logs info about versions and running user
  echo "Running as User: $(id -un)"
  emulator/emulator -version | head -n 1 | sed -u 's/^/version: /g'
  echo 'version: launch_script: {{version}}'
  img=$ANDROID_SDK_ROOT/system-images/android
  [ -f "$img/x86_64/source.properties" ] && cat "$img/x86_64/source.properties" | sed -u 's/^/version: /g'
  [ -f "$img/x86/source.properties" ] && cat "$img/x86/source.properties" | sed -u 's/^/version: /g'
}

install_adb_keys() {
  if [ -s "/run/secrets/adbkey" ]; then
    echo "emulator: Copying private key from secret partition"
    run cp /run/secrets/adbkey "${homedir}/.android"
  elif [ ! -z "${ADBKEY}" ]; then
    echo "emulator: Using provided adb private key"
    echo "-----BEGIN PRIVATE KEY-----" >"${homedir}/.android/adbkey"
    echo $ADBKEY | tr " " "\\n" | sed -n "4,29p" >>"${homedir}/.android/adbkey"
    echo "-----END PRIVATE KEY-----" >>"${homedir}/.android/adbkey"
  else
    echo "emulator: No adb key provided, creating internal one, you might not be able connect from adb."
    run adb keygen "${homedir}/.android/adbkey"
  fi
  run chmod 600 "${homedir}/.android/adbkey"
}

# Installs the console tokens, if any. The environment variable |TOKEN| will be
# non empty if a token has been set.
install_console_tokens() {
  if [ -s "/run/secrets/token" ]; then
    echo "emulator: Copying console token from secret partition"
    run cp /run/secrets/token "${homedir}/.emulator_console_auth_token"
    TOKEN=yes
  elif [ ! -z "${TOKEN}" ]; then
    echo "emulator: Using provided emulator console token"
    echo ${TOKEN} >"${homedir}/.emulator_console_auth_token"
  else
    echo "emulator: No console token provided, console disabled."
  fi

  if [ ! -z "${TOKEN}" ]; then
    echo "emulator: forwarding the emulator console."
    socat -d tcp-listen:5554,reuseaddr,fork tcp:127.0.0.1:5556 &
  fi
}

install_grpc_certs() {
    # Copy certs if they exists and are not empty.
    [ -s "/run/secrets/grpc_cer" ] && cp /run/secrets/grpc_cer "${homedir}/.android/emulator-grpc.cer"
    [ -s "/run/secrets/grpc_key" ] && cp /run/secrets/grpc_key "${homedir}/.android/emulator-grpc.key"
}

clean_up() {
  # Delete any leftovers from hard exits.
  run rm -rf /android-home/Pixel2.avd/*.lock
  run install -d "${homedir}/.android"
  run install -d "${tempdir}/log"
  # Check for core-dumps, that might be left over
  if ls core* 1>/dev/null 2>&1; then
    echo "emulator: ** WARNING ** WARNING ** WARNING **"
    echo "emulator: Core dumps exist in this image. This means the emulator has crashed in the past."
  fi
}

setup_pulse_audio() {
  # We need pulse audio for the webrtc video bridge, let's configure it.
  run mkdir -p ${homedir}/.config/pulse
  export PULSE_SERVER=unix:/${homedir}/.config/pulse/pulse-socket
  run pulseaudio -D -vvvv --log-time=1 --log-target=newfile:${tempdir}/log/pulseverbose.log --log-time=1 --exit-idle-time=-1
  tail -f ${tempdir}/log/pulseverbose.log -n +1 | sed -u 's/^/pulse: /g' &
  run pactl list || exit 1
}

forward_loggers() {
  run mkdir ${tempdir}/log
  run mkfifo ${tempdir}/log/kernel.log
  run mkfifo ${tempdir}/log/logcat.log
  echo "emulator: It is safe to ignore the warnings from tail. The files will come into existence soon."
  tail --retry -f ${tempdir}/log/goldfish_rtc_0 | sed -u 's/^/video: /g' &
  cat ${tempdir}/log/kernel.log | sed -u 's/^/kernel: /g' &
  cat ${tempdir}/log/logcat.log | sed -u 's/^/logcat: /g' &
}

homedir="$( getent passwd "$(id -u)" | cut -d: -f6 )"
tempdir="/tmp"
show_info
clean_up
install_console_tokens
install_adb_keys
install_grpc_certs
if test "${NO_PULSE_AUDIO}" != "true"; then
  setup_pulse_audio
fi

# copy config sekelton if config.ini not existing, and let its user override/append to it
if test ! -e /android-home/Pixel2.avd/config.ini; then
    cp -dR /android-home-default/* /android-home/
    if [ ! -z "${AVD_CONFIG}" ]; then
        echo "Adding ${AVD_CONFIG} to config.ini"
        echo "${AVD_CONFIG}" >>"/android-home/Pixel2.avd/config.ini"
    fi
fi

# Basic launcher command, additional flags can be added.
LAUNCH_CMD=emulator/emulator
var_append LAUNCH_CMD -avd Pixel2
var_append LAUNCH_CMD -ports 5556,5557 -grpc 8554
var_append LAUNCH_CMD -skip-adb-auth
var_append LAUNCH_CMD -feature AllowSnapshotMigration
if test "${NO_FORWARD_LOGGERS}" != "true"; then
  forward_loggers
  var_append LAUNCH_CMD -shell-serial file:${tempdir}/log/kernel.log
  var_append LAUNCH_CMD -logcat-output ${tempdir}/log/logcat.log
fi
if [ ! -z "${EMULATOR_PARAMS}" ]; then
  var_append LAUNCH_CMD $EMULATOR_PARAMS
fi
if [ ! -z "${ADD_EMULATOR_PARAMS}" ]; then
  var_append LAUNCH_CMD $ADD_EMULATOR_PARAMS
fi
if [ ! -z "${TURN}" ]; then
  var_append LAUNCH_CMD -turncfg \'${TURN}\'
fi
# Add qemu specific parameters
var_append LAUNCH_CMD -qemu -append panic=1

# Launch internal adb server, needed for our health check.
# Once we have the grpc status point we can use that instead.
/android/sdk/platform-tools/adb start-server
# All our ports are loopback devices, so setup a simple forwarder
socat -d tcp-listen:5555,reuseaddr,fork tcp:127.0.0.1:5557 &
# Kick off the emulator
run exec $LAUNCH_CMD
