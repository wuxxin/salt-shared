# -*- coding: utf-8 -*-

# saltstack modul to be used as salt['extutils.re_findall'](p,s)

import re
from shlex import quote as shell_quote


def re_sub(pattern, repl, string, count=0, flags=0):
    return re.sub(pattern, repl, string, count=count, flags=flags)


def re_findall(pattern, string, flags=0):
    return re.findall(pattern, string, flags)


def quote(data):
    return shell_quote(data)
