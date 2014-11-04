include:
  - .init

gitlab-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/gitlab-vm; vagrant up
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: gitlab-vm


