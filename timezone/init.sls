SystemTimezone:
  timezone.system:
    - name: {{ pillar['timezone'] }}
    - utc: True
