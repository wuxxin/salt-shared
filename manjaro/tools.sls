cmdline-tools:
  pkg.installed:
    - pkgs:
      # network monitor
      - nload
      - bmon
      - iftop
      # disk io monitor
      - atop
      - dstat
      # lfs - modern df replacement
      - lfs
      # pueue - task management for sequential and parallel execution of long-running tasks
      - pueue
