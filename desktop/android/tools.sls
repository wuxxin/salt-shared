include:
  - python

android-tools:
  pkg.installed:
    - pkgs:
{%- if grains['osmajorrelease']|int < 18 %}
      - android-tools-adb
      - android-tools-fastboot
{%- else %}
      - adb
      - fastboot
{%- endif %}
      - android-tools-adbd
      - aapt

{% from 'python/lib.sls' import pip3_install %}
{{ pip3_install('adb') }}

heimdall:
  pkg.installed:
    - pkgs:
      - heimdall-flash
      - heimdall-flash-frontend
