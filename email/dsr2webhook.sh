#!/usr/bin/env sh
set -e

usage () {
    cat <<EOF
Usage: $0 --format <format> --url <url> [--sender <sender> --recipient <recipient>]

format: sendgrid, zone-mta, file
url: http post url except for file, it is the file path

EOF
}
if test "$format" = "file"; then
    perl -MSisimai -lE 'print Sisimai->dump(STDIN)' >> "$url"
else
    perl -MSisimai -lE 'print Sisimai->dump(STDIN)' | \
    /usr/local/bin/sisimai_transform.py --format "$format" | \
    curl -H "Content-Type: application/json" -X POST -d @- "$url"
fi
