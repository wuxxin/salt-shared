# {% from 'arch/lib.sls' import aur_install with context %}

console-editor:
  pkg.installed:
    - pkgs:
      # helix - A post-modern modal text editor
      - helix
# {% load_yaml as pkgs %}
      # Fresh - A terminal text editor you can just use, A lightweight, fast terminal-based text editor with LSP support and TypeScript plugins
      - fresh-editor
# {% endload %}

# {{ aur_install('console-editor-aur', pkgs) }}

