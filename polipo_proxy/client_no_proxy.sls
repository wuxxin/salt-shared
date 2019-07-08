/etc/apt/apt.conf.d/02proxy:
  file:
    - absent

/etc/profile.d/proxy.sh:
  file:
    - absent

/etc/sudoers.d/proxy:
  file:
    - absent
