#!/bin/bash
set -eo pipefail
# set -x

default_reserve_general=1024
default_reserve_per_core=250

config_template=$(cat << EOF
### PGTUNE-CONFIG-BEGIN ###
# bash subset reimplementation of http://pgtune.leopard.in.ua/ postgresql 10, linux, web
# https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server
# https://www.postgresql.org/docs/10/static/runtime-config-resource.html
max_connections = ##MAX_CONNECTIONS##
shared_buffers = ##SHARED_BUFFERS##
work_mem = ##WORK_MEM##
effective_cache_size = ##EFFECTIVE_CACHE_SIZE##
### PGTUNE-CONFIG-END ###
EOF
)

usage(){
    cat << EOF
Usage:  $0 update path/to/postgresql.conf [reserve]
           show [--no-marker] [reserve]

reserve:
    [--reserve  <general-mb:default=$default_reserve_general>
                <per-core-mb:default=$default_reserve_per_core>]

    general-mb : reserved memory in megabyte unavailable to postgresql tuning
    per-core-mb: additional reserved memory in megabyte per cpu core
EOF
    exit 1
}

calculate_values () {
    # args: $1= reserved memory in megabyte in general
    # args: $2= additional reserved memory in megabyte per core
    # globals MAX_CONNECTIONS SHARED_BUFFERS WORK_MEM EFFECTIVE_CACHE_SIZE
    local res_mem_general_mb res_mem_core_mb mem_kb mem_mb pg_mb cores

    res_mem_general_mb="$1"
    res_mem_core_mb="$2"

    # tune postgresql to current vm memory and cores
    mem_kb=$(cat /proc/meminfo  | grep -i memtotal | sed -r "s/[^:]+: *([0-9]+) .*/\1/g")
    mem_mb=$((mem_kb / 1024))
    cores=$(nproc)

    # memory available for postgresql tuning calculation
    #   we reserve res_mem_general_mb plus res_mem_core_mb per core out of scope
    #   for postgres because of other apps
    #   Range: 512MB < pg_mb
    pg_mb=$((mem_mb - res_mem_general_mb - cores * res_mem_core_mb))
    if test $pg_mb -le 512; then pg_mb=512; fi

    # max_connections: default = 100
    #   Range: 16 (1 core)<= MAX_CONNECTIONS <= 78 (32 cores)
    MAX_CONNECTIONS=$((14 + cores * 2))

    # shared_buffers: default = 128MB
    #   with 1GB or more of RAM, a reasonable starting value for shared_buffers
    #   is 25% of the memory in your system. This buffer directly affects the cache hit ratio
    SHARED_BUFFERS=$((pg_mb / 4))

    # work_mem: default = 4MB
    #   This size is applied to each and every sort done by each user, and
    #   complex queries can use multiple working memory sort buffers.
    #   Set to 50MB, have 30 queries, using 1.5GB of real memory,
    #   if a query involves doing merge sorts of 8 tables, that requires 8 times work_mem.
    #   Calculation is 4mb at 512pg_mb (which translates to 96 available work_mem buffers)
    #   Range: 4MB < WORK_MEM < 64MB
    WORK_MEM=$(((pg_mb - SHARED_BUFFERS) * 1024 / 96 / cores))
    if test $WORK_MEM -lt 4096; then WORK_MEM=4096; fi
    if test $WORK_MEM -gt 65536; then WORK_MEM=65536; fi

    # effective_cache_size: default= 4GB
    #   Setting effective_cache_size to 1/2 of total memory
    #   would be a normal conservative setting, and 3/4 of memory is a more
    #   aggressive but still reasonable amount.
    #   Range: 2048MB < EFFECTIVE_CACHE_SIZE
    EFFECTIVE_CACHE_SIZE=$((3 * pg_mb / 4))
    if test $EFFECTIVE_CACHE_SIZE -lt 2048; then EFFECTIVE_CACHE_SIZE=2048; fi

    # typify values
    SHARED_BUFFERS="${SHARED_BUFFERS}MB"
    WORK_MEM="${WORK_MEM}kB"
    EFFECTIVE_CACHE_SIZE="${EFFECTIVE_CACHE_SIZE}MB"
}


# main
show_marker=true
config_filename=""
reserve_general=$default_reserve_general
reserve_per_core=$default_reserve_per_core

# parse args
if test "$1" != "update" -a "$1" != "show"; then usage; fi
command="$1"
shift
if test "$command" = "update"; then
    config_filename="$1"
    if test ! -e $config_filename; then
        echo "Error: postgresql config file ($config_filename) must exist"
        exit 1
    fi
    shift
else
    if test "$1" = "--no-marker"; then
        show_marker=false
        shift
    fi
fi
if test "$1" = "--reserve"; then
    if test "$3" = ""; then
        echo "Error: --reserve needs two arguments"
        usage
    fi
    reserve_general=$2
    reserve_per_core=$3
    shift 3
fi

# calculate settings, write to template block
calculate_values "$reserve_general" "$reserve_per_core"
block_output=$(printf "%s\n" "$config_template" |
    sed -r "s/##MAX_CONNECTIONS##/$MAX_CONNECTIONS/g;s/##EFFECTIVE_CACHE_SIZE##/$EFFECTIVE_CACHE_SIZE/g" |
    sed -r "s/##WORK_MEM##/$WORK_MEM/g;s/##SHARED_BUFFERS##/$SHARED_BUFFERS/g")

if test "$command" = "show"; then
    if test "$show_marker" = "true"; then
        printf "%s\n" "$block_output"
    else
        printf "%s" "$block_output" | tail -n+2 | head -n-1
    fi

elif test "$command" = "update"; then
    pgcfg_org=$(cat "${config_filename}")
    pgcfg_new=$(printf "%s" "$pgcfg_org" |
        sed '/### PGTUNE-CONFIG-BEGIN ###/,/### PGTUNE-CONFIG-END ###/d' |
        printf "%s" "$block_output" |
        sed -r "s/##MAX_CONNECTIONS##/$MAX_CONNECTIONS/g;s/##EFFECTIVE_CACHE_SIZE##/$EFFECTIVE_CACHE_SIZE/g" |
        sed -r "s/##WORK_MEM##/$WORK_MEM/g;s/##SHARED_BUFFERS##/$SHARED_BUFFERS/g")

    if ! diff -q <(printf "%s" "$pgcfg_org") <(printf "%s" "$pgcfg_new"); then
        echo "Changed postgresql config"
        diff -u <(printf "%s" "$pgcfg_org") <(printf "%s" "$pgcfg_new")
        printf "%s" "$pgcfg_new" > "${config_filename}.new"
        mv "$config_filename" "${config_filename}.old"
        mv "${config_filename}.new" "${config_filename}"
        systemctl restart postgresql
    fi
fi
