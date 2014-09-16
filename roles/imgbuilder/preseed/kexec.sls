kexec-boot:
  pkg.installed:
    - pkgs:
      - kexec-tools
      - syslinux
      - extlinux
      - whois
