iso-env:
  pkg.installed:
    - pkgs:
      - syslinux
      - genisoimage


{% macro mk_install_iso(cs) %}

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}
{% set tmp_target=cs.target+ "/CD_root" %}

iso-clean-tmp_target:
  file.absent:
    - name: {{ tmp_target }}

iso-make-tmp_target:
  file.directory:
    - name: {{ tmp_target }}
    - user: {{ s.user }}
    - group: {{ s.user }}
    - makedirs: true
    - require:
      - file: iso-clean-tmp_target

iso-make-dirs:
  file.directory:
    - name: {{ tmp_target }}/isolinux
    - makedirs: true
    - require:
      - file: iso-make-tmp_target

iso-copy-isolinux:
  file.copy:
    - source: /usr/lib/syslinux/isolinux.bin
    - name: {{ tmp_target }}/isolinux/isolinux.bin
    - require:
      - file: iso-make-dirs

iso-copy-kernel:
  file.copy:
    - source: {{ cs.target }}/linux
    - name: {{ tmp_target }}/linux
    - require:
      - file: iso-make-dirs

iso-copy-initrd:
  file.copy:
    - source: {{ cs.target }}/initrd.gz
    - name: {{ tmp_target }}/initrd.gz
    - require:
      - file: iso-make-dirs

iso-make-isolinux.cfg:
  file.managed:
    - source: salt://roles/imgbuilder/preseed/files/isolinux.cfg
    - name: {{ tmp_target }}/isolinux/isolinux.cfg
    - template: jinja
    - context:
       hostname: {{ cs.hostname }}
       cmdline: {{ cs.cmdline }}
       initrd: initrd.gz
       kernel: linux
    - require:
      - file: iso-make-dirs

iso-mkisofs:
  cmd.run:
    - name: mkisofs -o {{ cs.target }}/preseed.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table {{ tmp_target }}
    - require:
      - file: iso-make-isolinux.cfg
      - file: iso-copy-initrd
      - file: iso-copy-kernel
      - file: iso-copy-isolinux

iso-hybrid-image:
  cmd.run:
    - name: isohybrid {{ cs.target }}/preseed.iso
    - require:
      - cmd: iso-mkisofs

iso-clean-tmp_target_finish:
  file.absent:
    - name: {{ tmp_target }}
    - require:
      - cmd: iso-hybrid-image

iso-checksum-image:
  cmd.run:
    - name: sha256sum -b {{ cs.target }}/preseed.iso | sed -re "s/([^ ]+) .*/\1/g" >  {{ cs.target }}/preseed.iso.sha256
    - onlyif: test ! -f  {{ cs.target }}/preseed.iso.sha256

{% endmacro %}
