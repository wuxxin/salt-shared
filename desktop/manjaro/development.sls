include:
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.python

desktop_manjaro_dev_packages:
  pkg.installed:
    - pkgs:
      # Invoke the upgrade procedure of multiple package managers
      - topgrade
  test:
    - nop
