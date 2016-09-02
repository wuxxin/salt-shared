tmux:
  pkg:
    - installed

create_tmux_conf:
  file.managed:
    - name: /root/.tmux.conf
    - require:
      - pkg: tmux

modify_tmux_conf:
  file.append:
    - name: /root/.tmux.conf
    - text: |
        set -g terminal-overrides 'xterm*:smcup@:rmcup@'
        set -g terminal-overrides '*rxvt*:smcup@:rmcup@'
        set-window-option -g mode-mouse on
        set-option -g history-limit 10000
    - require:
      - file: create_tmux_conf

/root/.profile:
  file.append:
    - text: |
        if test -n "$PS1"; then
            if test $TERM != "screen"; then
                if tmux has; then tmux a; else tmux; fi
            fi
        fi
    - require:
      - pkg: tmux
