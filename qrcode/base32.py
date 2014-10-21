#!/usr/bin/python
import sys, base64, zipfile, StringIO

def usage():
    print("""
Usage: base32.py (encode|decode [unzip])

takes stdin and encode/decodes it to/from base32. 
with optional parameter unzip it will treat decoded data as zipfile and unzip it to current directory

Limits: Only works for small (< RAM) files (everything is read in memory and processed later)

""")
    sys.exit()

if len(sys.argv) <= 1: usage()
if sys.argv[1] not in ("encode", "decode"): usage()

x = sys.stdin.read()

if sys.argv[1] == "encode":
    y = base64.b32encode(x)
    sys.stdout.write(y)

elif sys.argv[1] == "decode":
    y = base64.b32decode(x)

    if len(sys.argv) >= 3 and sys.argv[2] == "unzip":
        f = StringIO.StringIO(y)
        z = zipfile.ZipFile(f)

        if z.testzip() is not None:
            sys.stderr.write("Error: Zipfile Error: {0}".format(z.testzip()))
        else:
            z.extractall()
            z.close()
            f.close()
    else:
        sys.stdout.write(y)
