{#
+ https://virtio-fs.gitlab.io/howto-qemu.html
  + requisites
    + kernel 5.4+
    + QEMU 5.0+ (included in kata-containers 1.9+)
    + kata-containers 1.9+
    + libvirt 6.2+ if libvirt support is needed
  + remark
    + ppa:jacob/virtualisation has qemu 5.0 and libvirt 6.6
#}

{% set branch = 'master' %}
{% set baseurl = 'http://download.opensuse.org/repositories/home:/katacontainers:/releases:/' ~
    grains['cpuarch'] ~ ':/' ~ branch ~ '/xUbuntu_' ~ grains['osrelease'] %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 "'+
  baseurl+ '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

kata-containers:
  pkgrepo.managed:
    - name: deb {{ baseurl }}/ /
    - key_url: {{ baseurl }}/Release.key
    - file: /etc/apt/sources.list.d/kata_containers_ppa.list
    - require_in:
      - pkg: kata-containers
  pkg.installed:
    - pkgs:
      - kata-runtime

{% endif %}
