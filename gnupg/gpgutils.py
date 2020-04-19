#!/usr/bin/env python3
"""
Encryption/Signing, Decryption/Verifying modul.

- This module uses Gnu Privacy Guard 1/2 for the actual encryption work
  - The GNU Privacy Guard -- a free implementation of the OpenPGP standard as defined by RFC4880

- Environment
  - set environment variable GPG_EXECUTABLE to use a custom existing gnupg binary

"""
import sys
import os
import subprocess
import tempfile
import re
import inspect
import pydoc


def _gpgname():
    GPG_EXECUTABLE = "gpg"
    if os.environ.get("GPG_EXECUTABLE"):
        GPG_EXECUTABLE = os.environ["GPG_EXECUTABLE"]
    return GPG_EXECUTABLE


def _gpg(args, batch_args=None):
    call = [_gpgname()] + args
    stdin = subprocess.PIPE if batch_args else None

    try:
        popen = subprocess.Popen(
            call,
            stdin=stdin,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
        )
    except OSError as e:
        if e.errno == os.errno.ENOENT:
            raise OSError('ERROR: gpg executable "{0}" not found'.format(_gpgname()))
        else:
            raise

    if batch_args:
        stdout, stderr = popen.communicate(batch_args)
        popen.stdin.close()
    else:
        stdout, stderr = popen.communicate()

    returncode = popen.returncode
    if returncode != 0:
        raise IOError(
            '"{0}" returned error code: {1} , stdout was: {2}, stderr was: {3}'.format(
                call, returncode, stdout, stderr
            )
        )

    return (returncode, stdout, stderr)


def _gpgversion():
    gpgversion = [0, 0, 0]
    returncode, stdout, stderr = _gpg(["--version"])
    vermatch = re.match(r"[^0-9]+([0-9]+)\.([0-9]+)\.([0-9]+)", stdout.splitlines()[0])
    if vermatch is not None:
        gpgversion = [
            int(vermatch.group(1)),
            int(vermatch.group(2)),
            int(vermatch.group(3)),
        ]
    return gpgversion


def _isgpg2():
    """ returns True if gpg executable is gpg version 2"""
    return _gpgversion()[0] == 2


def _strbool(data):
    """ return either the boolean value (if isinstance(text,bool) or True if string is one of True or Yes (case insensitiv) or False"""
    if isinstance(data, bool):
        return data
    else:
        return data.upper() in ["TRUE", "YES"]


def reset_keystore(gpghome):
    """ wipes out keystore under directory gpghome

    :warn: deletes every file in this directory
    """
    if not os.path.isdir(gpghome):
        os.makedirs(gpghome)
    for f in os.listdir(gpghome):
        path = os.path.join(gpghome, f)
        if os.path.isfile(path):
            os.remove(path)


def gen_keypair(
    owneremail,
    ownername,
    secretkey_filename,
    publickey_filename,
    keylength=2560,
    ask_passphrase=False,
):
    """ writes a pair of ascii armored key files, first is secret key, second is publickey, minimum owneremail length is five"""

    batch_args = "%echo Generating key\n"
    if _strbool(ask_passphrase):
        batch_args += "%ask-passphrase\n"
    else:
        batch_args += "%no-protection\n"
    if _isgpg2():
        keytype = "RSA"
        gpgver = _gpgversion()
        if gpgver[1] < 1 or (gpgver[1] == 1 and gpgver[2] < 15):
            print(
                "Warning: gpg < 2.1.15 (this={}.{}.{}) secret export bug".format(
                    gpgver[0], gpgver[1], gpgver[2]
                )
            )
    else:
        keytype = "1"
        batch_args += "%secring {0}\n%pubring {1}\n".format(
            secretkey_filename, publickey_filename
        )

    batch_args += "Key-Type: {0}\nKey-Length: {1}\n".format(keytype, keylength)
    batch_args += "Key-Usage: encrypt,sign\n"
    batch_args += "Name-Real: {0}\nName-Email: {1}\n".format(ownername, owneremail)
    batch_args += "Expire-Date: 0\n"
    batch_args += "%commit\n%echo done\n"
    print(batch_args)

    if _isgpg2():
        try:
            gpghome = tempfile.mkdtemp()
            reset_keystore(gpghome)
            baseargs = ["--homedir", gpghome, "--batch", "--yes"]
            args = baseargs + ["--gen-key"]
            returncode, stdout, stderr = _gpg(args, batch_args)
            args = baseargs + ["--armor", "--export", "--output", publickey_filename]
            returncode, stdout, stderr = _gpg(args)
            args = baseargs + [
                "--armor",
                "--export-secret-keys",
                "--output",
                secretkey_filename,
            ]
            returncode, stdout, stderr = _gpg(args)
        finally:
            print(gpghome)
            reset_keystore(gpghome)
    else:
        args = ["--no-default-keyring", "--armor", "--batch", "--yes", "--genkey"]
        returncode, stdout, stderr = _gpg(args, batch_args)

    return stdout


def import_key(keyfile, gpghome):
    """ import a keyfile (generated by gen_keypair) into gpghome directory gpg keyring """
    args = ["--homedir", gpghome, "--batch", "--yes", "--import", keyfile]
    returncode, stdout, stderr = _gpg(args)
    return stdout


def set_ownertrust(userid, gpghome, trustlevel=5):
    """ edit a already imported key and change the trustlevel (default 5=ultimate trust) """
    args = ["--homedir", gpghome, "--batch", "--yes", "--import-ownertrust"]
    batch_args = userid + ":" + str(trustlevel) + ":\n"
    returncode, stdout, stderr = _gpg(args, batch_args)
    return stdout


def publickey_list(gpghome):
    """ returns a string listing all keys in keystore of gpghome """
    args = [
        "--homedir",
        gpghome,
        "--batch",
        "--yes",
        "--fixed-list-mode",
        "--with-colons",
        "--list-keys",
        "--with-fingerprint",
        "--with-fingerprint",
    ]
    returncode, stdout, stderr = _gpg(args)
    return stdout


def secretkey_list(gpghome):
    """ returns a string listing all keys in keystore of gpghome """
    args = [
        "--homedir",
        gpghome,
        "--batch",
        "--yes",
        "--fixed-list-mode",
        "--with-colons",
        "--list-secret-keys",
        "--with-fingerprint",
    ]
    returncode, stdout, stderr = _gpg(args)
    return stdout


def encrypt_sign(sourcefile, destfile, gpghome, encrypt_owner, signer_owner=None):
    """ read sourcefile, encrypt and optional sign and write destfile

    :note: booth sourcefile and destfile should already exist (destfile should be zero length)
    :param gpghome: directory where the .gpg files are
    :param encrypt_owner: owner name of key for encryption using his/her public key
    :param signer_owner: if not None: owner name of key for signing using his/her secret key
    """
    args = [
        "--homedir",
        gpghome,
        "--batch",
        "--yes",
        "--always-trust",
        "--recipient",
        encrypt_owner,
        "--output",
        destfile,
    ]
    if signer_owner:
        args += ["--local-user", signer_owner, "--sign"]
    args += ["--encrypt", sourcefile]

    returncode, stdout, stderr = _gpg(args)
    return stdout


def decrypt_verify(sourcefile, destfile, gpghome, decrypt_owner, verify_owner=None):
    """ read sourcefile, decrypt and optional verify if signer is verify_owner

    :param decrypt_owner: owner name of key used for decryption using his/her secret key
    :param verify_owner: owner name of key used for verifying that it was signed using his/her public key
    :raise IOError: on gnupg error, with detailed info
    :raise KeyError: if key owner could not be verified
    """
    args = [
        "--homedir",
        gpghome,
        "--batch",
        "--yes",
        "--always-trust",
        "--recipient",
        decrypt_owner,
        "--output",
        destfile,
        "--decrypt",
        sourcefile,
    ]
    returncode, stdout, stderr = _gpg(args)
    if verify_owner is not None:
        p = re.compile('gpg: Good signature from "' + verify_owner + '"')
        if p.match is None:
            raise (
                KeyError,
                "could not verify that signer was keyowner: %s , args: %s , stdout: %s , stderr: %s"
                % (verify_owner, str(args), stdout, stderr),
            )


def help(which=None):
    """ help about all functions or one specific function """
    m = sys.modules[__name__]
    if which:
        print(pydoc.render_doc(getattr(m, which)))
    else:
        print(pydoc.render_doc(m))
    sys.exit(1)


if __name__ == "__main__":
    args = sys.argv
    args.pop(0)
    m = sys.modules[__name__]
    if not args:
        help()
    c = args.pop(0)
    f = getattr(m, c, None)
    if f is None:
        print("ERROR: unknown command {0}".format(c), file=sys.stderr)
        help()
    signature = inspect.getfullargspec(f)
    defaults_len = len(signature.defaults) if signature.defaults else 0
    if len(signature.args) - defaults_len > len(args):
        print("ERROR: wrong number of arguments for {0}".format(c), file=sys.stderr)
        help(c)
    r = f(*args)
    if r:
        print(r)
