# {% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}

ups_tools:
  pkg.installed:
    - name: nut

{# make the qoltec ups appear as ups-qoltec with owner nut #}
/etc/udev/rules.d/99-qoltec-ups.rules:
  file.managed:
    - makedirs: true
    - contents: |
        SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="ups-qoltec", OWNER="nut", GROUP="nut", MODE="0660"
    - require:
      - pkg: ups_tools

/etc/nut/ups.conf:
  file.append:
    - makedirs: true
    - text: |
        [ups-qoltec]
            driver = nutdrv_qx
            port = /dev/ups-qoltec
            desc = "Qoltec 53980 UPS"
            protocol = q1
    - require:
      - pkg: ups_tools

# aur_install('ups_tools_aur', ['ups-monitor'])
