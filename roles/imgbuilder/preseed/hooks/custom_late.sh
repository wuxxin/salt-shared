#!/bin/sh

logger -t custom_late.sh started custom_late.sh

# execute /tmp/custom_late*hook
for a in `ls /tmp/custom_late*hook | sort -n`; do
    logger -t custom_late_hook $a
    log-output -t custom_late_hook sh $a
fi

