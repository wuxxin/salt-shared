include:
  - code.asm
  - code.go
  - code.java
  - code.nodejs
  - code.python
  - code.rust

languages_nop_req:
  test:
    - nop
    - require:
      - sls: code.asm
      - sls: code.go
      - sls: code.java
      - sls: code.nodejs
      - sls: code.python
      - sls: code.rust

linker-mold:
  pkg.installed:
    - pkgs:
      # mold - A Modern Linker
      - mold
