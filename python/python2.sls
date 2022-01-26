python2:
  pkg.installed:
    - pkgs:
      - python2.7

pip2-upgrade:
  cmd.run:
    # pip 21.x borks on install
    - name: pip2 install -U "pip<21" virtualenv
    - onlyif: test "$(which pip2)" = "/usr/bin/pip2"
