include:
  - .ppa
  - .user
  
hamster-time-tracker:
  pkg.installed:
    - require:
      - cmd: hamster_ppa
