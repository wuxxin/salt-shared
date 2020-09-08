{% from "oauth2proxy/defaults.jinja" import settings with context %}
{% set oauth2proxy_local_binary = "/usr/local/bin/oauth2-proxy" %}

oauth2proxy_archive:
  file.managed:
    - source: {{ settings.external.oauth2_proxy_tar_gz_binary_xz.download }}
    - source_hash: {{ settings.external.oauth2_proxy_tar_gz_binary_xz.hash_url }}
    - name: {{ settings.external.oauth2_proxy_tar_gz_binary_xz.target }}
  archive.extracted:
    - source: {{ settings.external.oauth2_proxy_tar_gz_binary_xz.target }}
    - dest: {{ oauth2_proxy_tar_gz_local_binary }}
    
oauth2proxy_binary:
  cmd.wait:
    - name: xz -d < {{ settings.external.oauth2_proxy_tar_gz_binary_xz.target }} > {{ oauth2_proxy_tar_gz_local_binary }} && chmod +x {{ oauth2_proxy_tar_gz_local_binary }}
    - onchange:
      - file: oauth2_proxy_tar_gz_archive
    - require:
      - pkg: oauth2_proxy_tar_gz_requisites
