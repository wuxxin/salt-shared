{#
Domain Type  Item    Value     Default Description
*      soft  memlock unlimited unset   maximum locked-in-memory address space (KB)
*      hard  memlock unlimited unset   maximum locked-in-memory address space (KB)
#}

/etc/security/limits.d/memlock.conf:
  file.managed:
    - contents: |
        *         soft    memlock   unlimited
        *         hard    memlock   unlimited
