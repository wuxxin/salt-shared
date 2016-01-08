include:
  - .ppa

websockify:
  pkg:
    - installed

xpra:
  pkg.installed:
    - pkgs:
      - xpra
      - websockify
      - python-gst-1.0
  require:
    - pkgrepo: xpra_ppa
