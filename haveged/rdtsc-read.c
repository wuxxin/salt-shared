#include <stdio.h>

#if defined(__i386__)

static __inline__ unsigned long long rdtsc(void)
{
        unsigned long long int x;

        __asm__ __volatile__ (".byte 0x0f, 0x31" : "=A" (x));
        return x;
}

#elif defined(__x86_64__)

static __inline__ unsigned long long rdtsc(void)
{
        unsigned hi, lo;

        __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
        return ( (unsigned long long)lo)|( ((unsigned long long)hi)<<32 );
}

#endif

int
main(void)
{
        long i;
        unsigned long long d;

        d = 0;
        for (i = 0; i < 1000000; i ++) {
                unsigned long long b, e;

                b = rdtsc();
                e = rdtsc();
                d += e - b;
        }
        printf("average : %.3f\n", (double)d / 1000000.0);
        return 0;
}
