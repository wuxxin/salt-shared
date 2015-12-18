{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}

{% set gcloud_source= "https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz" %}
{% set gcloud_archive= "google-cloud-sdk.tar.gz" %}
{% set gcloud_dirname= "google-cloud-sdk" %}
{% set tmp_destfile= "/tmp/"+ gcloud_archive %}
{% set final_destdir= user_home %}
{% set gcloud_destdir= final_destdir+ "/"+ gcloud_dirname %}

gcloud_download:
  module.run:
    - name: cp.get_url
    - path: {{ gcloud_source }}
    - dest: {{ tmp_destfile }}
    - unless: test -d {{ gcloud_destdir }}
  cmd.run:
    - name: tar xzf {{ tmp_destfile }}
    - user: {{ user }}
    - cwd: {{ final_destdir }}
    - unless: test -d {{ gcloud_destdir }}
    - require:
      - module: gcloud_download

gcloud_install:
  cmd.run:
    - name: env CLOUDSDK_CORE_DISABLE_PROMPTS=1 ./google-cloud-sdk/install.sh
    - user: {{ user }}
    - cwd: {{ final_destdir }}
    - unless: test -f {{ user_home }}/.config/gcloud/.metricsUUID
    - require:
      - cmd: gcloud_download

gcloud-create-user-bashrc:
  file.managed:
    - user: {{ user }}
    - name: {{ user_home }}/.bashrc

gcloud-create-user-profile:
  file.managed:
    - user: {{ user }}
    - name: {{ user_home }}/.profile

gloucd-modify-path-user-profile:
  file.blockreplace:
    - name: {{ user_home }}/.profile
    - marker_start: "# The next line updates PATH for the Google Cloud SDK."
    - marker_end: "source '{{ gcloud_destdir }}/path.bash.inc'"
    - content: ""
    - append_if_not_found: True
    - require:
      - file: gcloud-create-user-profile

gloucd-modify-completion-user-bashrc:
  file.blockreplace:
    - name: {{ user_home }}/.bashrc
    - marker_start: "# The next line enables bash completion for gcloud."
    - marker_end: "source '{{ gcloud_destdir }}/completion.bash.inc'"
    - content: ""
    - append_if_not_found: True
    - require:
      - file: gcloud-create-user-bashrc
