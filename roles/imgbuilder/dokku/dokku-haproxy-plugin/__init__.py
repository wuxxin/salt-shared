#!/usr/bin/env python

import os
import stat

from contextlib import contextmanager

import click
from click.formatting import HelpFormatter

from sarge import run

class _simpleFormatter(HelpFormatter):
    @contextmanager
    def section(self, name):
        try:
            yield
        finally:
            self.dedent()

def click_simple_help(ctx):
    basectx = ctx.find_root()
    formatter = _simpleFormatter(width=basectx.terminal_width)
    basectx.command.format_commands(basectx, formatter)
    click.echo(formatter.getvalue().rstrip('\n'))


def cat_stdin():
    mode = os.fstat(0).st_mode
    if (stat.S_ISFIFO(mode) or stat.S_ISREG(mode)):
        stdin_text = click.get_text_stream('stdin')
        for line in stdin_text:
            click.echo(line)


def dokku_common(name, *args):
    """call a dokku_common function"""
    run("bash -c -- source ~/dokku_common; {0} {1}".format(name, args))
