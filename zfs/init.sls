{% from "zfs/defaults.jinja" import settings with context %}

include:
  - nfs.server
  - zfs.autosnapshot

zfsutils-linux:
  pkg.installed:
    - require:
      - sls: nfs.server

/etc/modprobe.d/zfs.conf:
  file.managed:
    - contents: |
        options zfs zfs_vdev_scheduler={{ settings.vdev_scheduler }}
        options zfs zfs_arc_max={{ settings.arc_max_bytes }}

{#

{% for f in ['build_from_lp.sh', 'customize-running-system.sh'] %}
/etc/recovery/zfs/{{ f }}:
  file.managed:
    - source: salt://machine-bootstrap/{{ f }}
    - filemode: "0755"
    - makedirs: true
{% endfor %}

+ set scrub non linear, for 6 weeks every 14days on sunday, then twice per year
  + default: Scrub the second Sunday of every month.
  +  24 0 8-14 * * root [ $(date +\%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ] && /usr/lib/zfs-linux/scrub

+ write out zfs patches somewhere ?

{% for p in salt['cmd.run_stdout'](
  'find '+ grains['project_basepath']+
    '/machine-bootstrap/zfs/ -name "*.patch" -type f -printf "%f\n" | sort -n',
  python_shell=True) %}
/etc/recovery/zfs/{{ p }}
  file.managed:
    - source: salt://machine-bootstrap/zfs/{{ p }}
{% endfor %}

if zfs:custom-build:enabled: true
  + test which customized zfs we have in custom archive
    + if there is a newer version (or not installed so far)
    + build and update running system
    + reinstall packages "zfsutils-linux zfs-dkms" after custom build
    + update recovery-squashfs

+ https://github.com/vpsfreecz/zfs/tree/vpsadminos-master-2004060

#}
