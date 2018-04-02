{# XXX samba breaks on lxc/lxd because of xattr container limits #}

patch-ntacls.py:
  file.managed:
    - name: /usr/lib/python2.7/dist-packages/samba/ntacls.py
    - source: salt://lab/appliance/zentyal/files/ntacls.py
    - makedirs: true
  cmd.run:
    - name: rm /usr/lib/python2.7/dist-packages/samba/ntacls.pyc; python2 -c "import compileall; compileall.compile_file('/usr/lib/python2.7/dist-packages/samba/ntacls.py')"
    - onchanges:
      - file: patch-ntacls.py
