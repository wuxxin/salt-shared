/etc/security/limits.d/maxfiles.conf:
  file.managed:
    - contents: |
        #<domain> <type>  <item>    <value>
        *         soft    nofile    1048576
        *         hard    nofile    1048576
        root      soft    nofile    1048576
        root      hard    nofile    1048576
