#!/usr/bin/env python3

"""
speakable friendly passwort generator

Produced Password Characteristics:
+ Password Size: 16 Character lowercase alphabet
+ Expected Entropy: 58 Bits= 4,25 * 11 + 2,25 * 5
+ Vowels Placing at Character: 2,5,8,11,14
+ unbiased and hopefully correct
    https://research.kudelskisecurity.com/2020/07/28/the-definitive-guide-to-modulo-bias-and-how-to-avoid-it/

Personal Metrics:
+ memorize:    ++ (pronounceable, no numbers, only lowercase)
+ security:     + (58 Bit if schema and implementation is correct)
+ convinience
    + general:  - (16 Chars)
    + mobile:   + (only lowercase alphabet)

Target Keys: disk key, ssh secret key, keychain-master key, gnupg password
Target Hardware: touchscreen, mobile, keyboard

Out of scope:
    any password stored in a keychain/password manager
    any machine password (use 64-120 Bit Entropy eq. 13-24 Chars base32)

"""

import os

try:
    from bitstring import BitStream
except ImportError:
    print("error: you need to install python package 'bitstring'")
    raise

consonants = "bcdfghjklmnpqrstvwxyz"
consonant_bits = 5
vowels = "aeiou"
vowel_bits = 3
vcc_rounds = 5
consonant_count = vcc_rounds * 2 + 1
vowel_count = vcc_rounds
batch_bytes_size = 8


def rand_val(bitsize, maximum, stream):
    # reject values if over maximum to avoid modulo bias
    valid_value = False
    while not valid_value:
        if (stream.len - stream.pos) < bitsize:
            stream.append(os.urandom(batch_bytes_size))
        data_int = stream.read("uint:{}".format(bitsize))
        if data_int < maximum:
            valid_value = True
    return data_int


def gen_phrase():
    bs = BitStream()
    generated = consonants[rand_val(consonant_bits, len(consonants), bs)]
    for i in range(vcc_rounds):
        generated += vowels[rand_val(vowel_bits, len(vowels), bs)]
        generated += consonants[rand_val(consonant_bits, len(consonants), bs)]
        generated += consonants[rand_val(consonant_bits, len(consonants), bs)]
    return generated


if __name__ == "__main__":
    print(gen_phrase())
