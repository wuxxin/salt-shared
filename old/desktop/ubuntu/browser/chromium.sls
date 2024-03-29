
{# since 19.10 chromium is no longer available as deb package from ubuntu, therefore get from ppa #}
{%- set baseurl =
'https://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_'+
grains['oscodename'].title() %}

{%- if grains['oscodename'] == 'focal' and
    salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
      baseurl+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"',
      python_shell=true) == 0 %}

chromium_ppa:
  pkgrepo.managed:
    - name: deb {{ baseurl }}/ /
    - key_url: {{ baseurl }}/Release.key
    - file: /etc/apt/sources.list.d/chromium_ppa.list
    - require_in:
      - pkg: chromium-browser

chromium-browser:
  pkg.installed:
    - pkgs:
      - ungoogled-chromium
      - ungoogled-chromium-driver

{%- else %}

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser
      {{ '- chromium-chromedriver' if grains['os'] == 'Ubuntu' }}

{%- endif %}
