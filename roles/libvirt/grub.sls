grub-settings:
  file.append:
    - name: /etc/default/grub
    - text: 'GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,9600n8 console=tty0 text nosplash nomodeset nohz=off transparent_hugepage=always"'
grub-settings2:
  file.append:
    - name: /etc/default/grub
    - text: 'GRUB_CMDLINE_LINUX="console=ttyS0,9600n8 console=tty0 text nosplash nomodeset nohz=off transparent_hugepage=always"'

update-grub:
  cmd.run:
    - name: update-grub
    - require:
      - file.append: grub-settings
      - file.append: grub-settings2

