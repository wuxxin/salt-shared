{% from "android/redroid/defaults.jinja" import settings with context %}
{% from "containers/lib.sls" import image with context %}

include:
  - android.tools
  - containers

{% set reddroid_module_list= ['mac80211_hwsim'] %}

redroid-kernel-modules:
  kmod.present:
    - mods:
  {%- for i in reddroid_module_list %}
      - {{ i }}
  {%- endfor %}
  file.managed:
    - name: /etc/modules-load.d/redroid.conf
    - contents: |
  {%- for i in reddroid_module_list %}
        {{ i }}
  {%- endfor %}


{# download android lineage image builder container image #}
{{ image(settings.redroid_service.image, settings.redroid_service.tag) }}
