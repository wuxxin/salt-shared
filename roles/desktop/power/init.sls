include:
  - .ppa

reenable_hibernate:
  file.managed:
    - name: /var/lib/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
    - contents: |
        [Re-enable hibernate by default in upower]
        Identity=unix-user:*
        Action=org.freedesktop.upower.hibernate
        ResultActive=yes

        [Re-enable hibernate by default in logind]
        Identity=unix-user:*
        Action=org.freedesktop.login1.hibernate
        ResultActive=yes

tlp:
  pkg.installed:
    - pkgs:
      - tlp
      - tlp-rdw
    - require:
      - pkgrepo: tlp-ppa

psensor:
  pkg:
    - installed
