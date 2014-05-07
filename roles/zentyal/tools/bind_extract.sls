{% set domain_name = 'in.spitzauer.at' %}
{% set sed_filter = '1,4d;$d' %}

bind_extract:
  pkg.installed:
    - pkgs:
      - build-essential
      - git
  git.latest:
    - name: https://github.com/derat/bind-to-tinydns.git
    - target: /root/bind-to-tinydns
    - require:
      - pkg: bind_extract
  cmd.wait:
    - name: cd /root/bind-to-tinydns; make
    - watch:
      - git: bind_extract

extract_data:
  cmd.run:
    - name: cd /root/bind-to-tinydns; dig {{ domain_name }} axfr | ./bind-to-tinydns {{ domain_name }} {{ domain_name }}.bind {{ domain_name }}.temp
    - require:
      - cmd: bind_extract

convert_data:
  cmd.run:
    - name: cd /root/bind-to-tinydns; cat {{ domain_name }}.bind | sed -re "s/(.+):900$/\1/g"  > {{ domain_name }}.tinydns
    - require:
      - cmd: extract_data
