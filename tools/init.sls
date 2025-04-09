{% from 'python/lib.sls' import pipx_install %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - code.python

usr_local_bin:
  file.directory:
    - name: {{ user_home }}/.local/bin
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true

{# jinja2-cli - CLI interface to Jinja2, including yaml,xml,toml support #}
{{ pipx_install('jinja2-cli[yaml,toml,xml]', user=user) }}

{# flatyaml.py - convert yaml to a flat key=value format #}
flatyaml:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-yaml
    - require:
      - sls: python
  file.managed:
    - name: {{ user_home }}/.local/bin/flatyaml.py
    - source: salt://tools/flatyaml.py
    - mode: "0755"
    - user: {{ user }}
    - group: {{ user }}

{# passgen.py - speakable friendly passwort generator #}
passgen:
  pkg.installed:
    - name: python{{ '3' if grains['os_family']|lower == 'debian' }}-bitstring
    - require:
      - sls: python
  file.managed:
    - name: {{ user_home }}/.local/bin/passgen.py
    - source: salt://tools/passgen.py
    - mode: "0755"
    - user: {{ user }}
    - group: {{ user }}

{# gpgutils.py - Encryption/Signing, Decryption/Verifying with gnupg #}
gpgutils:
  pkg.installed:
    - pkgs:
      - gnupg
  file.managed:
    - name: {{ user_home }}/.local/bin/gpgutils.py
    - source: salt://tools/gpgutils.py
    - mode: "0755"
    - user: {{ user }}
    - group: {{ user }}

{# sentrycat.py - error reporting to sentry #}
sentrycat:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-requests
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-chardet
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-sentry_sdk
    - require:
      - sls: python
  file.managed:
    - name: {{ user_home }}/.local/bin/sentrycat.py
    - source: salt://tools/sentrycat.py
    - mode: "0755"
    - user: {{ user }}
    - group: {{ user }}

{# create a linked qrcode pdf from data, read data from linked qrcodes inside pdf #}
qrcode:
  pkg.installed:
    - pkgs:
      - qrencode
      - imagemagick
      - zbar

{% for a in ['data2qrpdf.sh', 'qrpdf2data.sh'] %}
{{ user_home }}/.local/bin/{{ a }}:
  file.managed:
    - source: salt://tools/{{ a }}
    - mode: "0755"
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

