{% from "http_frontend/defaults.jinja" import settings with context %}

{% set easyrsa_local_file= "/usr/local/"+ settings.external.easy_rsa_tar_gz.target+ "/easy_rsa.tar.gz" %}

include:
  - http_frontend.dirs

pki_requisites:
  pkg.installed:
    - pkgs:
      - swaks

{% for i in ['create-client-certificate.sh', 'revoke-client-certificate.sh'] %}
"/usr/local/bin/{{ i }}":
  file.managed:
    - source: salt://http_frontend/pki/{{ i }}
    - template: jinja
    - mode: "0755"
    - defaults:
        settings: {{ settings }}
{% endfor %}

{{ settings.cert_dir }}/easyrsa:
  file.directory:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - dir_mode: 770
    - file_mode: 660
    - makedirs: true

# install miniature pki cmdline tool
easyrsa:
  file.managed:
    - name: {{ easyrsa_local_file }}
    - source: {{ settings.external.easy_rsa_tar_gz.download }}
    - source_hash: sha256={{ settings.external.easy_rsa_tar_gz.hash }}
  archive.extracted:
    - name: {{ settings.cert_dir }}/easyrsa
    - source: {{ easyrsa_local_file }}
    - archive_format: tar
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - enforce_toplevel: false
    - overwrite: true
    - clean: false
    - options: --strip-components 1
    - onchanges:
      - file: easyrsa
    - require:
      - file: easyrsa

# config
easyrsa_vars:
  file.managed:
    - name: {{ settings.cert_dir }}/easyrsa/vars
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - contents: |
        set_var EASYRSA_CRL_DAYS 3650
        set_var EASYRSA_CERT_EXPIRE 1095

# Generate initial CA for client certificates
easyrsa_build_ca:
  cmd.run:
    - name: |
        if test -f {{ settings.cert_dir }}/easyrsa/pki/ca.crt; then
          rm -r {{ settings.cert_dir }}/easyrsa/pki
        fi
        ./easyrsa --batch init-pki
        ./easyrsa --batch --req-cn="{{ settings.domain }}" \
          --subject-alt-name="DNS:{{ settings.domain }}" \
          --req-org="{{ settings.domain }} Client Cert CA" \
          build-ca nopass
    - runas: {{ settings.user }}
    - cwd: {{ settings.cert_dir }}/easyrsa
    - unless: |
        result="false"
        if test -f {{ settings.cert_dir }}/easyrsa/pki/ca.crt; then
          subject_cn=$(openssl x509 -text -noout \
            -in "{{ settings.cert_dir }}/easyrsa/pki/ca.crt" | \
            grep "Subject: CN" | sed -r "s/[[:space:]]+Subject: +CN += +(.+)/\\1/g")
          echo "subject_cn:$subject_cn"
          echo "domain:{{ settings.domain }}"
          if test "$subject_cn" = "{{ settings.domain }}"; then
            result="true"
          fi
        fi
        $result
    - require:
      - archive: easyrsa
      - file: easyrsa_vars

# create revocation list if index is newer than list or list is not existing
easyrsa_gen_crl:
  cmd.run:
    - name: ./easyrsa --batch gen-crl
    - runas: {{ settings.user }}
    - cwd: {{ settings.cert_dir }}/easyrsa
    - onlyif: test ! -e {{ settings.cert_dir }}/easyrsa/pki/crl.pem -o {{ settings.cert_dir }}/easyrsa/pki/crl.pem -ot {{ settings.cert_dir }}/easyrsa/pki/index.txt
    - require:
      - cmd: easyrsa_build_ca

# copy ca and crl to cert_dir
{{ settings.cert_dir }}/{{ settings.ssl_client_ca }}:
  file.copy:
    - source: {{ settings.cert_dir }}/easyrsa/pki/ca.crt
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - force: true
    - onchanges:
      - cmd: easyrsa_build_ca

{{ settings.cert_dir }}/{{ settings.ssl_client_crl }}:
  file.copy:
    - source: {{ settings.cert_dir }}/easyrsa/pki/crl.pem
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - mode: "0640"
    - force: true
    - onchanges:
      - cmd: easyrsa_gen_crl
