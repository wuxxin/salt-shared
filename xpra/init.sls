include:
  - .ppa

websockify:
  pkg:
    - installed

xpra:
  pkg:
    - installed
  require:
    - pkg: websockify
    - pkgrepo: xpra_ppa
