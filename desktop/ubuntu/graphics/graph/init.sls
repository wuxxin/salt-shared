graph:
  pkg.installed:
    - pkgs:
      - graphviz
      - plantuml
{% for p in ['blockdiag', 'actdiag', 'nwdiag', 'seqdiag',] %}
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-{{ p }}
{% endfor %}
