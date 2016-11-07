# -*- coding: utf-8 -*-

import re
try:  # py3
    from shlex import quote as shell_quote
except ImportError:  # py2
    from pipes import quote as shell_quote

def re_replace(pattern, replacement, string):
    return re.sub(pattern, replacement, string)

def quote(data):
    return shell_quote(data)
