#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh

userdata_to_env appliance || exit $?

do_letsencrypt_update() {
  echo "FIXME: Unimplemented!"
}

do_letsencrypt_update
