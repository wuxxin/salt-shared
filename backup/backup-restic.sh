#!/bin/bash
set -eo pipefail
# set -x

usage() {
    cat << EOF
Usage:  $0 run <args>*
        $0 repository create|use-existing

+ run <args>*
    executes restic as user {{ settings.user }},
    puts {{ settings.backup_env }} in environment,
    passes all remaining cmdline arguments to restic

    Example: $0 run snapshots

+ repository create
    create a new restic repository at configured location

+ repository use-existing
    activate an existing repository (if key matches)

EOF
    exit 1
}

. "/usr/local/lib/app-library.sh"

if test "$1" != "repository" -a "$1" != "run"; then
    echo "Error: unknown command"
    usage
fi

# check if run as root
if test "$(id -u)" != "0"; then
    echo "Error: $0 must be called as root"
    usage
fi

# get restic configuration
if ! test -e "{{ settings.backup_env }}"; then
    echo "error: could not read backup environment {{ settings.backup_env }}"
    exit 1
fi
. "{{ settings.backup_env }}"

# execute requested function
if test "$1" = "run"; then
    shift
    gosu "{{ settings.user }}" env $RESTIC_ENV \
        HOME="{{ settings.home_dir }}" \
        RESTIC_PASSWORD="$RESTIC_PASSWORD" \
        RESTIC_REPOSITORY="$RESTIC_REPOSITORY" \
        restic "$@"

elif test "$1" = "repository"; then
    shift
    if test "$1" = "create"; then
        create_repository=true
    elif test "$1" = "use-existing"; then
        create_repository=false
    else
        usage
    fi
    shift

    if test "$create_repository" = "true"; then
        echo "creating repository, executing restic init"
        gosu "{{ settings.user }}" env $RESTIC_ENV \
            HOME="{{ settings.home_dir }}" \
            RESTIC_PASSWORD="$RESTIC_PASSWORD" \
            RESTIC_REPOSITORY="$RESTIC_REPOSITORY" \
            restic init
    fi
    echo "get restic repository id"
    restic_repo_id=$(gosu "{{ settings.user }}" env $RESTIC_ENV \
        HOME="{{ settings.home_dir }}" \
        RESTIC_PASSWORD="$RESTIC_PASSWORD" \
        RESTIC_REPOSITORY="$RESTIC_REPOSITORY" \
        restic cat config --json | json_dict_get id)
    echo "activate backup for repository id: $restic_repo_id"
    set_tag "app_backup_id" "$restic_repo_id"
else
    usage
fi
