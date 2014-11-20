vagrant:
  pkg.installed:
    - sources:
{% if grains.osarch == "amd64" %}
      - vagrant: https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
{% elif grains.osarch == "i386" %}
      - vagrant: https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_i686.deb
{% endif %}

