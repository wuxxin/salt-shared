{% from "app/http_frontend/defaults.jinja" import settings with context %}

include:
  - app.http_frontend.dirs

pki_requisites:
  pkg.installed:
    - pkgs:
      - bc
      - swaks
      - gosu
      - openssl

{% for i in [
'create-client-certificate.sh',
'create-host-certificate.sh',
'renew-host-certificates.sh',
'revoke-certificate.sh'] %}
"/usr/local/bin/{{ i }}":
  file.managed:
    - source: salt://app/http_frontend/pki/{{ i }}
    - template: jinja
    - mode: "0755"
    - defaults:
        settings: {{ settings }}
{% endfor %}

{{ settings.ssl.base_dir }}/easyrsa:
  file.directory:
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - dir_mode: 770
    - file_mode: 660
    - makedirs: true

# install miniature pki cmdline tool
easyrsa:
  file.managed:
    - name: {{ settings.external.easy_rsa_tar_gz.target }}
    - source: {{ settings.external.easy_rsa_tar_gz.download }}
    - source_hash: sha256={{ settings.external.easy_rsa_tar_gz.hash }}
  archive.extracted:
    - name: {{ settings.ssl.base_dir }}/easyrsa
    - source: {{ settings.external.easy_rsa_tar_gz.target }}
    - archive_format: tar
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
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
    - name: {{ settings.ssl.base_dir }}/easyrsa/vars
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - contents: |
        set_var EASYRSA_CRL_DAYS 3650
        set_var EASYRSA_CERT_EXPIRE {{ settings.ssl.local_ca.validity_days }}

# Generate initial CA
# will wipe and recreate CA if settings.domain is changed
easyrsa_build_ca:
  cmd.run:
    - runas: {{ settings.ssl.user }}
    - cwd: {{ settings.ssl.base_dir }}/easyrsa
    - name: |
        if test -f {{ settings.ssl.base_dir }}/easyrsa/pki/ca.crt; then
          rm -r {{ settings.ssl.base_dir }}/easyrsa/pki
        fi
        ./easyrsa --batch init-pki
        ./easyrsa \
          --batch \
          --use-algo="{{ settings.ssl.local_ca.algo }}" \
          --curve="{{ settings.ssl.local_ca.curve }}" \
          --keysize="{{ settings.ssl.local_ca.keysize }}" \
          --dn-mode=org \
          --req-cn="{{ settings.domain }}" \
          --req-org="{{ settings.ssl.local_ca.organization }}" \
          --req-ou="{{ settings.ssl_local_ca_authority_unit }}" \
          --req-city="{{ settings.ssl.local_ca.city }}" \
          --req-st="" \
          --req-c="{{ settings.ssl.local_ca.country }}" \
          --req-email="" \
          build-ca nopass
    - unless: |
        result="false"
        if test -f {{ settings.ssl.base_dir }}/easyrsa/pki/ca.crt; then
          subject_cn=$(openssl x509 -text -noout \
            -in "{{ settings.ssl.base_dir }}/easyrsa/pki/ca.crt" | \
              grep -E "^[[:space:]]+Subject:.+CN =" | \
              sed -r "s/^[[:space:]]+Subject:.+CN = (.+)$/\\1/g")
          echo "expected_cn: {{ settings.domain }}"
          echo "current_cn: $subject_cn"
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
    - runas: {{ settings.ssl.user }}
    - cwd: {{ settings.ssl.base_dir }}/easyrsa
    - name: ./easyrsa --batch gen-crl
    - onlyif: test ! -e {{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem -o \
                {{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem -ot {{ settings.ssl.base_dir }}/easyrsa/pki/index.txt
    - require:
      - cmd: easyrsa_build_ca

# copy ca and crl to ssl.pki.data
{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_cert }}:
  file.copy:
    - source: {{ settings.ssl.base_dir }}/easyrsa/pki/ca.crt
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - force: true
    - onchanges:
      - cmd: easyrsa_build_ca

{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}:
  file.copy:
    - source: {{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem
    - user: {{ settings.ssl.user }}
    - group: {{ settings.ssl.user }}
    - mode: "0640"
    - force: true
    - onchanges:
      - cmd: easyrsa_gen_crl
