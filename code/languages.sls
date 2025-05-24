include:
  - code.asm
  - code.go
  - code.java
  - code.javascript
  - code.python.dev
  - code.rust

languages_nop_req:
  test:
    - nop
    - require:
      - sls: code.asm
      - sls: code.go
      - sls: code.java
      - sls: code.javascript
      - sls: code.python.dev
      - sls: code.rust

cross-compiler-arm:
  pkg.installed:
    - pkgs:
      - arm-none-eabi-binutils
      - arm-none-eabi-gcc
      - arm-none-eabi-newlib

linker-mold:
  pkg.installed:
    - pkgs:
      # mold - A Modern Linker
      - mold
