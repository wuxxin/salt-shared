{#
This file contains the maximum number of memory map areas a process
may have. Memory map areas are used as a side-effect of calling
malloc, directly by mmap, mprotect, and madvise, and also when loading
shared libraries.

While most applications need less than a thousand maps, certain
programs, particularly malloc debuggers, may consume lots of them,
e.g., up to one or two maps per allocation.

needed for kubernet workloads, eg. elasticsearch.

Elasticsearch uses a mmapfs directory by default to store its indices. The default operating system limits on mmap counts is likely to be too low, which may result in out of memory exceptions. 
#}

vm.max_map_count:
  sysctl.present:
    - value: 262144 {# 65530 #}
