include:
  - .init

{% if pillar.windows_packages_remove|d(false) %}
  {% for p in pillar['windows_packages_remove'] %}

win_remove_{{ p }}:
  cmd.run:
    - shell: cmd
    - cwd: c:\Chocolatey\bin
    - name: c:\Chocolatey\chocolateyinstall\chocolatey.cmd uninstall {{ p }}
    {#  -y  #}
    - require:
      - cmd: chocolatey_install

  {% endfor %}
{% endif %}
