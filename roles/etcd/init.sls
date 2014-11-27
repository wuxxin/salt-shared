include:
  - golang

{% set user="etcd" %}
{% set home="/home/"+ user %}
{% set gopath=home+ "/go" %}

etcd:
  group:
    - present
    - name: {{ user }}
  user:
    - present
    - name: {{ user }}
    - gid: {{ user }}
    - home: {{ home }}
    - shell: /bin/bash
    - remove_groups: False
    - require:
      - group: etcd
  file.directory:
    - name: {{ gopath }}/bin
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True
    - require:
      - user: etcd
  git.latest:
    - name: https://github.com/coreos/etcd.git
    - rev: v0.4.6 
    - target: {{ gopath }}/src/github.com/coreos/etcd
    - user: {{ user }}
    - submodules: True
    - require:
      - file: etcd
      - pkg: golang
  cmd.wait:
    - cwd: {{ gopath }}/src/github.com/coreos/etcd
    - env:
      - GOPATH: "{{ gopath }}"
    - name: ./build && cp -r -t {{ gopath }} bin
    - user: {{ user }}
    - group: {{ user }}
    - watch:
      - git: etcd


go_profile:
  file.managed:
    - name: {{ home }}/.profile
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: etcd

go_profile-activate:
  file.append:
    - name: {{ home }}/.profile
    - text: |
        export GOPATH={{ gopath }}
        export PATH=${GOPATH}/bin:$PATH
    - require:
      - file: go_profile
