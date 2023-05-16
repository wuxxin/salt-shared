base:

  # physical machine
  'virtual:physical':
    - match: grain
    - kernel
    - hardware

  # virtual machine
  'P@virtual:(?!physical)':
    - match: compound
    - kernel
    - virtual

  # any machine with a kernel (no container virtualization)
  '* and not ( P@virtual:lxc or P@virtual:systemd-nspawn )':
    - match: compound
    - kernel.entropy

  # any
  '*':
    - node
    - tools

  # main states
  # to disable main states, add pillar='{"disable_main": true}' to execution
  'not I@disable_main:true':
    - match: compound
    - main
