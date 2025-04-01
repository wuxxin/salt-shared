#!/usr/bin/env python3

import argparse
import re
from os import walk
from os.path import join


def get_patterns(patterns_dir):
    patterns = {}
    for (dirpath, _, filenames) in walk(patterns_dir):
        for name in filenames:
            with open(join(dirpath, name)) as f:
                for line in f.readlines():
                    if not line.startswith("#") and not line.strip() == "":
                        k, v = line.split(" ", 1)
                        patterns[k] = v.rstrip("\n")
    return patterns


def convert(expression, patterns):
    groks = re.compile("%{[^}]*}")

    failed_matches = set()
    matches_prev_len = 0

    while True:
        matches = groks.findall(expression)
        matches_cur_len = len(matches)
        if matches_cur_len == 0 or matches_cur_len == matches_prev_len:
            break
        for m in matches:
            inner = m.strip("%{}")
            if ":" in inner:
                patt, name = inner.split(":")
                replacement = "(?<{}>{{}})".format(name)
            else:
                patt = inner
                replacement = "{}"

            if patt not in patterns.keys():
                failed_matches.add(patt)
                continue

            expression = expression.replace(m, replacement.format(patterns[patt]))
        matches_prev_len = matches_cur_len

    print(expression)

    if failed_matches:
        global args
        print("\nWarning! Unable to match the following expressions:")
        print("  {}".format(", ".join(failed_matches)))
        print(
            "This could be a typo or a missing grok pattern file. check your grok patterns directory: {}".format(
                args.patterns_dir
            )
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("expression", metavar="expr", help="A grok expression.")
    parser.add_argument(
        "-d",
        "--patterns-dir",
        dest="patterns_dir",
        default="patterns",
        help="Directory to find grok patterns.",
    )
    args = parser.parse_args()
    patterns = get_patterns(args.patterns_dir)
    convert(args.expression, patterns)
