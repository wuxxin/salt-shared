#!/bin/bash
set -eo pipefail
# set -x

usage() {
    cat << EOF
Usage:  $0 restic <args>*

command line wrapper for the root user,
executes restic as user {{ settings.user }},
puts {{ settings.backup_env }} in environment,
passes all remaining cmdline arguments to restic

Examples:
+ create a new restic repository at configured location
    + `$0 restic init`

+ activate an existing repository for backup
    + `set_tag "backup_repo_id" "$($0 restic cat config --json | json_dict_get id)"`

EOF
    exit 1
}

if test "$1" != "restic"; then echo "Error: unknown command"; usage; fi
shift
# check if run as root
if test "$(id -u)" != "0"; then echo "Error: $0 must be called as root"; usage; fi
# get restic configuration
if ! test -e "{{ settings.backup_env }}"; then
    echo "error: could not read backup environment {{ settings.backup_env }}"
    exit 1
fi
. "{{ settings.backup_env }}"

# execute requested function
gosu "{{ settings.user }}" env $RESTIC_ENV \
    HOME="{{ settings.home_dir }}" \
    RESTIC_PASSWORD="$RESTIC_PASSWORD" \
    RESTIC_REPOSITORY="$RESTIC_REPOSITORY" \
    restic "$@"
