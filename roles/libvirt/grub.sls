# rationales:
# transparent_hugepage: http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf
# nohz: http://stackoverflow.com/questions/9775042/how-nohz-on-affects-do-timer-in-linux-kernel

libvirt-grub-settings:
  file.managed:
    - name: /etc/default/grub.d/libvirt.cfg
    - makedirs: true
    - contents: |
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nohz=off transparent_hugepage=always"

libvirt-update-grub:
  cmd.run:
    - name: update-grub
    - watch:
      - file: libvirt-grub-settings

