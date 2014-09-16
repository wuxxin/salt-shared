

# set target: to targetdir
{% set target="/srv/salt/custom/roles/imgbuilder/preseed/overlay" %}
{% set workdir=target+ "/../debs" %}

exists-targetdir:
  file.exists:
   - name: {{ target }}

create-workdir:
  file.directory:
    - name: {{ workdir }}

{% load_yaml as cs %}
additional_dpkg:
  - 'libgcc1'
  - 'libstdc++6'
  - 'libevent-2.0-5'
  - 'libncursesw5'
  - 'libtinfo5'
  - 'libhavege1'
  - 'haveged'
  - 'tmux'
{% endload %}

# download debs to workdir
download-debs:
  cmd.run:
    - name: cd {{ workdir }}; apt-get -y  download {% for p in cs.additional_dpkg %}{{ p }} {% endfor %}

{% for d in cs.additional_dpkg %}
unpack-{{ d }}:
  cmd.run:
    - name: dpkg-deb -X {{ workdir }}/{{ d }}*.deb {{ target }}
{% endfor %}


patch_zcat_gunzip:
  cmd.run:
    - name: rm zcat; ln -s busybox zcat; rm gunzip; ln -s busybox gunzip
    - only_if: test -d {{ target }}/bin
    - cwd: {{ target }}/bin
