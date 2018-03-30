# enable cgroup memory and swap accounting

docker-grub-settings:
  file.managed:
    - name: /etc/default/grub.d/docker.cfg
    - makedirs: true
    - contents: |
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX cgroup_enable=memory swapaccount=1"

docker-update-grub:
  cmd.run:
    - name: update-grub
    - watch:
      - file: docker-grub-settings

