#!/usr/bin/env sh
set -e

usage () {
    cat <<EOF
Usage:
    $0 --format <format> --post <url> --from-stdin [--save-on-fail <maildir>]
    $0 --format <format> --post <url> --from-maildir <maildir>

Parse and convert freeform "Delivery Status Reports" Mails into json for posting it to a webserver.

Can be used to scan through an existing set of mails inside a maildir,
or as a local mail delivery agent in postfix or getmail.

--format <format>
    webhook format: sendgrid, zonemta
--post <url>
    http(s) post url, or local directory name prefixed with file://

--from-stdin
    read one message from stdin, parse, post dsr, exit
--save-on-fail <maildir>
    if message was not dsr or could not get converted, or the webhook didnt return 200 OK
    save original mail contents to maildir

--from-maildir <maildir>
    read all new messages of configured maildir, process them,
    delete them if hook returned 200 OK, else move them to read

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
