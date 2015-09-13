{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}
{% set workdir= user_home+ '/.caffe' %}

include:
  - python.dev
  - roles.desktop.scipy

caffe_req:
  pkg.installed:
    - pkgs:
      - libprotobuf-dev
      - libleveldb-dev
      - libsnappy-dev
      - libopencv-dev
      - libhdf5-serial-dev
      - protobuf-compiler
      - libgflags-dev
      - libgoogle-glog-dev
      - liblmdb-dev
      - libatlas-base-dev

caffe_no_recommends_req:
  pkg.installed:
    - name: libboost-all-dev
    - install_recommends: False

caffe_profile:
  file.blockreplace:
    - name: {{ user_home }}/.profile
    - marker_start: "# caffe - config - begin"
    - marker_end: "# caffee - config - end"
    - append_if_not_found: True
    - content: |
        export PYTHONPATH={{ workdir }}:$PYTHONPATH
    - user: {{ user }}

caffe:
  git.latest:
    - name: https://github.com/BVLC/caffe.git
    - target: {{ workdir }}
    - user: {{ user }}
    - require:
      - sls: python.dev
      - sls: roles.desktop.scipy
      - pkg: caffe_req
      - pkg: caffe_no_recommends_req
      - file: caffe_profile

create_Makefile:
  file.copy:
    - name: {{ workdir }}/Makefile.config
    - source: {{ workdir }}/Makefile.config.example
    - preserve: true
    - require:
      - git: caffe

modify_Makefile:
  file.uncomment:
    - name: {{ workdir }}/Makefile.config
    - regex: "CPU_ONLY := 1"
    - backup: false
    - require:
      - file: create_Makefile

compile_caffe:
  cmd.run:
    - name: make all -j 4 && make pycaffe
    - cwd: {{ workdir }}
    - user: {{ user }}
    - require:
      - file: modify_Makefile
