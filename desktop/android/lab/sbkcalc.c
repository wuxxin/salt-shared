#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>


uint32_t
swab32 (uint32_t src)
{
  uint32_t dst;
  int i;

  dst = 0;
  for (i = 0; i < 4; i++)
  {
    dst = (dst << 8) + (src & 0xFF);
    src >>= 8;
  }
  return dst;
}


int
main (int argc, char *argv[])
{
  char uid[16], *p;
  uint32_t sbk[4];
  int i, j, mult;

  while (--argc)
  {
    p = argv[argc];
    if (p[0] == '0' && p[1] == 'x')
      p += 2;
    if (strlen (p) != 16)
      continue;
    strncpy (uid, p + 8, 8);
    strncpy (uid + 8, p, 8);
    for (i = 0; i < 16; i++)
      uid[i] = toupper (uid[i]);

    memset (sbk, 0, sizeof (sbk));

    for (i = 0; i < 4; i++)
    {
      sbk[i] = 0;
      mult = 1;
      for (j = 3; j >= 0; j--)
      {
        sbk[i] += uid[4*i+j] * mult;
        mult *= 100;
      }
    }
    for (i = 0; i < 4; i++)
      sbk[i] ^= sbk[3 - i];

    printf ("0x%08X 0x%08X 0x%08X 0x%08X\n",
        swab32 (sbk[0]), swab32 (sbk[1]), swab32 (sbk[2]), swab32 (sbk[3]));
  }

  exit (0);
}
