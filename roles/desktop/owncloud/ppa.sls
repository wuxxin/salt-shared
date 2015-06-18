{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{# FIXME: remove hardcoded path #}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
owncloudclient_ppa:
  pkgrepo.managed:
    - name: deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /
    - file: /etc/apt/sources.list.d/owncloudclient.list
    - key_url: http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_14.04/Release.key
{% endif %}

