{% if grains['virtual'] in ['kvm', 'qemu', 'xen'] %}

spice-vdagent:
  pkg:
    - installed

qemu-guest-agent:
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
