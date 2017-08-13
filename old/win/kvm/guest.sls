kvm_guest:
  pkg:
    - installed
    - require:
      - cmd: testsigning_on

testsigning_on:
  cmd.run:
    - name: 'c:\Windows\system32\bcdedit.exe -set TESTSIGNING ON'

testsigning_off:
  cmd.run:
    - name: 'C:\Windows\system32\bcdedit.exe -set TESTSIGNING OFF'
    - require:
      - pkg: kvm_guest

