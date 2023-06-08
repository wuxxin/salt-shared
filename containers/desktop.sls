{% from "containers/defaults.jinja" import settings with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - containers

{% for n in 'subuid', 'subgid' %}
add_{{ n }}_to_user_{{ user }}:
  file.append:
    - name: /etc/{{ n }}
    - text: |
        {{ user }}:100000:65536
{% endfor %}

{% if grains['os'] == 'Ubuntu' %}

x11docker-tools:
  pkg.installed:
    - pkgs: {{ settings.pkg.ubuntu.desktop }}

# snapshot (6.9.1-beta-1) at 038af50b3389ceaecf5916b29f3bc21ae5c613de
# https://github.com/mviereck/x11docker
x11docker:
  file.managed:
    - source: salt://containers/tools/x11docker
    - name: /usr/local/bin/x11docker
    - mode: "755"
    - require:
      - pkg: x11docker-tools


{% elif grains['os'] == 'Manjaro' %}
  {% from 'aur/lib.sls' import aur_install, pamac_patch_install, pamac_patch_install_dir with context %}

x11docker-tools:
  pkg.installed:
    - pkgs: {{ settings.pkg.manjaro.desktop }}

{{ aur_install("x11docker", ["x11docker"], require="pkg: x11docker-tools") }}

{% endif %}
