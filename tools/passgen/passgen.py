#!/usr/bin/env python3

import subprocess

try:
    from bitstring import BitStream
except ImportError as e:
    print("error: you need to install python package bitstring")
    raise

"""
human friendly passwort generator:

  Final Product:

    Password Size: 16 Character lowercase alphabet
    Expected Entropy: 58 Bits= 4,25 * 11 + 2,25 * 5
    Vowels Placing at Character: 2,5,8,11,14

  Execution:

    + Generate enough quality entropy:
        + ~ 72 Bit = 9 Bytes source entropy needed
        + openssl rand is used for entropy gathering

    + Generate
    11 Chars of Base 21 ([a-z] - [a,e,i,o,u])
        + using (5 Bit MOD 21 ) per char
        + Used Entropy Bits: 55 Bit

    + Generate 5 Chars of Base 5 ([a,e,i,o,u])
        + using (3 Bit MOD 5) per Char
        + Used Entropy Bits: 15 Bit

    + Total source entropy used: 70 out of 72 Bit

  Personal Metrics:

    memorize   : ++ (i can pronounce and hear the sound of it, no numbers, only lowercase)
    security   : + (58Bit if schema and implementation is correct)
    target
      area     : disk key, ssh secret key, keychain-master key, gnupg key password
      hardware : touchscreen, mobile, keyboard
    convinience
      general  : - (16 Chars)
      mobile   : + (only lowercase alphabet)
    out of scope:
      any password that can be stored in a password manager that is encrypted with a master password. (use random 64 to 120 Bit Entropy 13-24 Chars base32 output instead)

"""


def gen():

    consonants = "bcdfghjklmnpqrstvwxyz"
    vowels = "aeiou"
    generated = ""

    randdata = subprocess.check_output(["openssl", "rand", "9"])
    assert len(randdata) == 9
    bs = BitStream(randdata)

    generated += consonants[bs.read("int:5") % len(consonants)]
    for i in range(5):
        generated += vowels[bs.read("int:3") % len(vowels)]
        generated += consonants[bs.read("int:5") % len(consonants)]
        generated += consonants[bs.read("int:5") % len(consonants)]

    return generated


if __name__ == "__main__":
    print(gen())
