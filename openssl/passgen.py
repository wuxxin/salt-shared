#!/usr/bin/env python

import subprocess
from bitstring import BitStream

"""
human friendly passwort generator:

  Final Product:
    Password Size: 16 Character lowercase alphabet
    Expected Entropy: 54-58 Bits: 4,25x11+2,25x5
    Vowels Placing: 2,5,8,11,14

  schema:

    Generate enough entropy: ~ 72 Bit = 9 Bytes source entropy needed

    Generate 11 Chars of Base 21 (a-z -a,e,i,o,u)
    using (5 Bit MOD 21 ) per char
    Used: 55 Bit

    Generate 5 Chars of Base 5 (a,e,i,o,u)
    using (3 Bit MOD 5) per Char
    Used: 15 Bit

    Total: 70 Bit Entropy used

  Personal Metrics:
    memorize: ++ (i can pronounce and hear the sound of it, no numbers, only lowercase)
    convinience: general: - (16 Chars) mobile: + (only lowercase alphabet)
    security: + (58Bit if analyze and implementation is correct)
    target area: disk encryption password, ssh secret key password, keychain key password, gpg key password
    target hardware: touchscreen, mobile, keyboard
    not applicable: any password that can be stored in a manager with a master password,
       you should use complete random 64 to 120 Bit Entropy 13-24 Chars base32 output instead

"""

def gen():

    consonants = "bcdfghjklmnpqrstvwxyz"
    vowels = "aeiou"

    randdata = subprocess.check_output(["openssl", "rand", "9"])
    assert len(randdata) == 9
    bs = BitStream(randdata)
    generated=""

    generated += consonants[bs.read('int:5') % len(consonants)]
    for i in range(5):
        generated += vowels[bs.read('int:3') % len(vowels)]
        generated += consonants[bs.read('int:5') % len(consonants)]
        generated += consonants[bs.read('int:5') % len(consonants)]

    return generated


if __name__ == '__main__':
    print(gen())
