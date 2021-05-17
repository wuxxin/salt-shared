{% load_yaml as settings %}
version:
  helm: '3.2.3'
  helmdiff: '3.1.1'
{% endload %}

helm:
  file.managed:
    - name: /usr/local/lib/helm-linux-amd64.tar.gz
    - source: https://get.helm.sh/helm-v{{ settings.version.helm }}-linux-amd64.tar.gz
    - source_hash: https://get.helm.sh/helm-v{{ settings.version.helm }}-linux-amd64.tar.gz.sha256
    - mode: "755"
  cmd.run:
    - name: tar xzf /usr/local/lib/helm-linux-amd64.tar.gz --overwrite -C /usr/local/bin --strip-components=1 linux-amd64/helm
    - onchanges:
      - file: helm

helmfile:
  file.managed:
    - name: /usr/local/bin/helmfile
    - source: https://github.com/roboll/helmfile/releases/download/v{{ settings.version.helmfile }}/helmfile_linux_amd64
    - skip_verify: true
    - mode: "755"

{# helm plugin: helm x #}
helm-x-bin-dir:
  file.directory:
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x/bin
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
helm-x.tar.gz:
  file.managed:
    - name: {{ settings.home }}/.local/share/helm-x.tar.gz
    - source: https://github.com/mumoshu/helm-x/archive/v{{ settings.version.helmx }}.tar.gz
    - skip_verify: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - file: {{ settings.home }}/.local/share
  archive.extracted:
    - source: {{ settings.home }}/.local/share/helm-x.tar.gz
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - file: helm-x.tar.gz
helm-x-symlink:
  file.symlink:
    - name: {{ settings.home }}/.local/share/helm/plugins/helm-x
    - target: {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - require:
      - file: {{ settings.home }}/.local/share
helm-x-binary:
  file.managed:
    - name: {{ settings.home }}/.local/share/helm-x_linux_amd64.tar.gz
    - source: https://github.com/mumoshu/helm-x/releases/download/v{{ settings.version.helmx }}/helm-x_{{ settings.version.helmx }}_linux_amd64.tar.gz
    - source_hash: https://github.com/mumoshu/helm-x/releases/download/v{{ settings.version.helmx }}/helm-x_{{ settings.version.helmx }}_checksums.txt
    - require:
      - file: {{ settings.home }}/.local/share
  cmd.run:
    - name: tar xzf {{ settings.home }}/.local/share/helm-x_linux_amd64.tar.gz --overwrite -C {{ settings.home }}/.cache/helm/plugins/https-github.com-mumoshu-helm-x/bin helm-x
    - runas: {{ settings.user }}
    - onchanges:
      - file: helm-x-binary

{# helm plugin: helm diff #}
helm-diff-bin-dir:
  file.directory:
    - name: {{ settings.home }}/.cache/helm/plugins/https-github.com-databus23-helm-diff/bin
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
helm-diff:
  file.managed:
    - name: {{ settings.home }}/.local/share/helm-diff-linux.tar.gz
    - source: https://github.com/databus23/helm-diff/releases/download/v{{ settings.helmdiff_version }}/helm-diff-linux.tgz
    - skip_verify: true
  cmd.run:
    - name: tar xzf {{ settings.home }}/.local/share/helm-diff-linux.tar.gz --overwrite -C {{ settings.home }}/.cache/helm/plugins/https-github.com-databus23-helm-diff --strip-components=1 diff
    - runas: {{ settings.user }}
    - onchanges:
      - file: helm-diff
helm-diff-symlink:
  file.symlink:
    - name: {{ settings.home }}/.local/share/helm/plugins/helm-diff
    - target: {{ settings.home }}/.cache/helm/plugins/https-github.com-databus23-helm-diff
    - makedirs: true
    - user: {{ settings.user }}
    - group: {{ settings.user }}
