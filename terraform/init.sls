{% load_yaml as defaults %}
version: 0.15.1
hash: 1ff798791abf518fb0b5d9958ec8327b7213f1c91fb5235923e91cc96c59ef2c
{% endload %}

{% set url = "https://releases.hashicorp.com/terraform/"+
    defaults.version+ "/terraform_"+ defaults.version+ "_linux_amd64.zip" %}
{% set localfile = "terraform_"+ defaults.version+ "_linux_amd64.zip" %}

terraform:
  file.managed:
    - name: /usr/local/lib/{{ localfile }}
    - source: {{ url }}
    - source_hash: sha256={{ defaults.hash }}
  cmd.run:
    - name: unzip -o /usr/local/lib/{{ localfile }} terraform -d /usr/local/bin
    - onchanges:
      - file: terraform
    - require:
      - file: terraform
