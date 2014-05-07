tmux:
  pkg:
    - installed

create_tmux_conf:
  file:
    - touch
    - name: /root/.tmux.conf
    - require:
      - pkg: tmux

modify_tmux_conf:
  file.append:
    - name: /root/.tmux.conf
    - text: set -g terminal-overrides 'xterm*:smcup@:rmcup@'
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

