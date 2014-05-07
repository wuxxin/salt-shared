include:
  - packer
  - git


bento:
  git.latest:
    - name: https://github.com/opscode/bento.git
    - target: /home/packer/bento
    - runas: packer
    - submodules: True
    - require:
      - cmd: packer
      - pkg: git

 