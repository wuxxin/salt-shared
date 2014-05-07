include:
  - packer
  - git


basebox-packer:
  git.latest:
    - name: https://github.com/misheska/basebox-packer.git
    - target: /home/packer/basebox-packer
    - runas: packer
    - submodules: True
    - require:
      - cmd: packer
      - pkg: git
 