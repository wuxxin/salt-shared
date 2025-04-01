include:
  - development.asm
  - development.go
  - development.java
  - development.nodejs
  - development.python
  - development.rust

languages_nop_req:
  test:
    - nop
    - require:
      - sls: development.asm
      - sls: development.go
      - sls: development.java
      - sls: development.nodejs
      - sls: development.python
      - sls: development.rust

linker-mold:
  pkg.installed:
    - pkgs:
      # mold - A Modern Linker
      - mold
