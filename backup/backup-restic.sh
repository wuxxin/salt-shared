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


if test -e "/usr/local/lib/app-library.sh"; then
    . "/usr/local/lib/app-library.sh"
else
    json_dict_get() { # $1=entry [$2..$x=subentry] , eg. gitops git source
        python3 -c "import sys, json, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], json.load(sys.stdin)))" $@
    }
    set_tag() { # $1=tagname $2=tagvalue
        echo "$2" > "{{ settings.tag_dir }}/$1"
    }
fi

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
