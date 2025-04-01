language-asm:
  pkg.installed:
    - pkgs:
      # nasm - 80x86 assembler designed for portability and modularity
      - nasm

language-javascript:
  pkg.installed:
    - pkgs:
      # nodejs - Evented I/O for V8 javascript ("Current" release)
      - nodejs
      # npm - JavaScript package manager
      - npm
      # eslint - AST-based pattern checker for JavaScript
      - eslint

language-go:
  pkg.installed:
    - pkgs:
      # go - Core compiler tools for the Go programming language
      - go

language-java:
  pkg.installed:
    - pkgs:
      # jdk-openjdk - OpenJDK Java development kit
      - jdk-openjdk
      # java-rhino - Open-source implementation of JavaScript written entirely in Java
      - java-rhino
      # ant - Java based build tool
      - ant

language-rust:
  pkg.installed:
    - pkgs:
      # rust - Systems programming language focused on safety, speed and concurrency
      - rust
      # rust-analyzer - Rust compiler front-end for IDEs
      - rust-analyzer

linker-mold:
  pkg.installed:
    - pkgs:
      # mold - A Modern Linker
      - mold


