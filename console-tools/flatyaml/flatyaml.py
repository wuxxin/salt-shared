#!/usr/bin/env python3
import sys
import collections
import argparse

from shlex import quote

try:
    import yaml
except ImportError as e:
    print('ERROR: fatal, could not import yaml: {0}, try "apt install python3-yaml"'.format(e))
    sys.exit(1)


def flatten(d, parent_key='', sep=''):
    items = []

    if isinstance(d, collections.MutableMapping):
        for k, v in d.items():
            new_key = parent_key + sep + k if parent_key else k
            items.extend(flatten(v, new_key, sep).items())
        return dict(items)

    elif isinstance(d, (list, tuple)):
        for i, v in enumerate(d):
            new_key = parent_key + sep + str(i) if parent_key else str(i)
            items.extend(flatten(v, new_key, sep).items())
        items.extend([ (parent_key + sep + 'len', len(d)), ])
        return dict(items)

    else:
        if d is None:
            d = ''
        elif isinstance(d, str):
            d = quote(d.strip())
        elif isinstance(d, bool):
            d = repr(d).lower()
        return { parent_key: d }


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
read yaml from FILE or stdin, filter,
flatten (combine name space with "_") & upper case key names
output sorted keys assigned with "=" to value on stdout as
{prefix}{KEY_NAME_SPACE}={value}{postfix}

+ strings are modified with strip and shlex.quote
+ lists are converted to names using key_name_0, key_name_len as maxindex
+ bools are converted to repr(value).lower()
+ None is converted to an empty string
''')

    parser.add_argument('--prefix', default='')
    parser.add_argument('--postfix', default='')
    parser.add_argument('--combine', default='_')
    parser.add_argument('--assign', default='=')
    parser.add_argument('--file', nargs='?',
        type=argparse.FileType('r'), default=sys.stdin,
        help='file to read or stdin if not defined')
    parser.add_argument('key',
        help='comma seperated list of keynames or "." for all')

    args = parser.parse_args()

    with args.file as f:
        data = yaml.safe_load(f)

    for i in args.key.split(','):
        keyroot = ''
        if i == '.':
            result = flatten(data, sep=args.combine).items()
        elif i in data:
            result = flatten(data[i], sep=args.combine).items()
            keyroot = i.upper()+ args.combine
        else:
            print('Error: key "{}" not found in data'.format(i), file=sys.stderr)
            continue

        for key, value in sorted(result):
            print('{prefix}{key}{assign}{value}{postfix}'.format(
                prefix=args.prefix,
                key=keyroot+key.upper(),
                assign=args.assign,
                value=value,
                postfix=args.postfix,
                ))

if __name__ == '__main__':
    main()
