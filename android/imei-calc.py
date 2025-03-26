#!/usr/bin/env python

import random
import sys


def luhn_checksum(number_string):
    """Calculates the Luhn checksum for a given number string."""

    # sum of odd-positioned digits (from right)
    digits = [int(d) for d in number_string]
    odd_sum = sum(digits[-2::-2])
    even_sum = 0
    # every second, starting from the last
    for d in digits[-1::-2]:
        d *= 2
        even_sum += d if d <= 9 else d - 9
        # sum_digits ( d//10 + d%10)
    total_sum = odd_sum + even_sum
    return (10 - (total_sum % 10)) % 10


def generate_imei(tac, serial=None):
    """Generates an IMEI-like number string with a valid Luhn checksum.

    Args:
        tac: The 8-digit TAC string.
        serial: Optional 6-digit serial string. If None, a random serial is generated.
    """

    if not tac.isdigit() or len(tac) != 8:
        raise ValueError("TAC must be an 8-digit string.")

    if serial is None:
        serial = "".join(random.choices("0123456789", k=6))
    elif not serial.isdigit() or len(serial) != 6:
        raise ValueError("Serial must be a 6-digit string.")

    number_without_checksum = tac + serial
    checksum = luhn_checksum(number_without_checksum)
    return number_without_checksum + str(checksum)


def main():
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("""Usage: python script.py <tac> [serial]
  tac:    8-digit Type Allocation Code
  serial: 6-digit serial number (Optional) 
            a random serial is generated If omitted
""")
        sys.exit(1)

    tac = sys.argv[1]
    serial = None
    if len(sys.argv) == 3:
        serial = sys.argv[2]

    try:
        imei = generate_imei(tac, serial)
        print(imei)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
