

# set target: to targetdir
{% set target="/home/wuxxin/work/petit/salt/salt-shared/roles/imgbuilder/preseed/overlay" %}
{% set workdir=target+ "/../debs" %}

exists_targetdir:
  file.exists:
   - name: {{ target }}

create_workdir:
  file.directory:
    - name: {{ workdir }}
    - require:
      - file: exists_targetdir

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
    - cwd: {{ workdir }}
    - require:
      - file: create_workdir

{% for d in cs.additional_dpkg %}
unpack-{{ d }}:
  cmd.run:
    - name: dpkg-deb -X {{ workdir }}/{{ d }}*.deb {{ target }}
    - require:
      - file: create_workdir
    
{% endfor %}

tar_gz_overlay:
  cmd.run:
    - cwd: {{ workdir }}
    - name: tar czf ../overlay.tar.gz .
    - unless test -f ../overlay.tar.gz

{# 
patch_zcat_gunzip:
  cmd.run:
    - name: rm zcat; ln -s busybox zcat; rm gunzip; ln -s busybox gunzip
    - only_if: test -d {{ target }}/bin
    - cwd: {{ target }}/bin
    - require:
      - file: create_workdir
#}
