sleep_off:
  cmd.run:
    - name: "powercfg -change -standby-timeout-ac 0"
