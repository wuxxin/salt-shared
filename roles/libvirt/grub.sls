# rationales:
# transparent_hugepage: http://www.linux-kvm.org/wiki/images/9/9e/2010-forum-thp.pdf
# nohz: http://stackoverflow.com/questions/9775042/how-nohz-on-affects-do-timer-in-linux-kernel

grub-settings:
  file.append:
    - name: /etc/default/grub
    - text: 'GRUB_CMDLINE_LINUX_DEFAULT="text nosplash nomodeset nohz=off transparent_hugepage=always"'
grub-settings2:
  file.append:
    - name: /etc/default/grub
    - text: 'GRUB_CMDLINE_LINUX="text nosplash nomodeset nohz=off transparent_hugepage=always"'

update-grub:
  cmd.run:
    - name: update-grub
    - require:
      - file.append: grub-settings
      - file.append: grub-settings2

