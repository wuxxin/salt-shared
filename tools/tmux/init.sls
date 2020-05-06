tmux:
  pkg:
    - installed
{% set marker = "# saltstack tmux automatic config" %}
{% set start = marker+ " start" %}
{% set end = marker+ " end" %}

create_tmux_conf:
  file.touch:
    - name: /root/.tmux.conf

/root/.tmux.conf:
  file.blockreplace:
    - marker_start: "{{ start }}"
    - marker_end: "{{ end }}"
    - content: |
        set -g terminal-overrides 'xterm*:smcup@:rmcup@'
        set -g terminal-overrides '*rxvt*:smcup@:rmcup@'
        set-option -g mouse on
        set-option -g history-limit 10000
    - append_if_not_found: True
    - require:
      - pkg: tmux

create_root_profile:
  file.touch:
    - name: /root/.profile

/root/.profile:
  file.blockreplace: {# XXX file.blockreplace does use "content" instead of "contents" #}
    - marker_start: "{{ start }}"
    - marker_end: "{{ end }}"
    - content: |
        if test -n "$PS1"; then
            if test $TERM != "screen"; then
                if tmux has; then tmux a; else tmux; fi
            fi
        fi
    - append_if_not_found: True
    - require:
      - pkg: tmux
