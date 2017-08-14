include:
  - .init

gitlab-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/gitlab-vm; vagrant up
    - runas: imgbuilder
    - require:
      - cmd: gitlab-vm


