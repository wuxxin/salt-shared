#!/usr/bin/env bash
set -e

usage () {
    cat <<EOF
Parse and convert freeform "Delivery Status Reports" mails into
selected json format and http post this json data to a webserver.

Usage as a local mail delivery agent for postfix or getmail:

    $0 --format <format> --post <url> --from-stdin
        [--save-on-fail <maildir>] [--sender <sender>] [--recipient <recipient>]

Usage to scan through an existing set of mails inside a maildir:

    $0 --format <format> --post <url> --from-maildir <maildir>

--format <format>
    outgoing webhook format: sendgrid, zonemta

--post <url>
    http(s) post url, or local directory name prefixed with file://

--from-stdin
    read one message from stdin, parse, post to webhook if dsr
    exit 0 if message is dsr and webhook post returned 200 OK
    exit 1 if message is dsr but webhook post returned != 200 OK
    exit 2 if message is not a dsr
    exit 3 if message could not be analyzed (unknown if dsr or not)

--save-on-fail <maildir>
    if message is not a dsr or could not get converted, or the webhook did not
    return 200 OK, save the original mail contents to <maildir>
    exit 4 if message could not be saved to <maildir>
    exit 0 in all other cases

--from-maildir <maildir>
    read all new messages of configured maildir, send all dsr messages to hook,
    delete them if hook returned 200 OK, else move them to read

    exit 0 if all dsr message posts returned 200 OK
    exit 1 if one or more dsr message posts returned != 200 OK
    exit 3 if one or more messages could not be analyzed
EOF
}

if test "$url" beginswith FIXME = "file"; then
    perl -MSisimai -lE 'print Sisimai->dump(STDIN)' | \
    /usr/local/bin/sisimai_transform.py --format "$format" >> "$url"
else
    perl -MSisimai -lE 'print Sisimai->dump(STDIN)' | \
    /usr/local/bin/sisimai_transform.py --format "$format" | \
    curl -H "Content-Type: application/json" -X POST -d @- "$url"
fi
