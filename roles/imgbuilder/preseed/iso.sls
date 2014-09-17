iso-env:
  pkg.installed:
    - pkgs:
      - syslinux
      - extlinux
      - genisoimage


{% macro mk_install_iso(cs) %}
    genisoimage -J -joliet-long -allow-lowercase -allow-limited-size -R -iso-level 4 -o "$File.iso" $File
{% endmacro %}

