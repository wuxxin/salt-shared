ansible:
  pkgrepo.managed:
    - ppa: rquillo/ansible
  pkg.installed:
    - require:
      - pkgrepo: ansible

