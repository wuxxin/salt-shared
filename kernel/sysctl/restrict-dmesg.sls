{# This denies access to the messages in the kernel ring buffer.
   Please note that this will deny access to non-root users on the host system. #}
kernel.dmesg_restrict:
  sysctl.present:
    - value: 1 {# 0 #}
