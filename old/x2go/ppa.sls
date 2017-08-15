{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %}


{% if grains['os'] == 'Debian' %}
x2go_ppa:
  pkgrepo.managed:
    - name: deb http://packages.x2go.org/debian {{ grains['lsb_distrib_codename'] }} main
    - humanname: "Debian X2go Repository"
    - file: /etc/apt/sources.list.d/x2go.list
    - keyid: E1F958385BFE2B6E
    - keyserver: keys.gnupg.net

{% elif grains['os'] == 'Ubuntu' %}
x2go_ppa:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/x2go/stable/ubuntu {{ grains['lsb_distrib_codename'] }} main
    - humanname: "Ubuntu X2go Repository"
    - file: /etc/apt/sources.list.d/x2go.list
    - keyid: a7d8d681b1c07fe41499323d7cde3a860a53f9fd
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer

{% elif grains['os'] in ['RedHat', 'CentOS'] %}
x2go_ppa:
  pkgrepo.managed:
    - name: "X11:RemoteDesktop:x2go.repo"
    - humanname: X11_RemoteDesktop_x2go
    - baseurl: http://download.opensuse.org/repositories/X11:/RemoteDesktop:/x2go/RHEL_6/
    - gpgkey: http://download.opensuse.org/repositories/X11:/RemoteDesktop:/x2go/RHEL_6/repodata/repomd.xml.key
    - gpgcheck: 1
{% endif %}

x2go_nop:
  test:
    - nop
