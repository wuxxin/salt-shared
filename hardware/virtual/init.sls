{% set allowed_api= [
  "guest-fsfreeze-freeze", "guest-fsfreeze-status", "guest-fsfreeze-thaw",
  "guest-fsfreeze-freeze-list", "guest-fstrim", "guest-get-host-name",
  "guest-get-vcpus", "guest-network-get-interfaces", "guest-set-vcpus",
  "guest-sync", "guest-sync-delimited", "guest-ping", "guest-get-time",
  "guest-set-time", "guest-get-timezone", "guest-shutdown", "guest-suspend-disk"
  ]
%}
{% set blacklisted_api= [
  "guest-exec", "guest-exec-status", "guest-file-close", "guest-file-flush",
  "guest-file-open", "guest-file-read", "guest-file-seek", "guest-file-write",
  "guest-get-fsinfo", "guest-get-memory-block-info", "guest-get-memory-blocks",
  "guest-get-osinfo", "guest-get-users", "guest-info", "guest-set-memory-blocks",
  "guest-set-user-password", "guest-suspend-hybrid", "guest-suspend-ram"
  ]
%}

{% if grains['virtual'] in ['kvm', 'qemu', 'xen'] %}

/etc/default/qemu-guest-agent:
  file.managed:
    - makedirs: true
    - contents: |
        [general]
        blacklist={{ ",".join(blacklisted_api) }}

qemu-guest-agent:
  pkg:
    - installed

spice-vdagent:
  pkg:
    - installed

{% elif grains['virtual'] == 'VirtualBox' %}

virtualbox-guest-dkms:
  pkg:
    - installed

{% elif grains['virtual'] == 'VMware' %}

open-vm-tools:
  pkg:
    - installed

{% endif %}
