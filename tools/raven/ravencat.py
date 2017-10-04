#!/usr/bin/env python3
import re
import sys
import logging
import os
import time
import argparse
import mailbox
import email
import pwd
import textwrap
import datetime
from html.parser import HTMLParser

import chardet
from raven import Client, get_version
from raven.transport.requests import RequestsHTTPTransport
from raven.utils.json import json

logger = logging.getLogger(__name__)


class MLStripper(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.reset()
        self.fed = []

    def handle_data(self, d):
        self.fed.append(d)

    def handle_entityref(self, name):
        self.fed.append('&%s;' % name)

    def handle_charref(self, name):
        self.fed.append('&#%s;' % name)

    def get_data(self):
        return ''.join(self.fed)


def _strip_once(value):
    """
    Internal tag stripping utility used by strip_tags.
    """
    s = MLStripper()
    try:
        s.feed(value)
    except HTMLParseError:
        return value
    try:
        s.close()
    except HTMLParseError:
        return s.get_data() + s.rawdata
    else:
        return s.get_data()


def strip_tags(value):
    """Returns the given HTML with all tags stripped."""
    # Note: in typical case this loop executes _strip_once once. Loop condition
    # is redundant, but helps to reduce number of executions of _strip_once.
    while '<' in value and '>' in value:
        new_value = _strip_once(value)
        if len(new_value) >= len(value):
            # _strip_once was not able to detect more tags
            break
        value = new_value
    return value


def html2text(htmltext):
    text = HTMLParser().unescape(strip_tags(htmltext))
    text = '\n\n'.join(re.split(r'\s*\n\s*\n\s*', text))
    text = re.sub('\s\s\s+', ' ', text)
    wrapper = textwrap.TextWrapper(
        replace_whitespace=False, drop_whitespace=False, width=72)
    return '\n'.join(wrapper.wrap(text))


def _get_content(message_part):
    payload = message_part.get_payload(decode=True)
    if message_part.get_content_charset() is None:
        charset = chardet.detect(payload)['encoding']
        logger.info(
            'no content charset declared, detection result: {0}'.format(charset))
    else:
        charset = message_part.get_content_charset()
    content = str(payload, charset, "replace")
    logger.debug('message-part: type: {0} charset: {1}'.format(
        message_part.get_content_type(), charset))
    return content


def exist_dir(x):
    if not os.path.isdir(x):
        raise argparse.ArgumentTypeError("{0} does not exist".format(x))
    return x


def exist_file(x):
    if not os.path.exists(x):
        raise argparse.ArgumentTypeError("{0} does not exist".format(x))
    return x


def get_uid():
    return pwd.getpwuid(os.geteuid())[0]


def send_message(client, message, options):
    eventid = client.captureMessage(
        message=message,
        data={
            'culprit': options.get('culprit'),
            'logger': options.get('logger'),
            'request': options.get('request'),
        },
        level=getattr(logging, options.get('level').upper()),
        stack=False,
        date=options.get('date'),
        tags=options.get('tags'),
        extra=options.get('extra'),
        # { 'user': get_uid() }.update(
    )
    success = not client.state.did_fail()
    if options.get('verbose', True):
        print('Event ID was {}'.format(eventid))
        if not success:
            print('error!', file=sys.stderr)

    return (success, eventid)


def send_mailbox(mbox, client, args):
    margs = args.__dict__

    for key, msg in mbox.iteritems():
        margs['culprit'] = msg['From']
        margs['timestamp'] = email.utils.parsedate_to_datetime(
            msg['Date']).astimezone(datetime.timezone.utc).replace(tzinfo=None).isoformat()
        margs['logger'] = 'mailbox.maildir'
        plain = ""
        html = ""

        for part in msg.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            elif part.get_content_type() == 'text/plain':
                plain = _get_content(part)
            elif part.get_content_type() == 'text/html':
                html = html2text(_get_content(part))
            else:
                print('skipping {0}'.format(part.get_content_type()))
                continue

        text = plain or html
        margs['extra'] = {'content': [a for a in text.splitlines() if a.strip()]}
        success, eventid = send_message(client, msg['subject'], margs)
        if success:
            mbox.remove(key)


def send_mbox(client, args):
    try:
        mbox = mailbox.mbox(args.mbox_message)
        send_mailbox(mbox, client, args)
    finally:
        if mbox:
            mbox.close()


def send_maildir(client, args):
    mbox = mailbox.Maildir(args.maildir_message)
    send_mailbox(mbox, client, args)


class EnvDefault(argparse.Action):
    def __init__(self, envvar, required=True, default=None, **kwargs):
        if not default and envvar:
            if envvar in os.environ:
                default = os.environ[envvar]
        if required and default:
            required = False
        super(EnvDefault, self).__init__(default=default, required=required,
                                         **kwargs)

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, values)


class JsonAction(argparse.Action):
    def __init__(self, option_strings, dest, **kwargs):
        super(JsonAction, self).__init__(option_strings, dest, **kwargs)
    def __call__(self, parser, namespace, values, option_strings):
        try:
            values = json.loads(values)
        except ValueError:
            print('Invalid JSON was used for option {}.  Received: {}'.format(
                option_strings, values), file=sys.stderr)
            raise
        setattr(namespace, self.dest, values)


def main():
    logging_choices= ('critical', 'error', 'warning', 'info', 'debug')
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='grouping by sentry uses the first line of the message')
    parser.add_argument('--verbose', action='store_true', default=True)
    parser.add_argument('--culprit', default='ravencat.send_message')
    parser.add_argument('--logger', default='ravencat.main')
    parser.add_argument('--release', default='')
    parser.add_argument('--site', default='')
    parser.add_argument('--level', default='info', choices=logging_choices)
    parser.add_argument('--extra', default={}, action=JsonAction,
        help='a json dictionary of extra data')
    parser.add_argument('--tags', default={}, action=JsonAction,
        help='a json dictionary listening tag name and value')
    parser.add_argument('--request', default={}, action=JsonAction,
        help='a json dictionary of the request')
    parser.add_argument('--dsn', action=EnvDefault,
        envvar='SENTRY_DSN', required=True,
        help='specify a sentry dsn, will use env SENTRY_DSN if unset')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--mbox-message', type=exist_file, metavar='FILE',
        help='mbox filename to parse and send all')
    group.add_argument('--maildir-message', type=exist_dir, metavar='DIR',
        help='maildir directory to parse and send all')
    group.add_argument('--message', type=argparse.FileType(mode='r', encoding='utf-8'),
        dest='message_file',
        metavar='FILE',
        help='filename to read message from, use "-" for stdin')
    group.add_argument('message', nargs='?',
        help='the message string to be sent')

    args = parser.parse_args()

    client = Client(args.dsn,
        include_paths=['raven'],
        transport=RequestsHTTPTransport,
        release=args.release,
        site=args.site,
        context= {},
        )

    if not client.remote.is_active():
        print('Error: DSN configuration, client.remote.is_active <= false', file=sys.stderr)
        sys.exit(1)

    if not client.is_enabled():
        print('Error: Client reporting is disabled', file=sys.stderr)
        sys.exit(1)

    if args.mbox_message:
        send_mbox(client, args)
    elif args.maildir_message:
        send_maildir(client, args)
    else:
        if args.message_file:
            args.message= args.message_file.read()

        success, eventid = send_message(client, args.message, args.__dict__)
        sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
