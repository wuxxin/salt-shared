#!/bin/bash
set -eo pipefail
# set -x


config_template=$(cat << EOF
### PGTUNE-CONFIG-BEGIN ###
# simple reimplementation of http://pgtune.leopard.in.ua/ postgresql 12, linux, web
# https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server
# https://www.postgresql.org/docs/12/static/runtime-config-resource.html
max_connections = ##MAX_CONNECTIONS##
shared_buffers = ##SHARED_BUFFERS##
work_mem = ##WORK_MEM##
effective_cache_size = ##EFFECTIVE_CACHE_SIZE##
### PGTUNE-CONFIG-END ###
EOF
)

usage(){
    cat << EOF
Usage:  $0 update postgresql.conf [--cores x] (--leave mainmb percoremb|--use mb)
           show [--no-marker]     [--cores x] (--leave mainmb percoremb|--use mb)

update:     read/modify/write postgresql config if different values
show:       show postgresql config snippet, with or without (--no-marker) begin and end marker

--cores     <overwrite the actual number of cores of the machine, default to:\$(nproc)>
--leave     <main-mb> <per-core-mb>
            main-mb : eg. "1024", reserved memory in megabyte unavailable to postgresql tuning
            per-core-mb: eg. "256", additional reserved memory in megabyte per cpu core
--use       <total-available-mb-for-postgresql> eg. "4096"

either "use" or "leave" must be specified.
in case of leave, total-available-mb-for-postgresql = Total-Mem - (leave.general + leave.percore * cores)
EOF
    exit 1
}

calculate_values () {
    # args: $1= memory available in megabyte for postgresql tuning
    # args: $2= number of cores for tuning
    # globals MAX_CONNECTIONS SHARED_BUFFERS WORK_MEM EFFECTIVE_CACHE_SIZE
    local pg_mb cores
    pg_mb=$1
    cores=$2

    # memory available for postgresql tuning calculation
    #   we reserve res_mem_general_mb plus res_mem_core_mb per core out of scope
    #   for postgres because of other apps
    #   Range: 512MB < pg_mb
    if test $pg_mb -le 512; then pg_mb=512; fi

    # max_connections: default = 100
    #   Range: 20 (1 core)<= MAX_CONNECTIONS <= 113 (32 cores)
    MAX_CONNECTIONS=$((17 + cores * 3))

    # shared_buffers: default = 128MB
    #   with 1GB or more of RAM, a reasonable starting value for shared_buffers
    #   is 25% of the memory in your system. This buffer directly affects the cache hit ratio
    #   Range: 128MB < SHARED_BUFFERS
    SHARED_BUFFERS=$((pg_mb / 4))

    # work_mem: default = 4MB
    #   This size is applied to each and every sort done by each user, and
    #   complex queries can use multiple working memory sort buffers.
    #   Set to 50MB, have 30 queries, using 1.5GB of real memory,
    #   if a query involves doing merge sorts of 8 tables, that requires 8 times work_mem.
    #   Calculation is 4mb at 512pg_mb (which translates to 96 available work_mem buffers)
    #   Range: 4MB < WORK_MEM < 64MB
    WORK_MEM=$(((pg_mb - SHARED_BUFFERS) * 1024 / (MAX_CONNECTIONS*2) / cores))
    if test $WORK_MEM -lt 4096; then WORK_MEM=4096; fi
    if test $WORK_MEM -gt 65536; then WORK_MEM=65536; fi

    # effective_cache_size: default= 4GB
    #   Range: 384MB < EFFECTIVE_CACHE_SIZE
    EFFECTIVE_CACHE_SIZE=$((pg_mb - SHARED_BUFFERS))
    if test $EFFECTIVE_CACHE_SIZE -lt 384; then EFFECTIVE_CACHE_SIZE=384; fi

    # typify values
    SHARED_BUFFERS="${SHARED_BUFFERS}MB"
    WORK_MEM="${WORK_MEM}kB"
    EFFECTIVE_CACHE_SIZE="${EFFECTIVE_CACHE_SIZE}MB"
}


# main
show_marker=true
config_filename=""
cores=$(nproc)
mem_kb=$(cat /proc/meminfo  | grep -i memtotal | sed -r "s/[^:]+: *([0-9]+) .*/\1/g")
mem_mb=$((mem_kb / 1024))

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
    if test "$1" = "--no-marker"; then show_marker=false; shift; fi
fi
if test "$1" = "--cores"; then
    if test "$2" = ""; then echo "Error: --cores needs one argument"; usage; fi
    cores=$2
    shift 2
fi
if test "$1" = "--leave"; then
    if test "$3" = ""; then echo "Error: --leave needs two arguments"; usage; fi
    pg_mb=$((mem_mb - $2 - cores * $3))
    shift 3
elif test "$1" = "--use"; then
    if test "$2" = ""; then echo "Error: --use needs one argument"; usage; fi
    pg_mb=$2
    shift 2
fi


# calculate settings, write to template block
calculate_values "$pg_mb" "$cores"

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
