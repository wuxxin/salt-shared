{# https://cloud.google.com/compute/docs/images/building-custom-os#kernelsecurity #}

# Enable syn flood protection
net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

# Ignore source-routed packets
net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0

# Ignore source-routed packets
net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects:
  sysctl.present:
    - value: 0

# Ignore ICMP redirects
net.ipv4.conf.default.accept_redirects:
  sysctl.present:
    - value: 0

# Ignore ICMP redirects from non-GW hosts
net.ipv4.conf.all.secure_redirects:
  sysctl.present:
    - value: 1

# Ignore ICMP redirects from non-GW hosts
net.ipv4.conf.default.secure_redirects:
  sysctl.present:
    - value: 1

# Don't allow traffic between networks or act as a router
net.ipv4.ip_forward:
  sysctl.present:
    - value: 0

# Don't allow traffic between networks or act as a router
net.ipv4.conf.all.send_redirects:
  sysctl.present:
    - value: 0

# Don't allow traffic between networks or act as a router
net.ipv4.conf.default.send_redirects:
  sysctl.present:
    - value: 0

# Reverse path filtering&mdash;IP spoofing protection
net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1

# Reverse path filtering&mdash;IP spoofing protection
net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 1

# Ignore ICMP broadcasts to avoid participating in Smurf attacks
net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1

# Ignore bad ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses:
  sysctl.present:
    - value: 1

# Log spoofed, source-routed, and redirect packets
net.ipv4.conf.all.log_martians:
  sysctl.present:
    - value: 1

# Log spoofed, source-routed, and redirect packets
net.ipv4.conf.default.log_martians:
  sysctl.present:
    - value: 1

# Implement RFC 1337 fix
net.ipv4.tcp_rfc1337:
  sysctl.present:
    - value: 1
