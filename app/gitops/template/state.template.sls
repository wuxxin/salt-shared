base:

  # physical machine
  'virtual:physical':
    - match: grain
    - hardware

  # virtual machine
  'P@virtual:(?!physical)':
    - match: compound
    - hardware.virtual

  # any
  '*':
    - node

  # main states
  # to disable main states, add pillar='{"disable_main": true}' to execution
  'not I@disable_main:true':
    - match: compound
    - main
