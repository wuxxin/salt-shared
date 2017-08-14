include:
  - .ppa

ansible:
  pkg:
    - installed
    - require:
      - test: ansible_nop

librarian-ansible:
  gem:
    - installed

