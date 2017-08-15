{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

xpra_ppa:
  pkgrepo.managed:
    - name: deb https://www.xpra.org/ {{ grains['lsb_distrib_codename'] }} main
    - file: /etc/apt/sources.list.d/xpra.list
    - key_url: "salt://xpra/gpg.asc"
    - require:
      - pkg: ppa_ubuntu_installer

# XXX: xpra.org hase some minor https quirks, we work around that because packages are signed
# XXX: we also set not to use a proxy to connect to xpra, because apt-cacher-ng fails in doing so
/etc/apt/apt.conf.d/40xpra-https-exception:
  file.managed:
    - contents: |
        Acquire::https::www.xpra.org::Verify-Peer "false";
        Acquire::https::proxy::www.xpra.org "DIRECT";

{% endif %}

xpra_nop:
  test:
    - nop
