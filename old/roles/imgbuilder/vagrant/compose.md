image:
build: path to vagrant file
vagrantfile: path to vagrant file
command: overwrite the default command
links:
 - first
 - db:database
 - redis
external_links:
extra_hosts:
ports:
expose:
volumes:
volumes_from:
environment:
env_file:
extends:
labels:
container_name
log_driver
net:
pid:
dns:
cap_add, cap_drop
dns_search
devices
security_opt

see docker run:
working_dir, entrypoint, user, hostname, domainname, mac_address, mem_limit, memswap_limit, privileged, restart, stdin_open, tty, cpu_shares, cpuset, read_only, volume_driver


compose:
  build
  kill
  ps
  restart
  run
  start
  up
  logs
  pull
  port
  rm
  scale
  stop
