vagrant:
  pkg.installed:
    - sources:
{% if grains.osarch == "amd64" %}
      - vagrant: https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
      # https://dl.bintray.com/mitchellh/vagrant/vagrant_1.5.3_x86_64.deb
      # https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
      # 
{% elif grains.osarch == "i386" %}
      - vagrant: https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_i686.deb
      # https://dl.bintray.com/mitchellh/vagrant/vagrant_1.5.3_i686.deb
      # https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_i686.deb
      # 
{% endif %}

