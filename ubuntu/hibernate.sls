polkit_hibernate_enable:
  file.managed:
    - name: /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
    - makedirs: True
    - contents: |
        [Re-enable hibernate by default in upower]
        Identity=unix-user:*
        Action=org.freedesktop.upower.hibernate
        ResultActive=yes

        [Re-enable hibernate by default in logind]
        Identity=unix-user:*
        Action=org.freedesktop.login1.hibernate
        ResultActive=yes

handle_lidswitch_hibernate:
  file.replace:
    - name: /etc/systemd/logind.conf
    - append_if_not_found: true
    - pattern: ^HandleLidSwitch=.*
    - repl: HandleLidSwitch=hibernate
    - unless: pm-is-supported --suspend-hybrid
    - require:
      - pkg:
        - suspend_support

handle_lidswitch_hibernate_hybrid:
  file.replace:
    - name: /etc/systemd/logind.conf
    - append_if_not_found: true
    - pattern: ^HandleLidSwitch=.*
    - repl: HandleLidSwitch=hybrid-sleep
    - onlyif: pm-is-supported --suspend-hybrid
    - require:
      - pkg:
        - suspend_support
