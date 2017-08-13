# KVM: vm.swappiness = 0 The kernel will swap only to avoid an out of memory condition
# Rationale: memory is given to the other domains, so we dont want the host to swap guest memory
vm.swappiness:
  sysctl.present:
    - value: 0

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt-bin
      - qemu-kvm
      - qemu-utils
      - cgroup-bin
      - bridge-utils
  service.running:
    - name: libvirt-bin
    - enable: True
    - require:
      - pkg: libvirt

{#
default-kvm-settings:
  file.managed:
    - name: /etc/default/qemu-kvm
    - contents: |
        # To disable qemu-kvm's page merging feature, set KSM_ENABLED=0 and restart qemu-kvm
        KSM_ENABLED=1
        SLEEP_MILLISECS=200
        # To load the vhost_net module, which in some cases can speed up
        # network performance, set VHOST_NET_ENABLED to 1.
        VHOST_NET_ENABLED=1
        # Set this to 1 if you want hugepages to be available to kvm under
        # /run/hugepages/kvm
        KVM_HUGEPAGES=1
    - require:
      - pkg: libvirt

# transparent_hugepage: http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf
# nohz: http://stackoverflow.com/questions/9775042/how-nohz-on-affects-do-timer-in-linux-kernel
libvirt-grub-settings:
  file.managed:
    - name: /etc/default/grub.d/libvirt.cfg
    - makedirs: true
    - contents: |
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nohz=off transparent_hugepage=always"
  cmd.wait:
    - name: update-grub
    - watch:
      - file: libvirt-grub-settings

      # KVM: useful for same page merging and huge pages on guest
      #vm.zone_reclaim_mode:
      #  sysctl.present:
      #    - value: 0
      # disable netfilter arptables on linux bridges
      #net.bridge.bridge-nf-call-arptables:
      #  sysctl.present:
      #    - value: 0
#}
