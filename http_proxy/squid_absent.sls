squid:
  service:
    - dead
  pkg:
    - removed

/var/cache/squid:
  file:
    - absent
