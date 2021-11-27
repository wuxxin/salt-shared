#!/bin/bash
set -eo pipefail
# set -x

usage() {
    cat << EOF
Usage:  $0 restic <args>*

backup command line wrapper for the root user.

+ executes restic as user {{ settings.user }}
+ puts {{ settings.env_file }} in environment
+ passes all remaining cmdline arguments to restic

Examples:

+ create a new restic repository at configured location
    + `$0 restic init`

+ activate an existing repository for backup

```sh
json_dict_get() { # $1=entry [$2..$x=subentry] , eg. gitops git source
    python3 -c "import sys, json, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], json.load(sys.stdin)))" $@
}
set_tag() { # $1=tagname $2=tagvalue
    echo "$2" > "{{ settings.var_dir }}/tags/$1"
}
set_tag "backup/backup_repo_id" "$($0 restic cat config --json | json_dict_get id)"`
```

EOF
    exit 1
}

if test "$1" != "restic"; then echo "Error: unknown command"; usage; fi
shift
# check if run as root
if test "$(id -u)" != "0"; then echo "Error: $0 must be called as root"; usage; fi
UNITNAME='backup-run'
HOME={{ settings.home_dir }}
USER={{ settings.user }}
EnvironmentFile={{ settings.env_file }}
WorkingDirectory={{ settings.home_dir }}
# get restic configuration, populate env
if ! test -e "$EnvironmentFile"; then
    echo "error: could not read backup environment: $EnvironmentFile"
    exit 1
fi
. "$EnvironmentFile"
# export env
export UNITNAME HOME USER RESTIC_REPOSITORY RESTIC_PASSWORD {% if settings.env %}{% for k,v in settings.env.items() %}{{ k }} {% endfor %}{% endif %}
# execute requested function
gosu "$USER" restic "$@"
