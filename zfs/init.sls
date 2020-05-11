include:
  - nfs.common
  - autosnapshot

zfsutils-linux:
  pkgs.installed:
    - require:
      - sls: nfs.common

/etc/modprobe.d/zfs.conf:
  file.managed:
    - contents: |
        options zfs zfs_vdev_scheduler={{ settings.vdev_scheduler }}
        options zfs zfs_arc_max={{ settings.arc_max_bytes }}


{% for f in ['build_from_lp.sh', 'customize-running-system.sh'] %}
/etc/recovery/zfs/{{ f }}:
  file.managed:
    - source: salt://machine-bootstrap/{{ f }}
    - filemode: "0755"
    - makedirs: true
{% endfor %}



{#
+ include machine-bootstrap/zfs/custom-zfs.sls
  if zfs:custom-build:enabled: true
    look if current custom build, rebuild
    reinstall packages "zfsutils-linux zfs-dkms" after custom build

+ set scrub non linear, for 6 weeks every 14days on sunday, then twice per year
  + default: Scrub the second Sunday of every month.
  +  24 0 8-14 * * root [ $(date +\%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ] && /usr/lib/zfs-linux/scrub
#}

{#
+ update all files
+ if machine-config says frankenstein=true
  + test which customized zfs we have runninng
  + if there is a newer version (or not installed so far)
    + build and update running system
    + update recovery-squashfs

https://github.com/vpsfreecz/zfs/tree/vpsadminos-master-2004060

{% for p in salt['cmd.run_stdout'](
  'find '+ grains['project_basepath']+
    '/machine-bootstrap/zfs/ -name "*.patch" -type f -printf "%f\n" | sort -n',
  python_shell=True) %}
/etc/recovery/zfs/{{ p }}
  file.managed:
    - source: salt://machine-bootstrap/zfs/{{ p }}
{% endfor %}

#}
