{% from "preseed/defaults.jinja" import defaults as ps_set%}
{% from 'preseed/lib.sls' import netboot_source, netboot_cmdline %}

{% set unittest= false %}
{% set username= "username"}
{% set hostname= "hostname" %}
{% set architecture= "amd64" %}
{% set suite= "xenial" %}

{% load_yaml as updates %}

target: '/opt/{{ hostname }}'

suite: {{ suite }}
architecture: {{ architecture }}
{{ netboot_source ("http://archive.ubuntu.com/ubuntu/dists/", suite, "-updates", "amd64", "hwe-netboot/ubuntu-installer", "20101020ubuntu451.14") %}
netboot_kernel_hash: "sha256=4985520127e08573ab2df58226604e5595833cb3d48d41d40dfe99a79c7d057b"
netboot_initrd_hash: "sha256=fe85c13124032498e5cc8fae2d8f71486bb3176755f7670d9afaf4cdd41225a6"
{{ netboot_cmdline (hostname) }}

username: {{ hostname }}
hostname: {{ hostname }}
domainname: 'domainname.local'

netcfg:
{% if unittest == true %}
  ip: '192.168.121.139'
  netmask: '255.255.255.0'
  gateway: '192.168.121.1'
{% else %}
  ip: '5.9.61.139'
  netmask: '255.255.255.224'
  gateway: '5.9.61.129'
{% endif %}
  dns: '8.8.8.8'

apt_proxy_mirror: '' {# we clear proxy_mirror because at the time of installing, proxy_mirror is not active #}

disks: '/dev/vda'
diskpassword_receiver_key: 'salt://example/root@example.public.gpg.asc'
diskpassword_receiver_id: 'root@example'
default_preseed: 'preseed-custom-console.cfg'

custom_ssh_identity: ''
custom_files:
  '/.ssh/authorized_keys': 'salt://example/example.pub'
{% if unittest != true %}
  '/tmp/custom_part.env': 'salt://example/custom_part.env'
{% endif %}
  '/watch': 'salt://preseed/files/watch'
{% endload %}
{% do ps_set.update(updates) %}


{% from 'preseed/lib.sls' import preseed_make with context %}
{{ preseed_make(ps_set) }}

{% from 'preseed/iso.sls' import mk_install_iso with context %}
{{ mk_install_iso(ps_set) }}

{% for a in ('Vagrantfile', 'README.md',) %}
machine-copy-{{ a }}:
  file.managed:
    - source: "salt://example/{{ a }}"
    - name: {{ ps_set.target }}/{{ a }}
    - user: {{ username }}
    - group: {{ username }}
    - mode: 700
    - template: jinja
    - context:
        target: {{ ps_set.target }}
        cmdline: {{ ps_set.cmdline }}
        hostname: {{ ps_set.hostname|d(" ") }}
        custom_ssh_identity: {{ ps_set.custom_ssh_identity|d(None) }}
{% endfor %}
