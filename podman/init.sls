include:
  - ubuntu

{% set baseurl =
  'https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_'+
  grains['osrelease'] %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
  baseurl+ '/InRelease" | grep -q "200 OK"', python_shell=true) == 0 %}

podman:
  pkgrepo.managed:
    - name: deb {{ baseurl }}/ /
    - key_url: {{ baseurl }}/Release.key
    - file: /etc/apt/sources.list.d/podman_ppa.list
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: podman
  pkg.installed:
    - pkgs:
      - podman

{% endif %}
