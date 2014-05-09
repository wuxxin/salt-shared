include:
  - packer
  - git


basebox-packer:
  git.latest:
    - name: https://github.com/misheska/basebox-packer.git
    - target: /home/imgbuilder/basebox-packer
    - user: imgbuilder
    - submodules: True
    - require:
      - cmd: packer
      - pkg: git

bento:
  git.latest:
    - name: https://github.com/opscode/bento.git
    - target: /home/imgbuilder/bento
    - user: imgbuilder
    - submodules: True
    - require:
      - cmd: packer
      - pkg: git

 