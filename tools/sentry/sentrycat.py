#!/usr/bin/env python3
import argparse
import copy
import datetime
import email
import json
import logging
import mailbox
import os
import pwd
import re
import socket
import sys
import textwrap
import time

import chardet
import sentry_sdk

from sentry_sdk.integrations.logging import LoggingIntegration
from sentry_sdk.integrations.stdlib import StdlibIntegration
from sentry_sdk.integrations.excepthook import ExcepthookIntegration
from sentry_sdk.integrations.dedupe import DedupeIntegration
from sentry_sdk.integrations.atexit import AtexitIntegration
from sentry_sdk.integrations.threading import ThreadingIntegration

from html.parser import HTMLParser

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

    if charset in ['iso-8859-8-i', 'iso-8859-8-e']:
        # XXX https://bugs.python.org/issue18624
        logger.debug('aliasing charset iso-8859-8 for {0}'.format(charset))
        charset = 'iso-8859-8'

    logger.debug('message-part: type: {0} charset: {1}'.format(
        message_part.get_content_type(), charset))
    content = str(payload, charset, "replace")
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


def send_message(args):
    ''' Mandatory args: message '''

    margs = copy.copy(args)
    [ margs.pop(i) for i in ['verbose',] ]

    with sentry_sdk.push_scope() as local_scope:
        if margs.get('level', False):
            local_scope.level = margs.pop('level')
        if margs.get('request', False):
            local_scope.request = margs.pop('request')
        for k,v in margs.pop('extra', {}).items():
            local_scope.set_extra(k, v)
        for k,v in margs.pop('tags', {}).items():
            local_scope.set_tag(k, v)
        if margs.get('email', False):
            email_address= margs.pop('email')
            local_scope.user = {
                "email": email_address,
            }
        eventid = sentry_sdk.capture_event(margs)

    if args.get('verbose', True):
        if eventid:
            print('Sent Event ID: {}'.format(eventid))
        else:
            print('Error sending Event "{}" !'.format(margs.message), file=sys.stderr)

    return eventid


def send_mailbox(mbox, args):
    margs = copy.copy(args)
    [ margs.pop(i) for i in ['verbose',] ]

    for key, mailentry in mbox.iteritems():
        margs['culprit'] = mailentry['From']
        margs['email'] = mailentry['From']
        margs['timestamp'] = email.utils.parsedate_to_datetime(mailentry['Date']).astimezone(
            datetime.timezone.utc).replace(tzinfo=None).isoformat()
        margs['logger'] = 'mailbox.send_mailbox'
        margs['message'] = mailentry['subject']
        plain = ""
        html = ""
        if args.get('verbose', True):
            print('Processing Email ID: {}'.format(mailentry.), file=sys.stdout)

        for part in mailentry.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            elif part.get_content_type() == 'text/plain':
                plain = _get_content(part)
            elif part.get_content_type() == 'text/html':
                html = html2text(_get_content(part))
            else:
                if args.get('verbose', True):
                    print('skipping {0}'.format(part.get_content_type()), file=sys.stdout)
                continue

        text = plain or html
        margs['extra'] = {'content': [a for a in text.splitlines() if a.strip()]}
        eventid = send_message(client, margs)
        if eventid:
            mbox.remove(key)
        else:
            print('Error sending Event "{}" !'.format(margs.message), file=sys.stderr)


def send_mbox(mbox_filename, args):
    try:
        mbox = mailbox.mbox(mbox_filename)
        send_mailbox(mbox, args)
    finally:
        if mbox:
            mbox.close()


def send_maildir(mbox_dirname, args):
    mbox = mailbox.Maildir(mbox_dirname)
    send_mailbox(mbox, args)


class EnvDefault(argparse.Action):
    def __init__(self, envvar, required=True, default=None, **kwargs):
        if not default and envvar:
            if envvar in os.environ:
                default = os.environ[envvar]
        if required and default:
            required = False
        super(EnvDefault, self).__init__(
            default=default, required=required, **kwargs)

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
    parser.add_argument('--logger', default='sentrycat.main')
    parser.add_argument('--level', default='info', choices=logging_choices)
    parser.add_argument('--culprit', default='sentrycat.send_message')
    parser.add_argument('--server_name', default=socket.getfqdn())
    parser.add_argument('--release', default='')
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

    args = parser.parse_args().__dict__

    client = sentry_sdk.init({
        'dsn': args.pop('dsn'),
        'release': args.pop('release'),
        'server_name': args.pop('server_name'),
        'send_default_pii': True,
        'integrations': [
            LoggingIntegration(),
            StdlibIntegration(),
            ExcepthookIntegration(),
            DedupeIntegration(),
            AtexitIntegration(),
            ThreadingIntegration(),
        ],
        'default_integrations': False,
    })

    if not client:
        print('Error: failed to initialize sentry_sdk', file=sys.stderr)
        sys.exit(1)

    with sentry_sdk.configure_scope() as scope:
        scope.level = args.pop('level')
        for k,v in args.pop('extra').items():
            scope.set_extra(k, v)
        for k,v in args.pop('tags').items():
            scope.set_tag(k, v)

    if args.get('mbox_message'):
        mbox_name=args.pop('mbox_message')
        send_mbox(mbox_name, args)
    elif args.get('maildir_message'):
        mbox_name=args.pop('maildir_message')
        send_maildir(mbox_name, args)
    else:
        if args.get('message_file'):
            msgfile_obj=args.pop('message_file')
            args['message']= msgfile_obj.read()

        eventid = send_message(args)
        sys.exit(0 if eventid else 1)


if __name__ == '__main__':
    main()
