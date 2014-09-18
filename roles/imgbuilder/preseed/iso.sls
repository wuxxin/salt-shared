iso-env:
  pkg.installed:
    - pkgs:
      - syslinux
      - genisoimage

{% macro mk_install_iso(cs) %}

{% set tmp_target=cs.target+ "/CD_root" %}

iso-clean-tmp_target:
  file.absent:
    - name: {{ tmp_target }}

iso-make-tmp_target:
  file.directory:
    - name: {{ tmp_target }}
    - user: imgbuilder
    - group: imgbuilder
    - makedirs: true
    - require:
      - file: iso-clean-tmp_target

iso-make-dirs:
  file.directory:
    - name: {{ tmp_target }}/isolinux
    - makedirs: true

iso-copy-isolinux:
  file.copy:
    - source: /usr/lib/syslinux/isolinux.bin
    - name: {{ tmp_target }}/isolinux/isolinux.bin

iso-copy-kernel:
  file.copy:
    - source: {{ cs.target }}/linux
    - name: {{ tmp_target }}/linux

iso-copy-initrd:
  file.copy:
    - source: {{ cs.target }}/initrd.gz
    - name: {{ tmp_target }}/initrd.gz

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

iso-mkisofs:
  cmd.run:
    - name: mkisofs -o {{ cs.target }}/preseed.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table {{ tmp_target }}

iso-hybrid-image:
  cmd.run:
    - name: isohybrid {{ cs.target }}/preseed.iso

{% endmacro %}
