gimp:
  pkg.installed:
    - pkgs:
      - gimp
      - gimp-data-extras
      - gimp-plugin-registry

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("krita_ppa", "kritalime/ppa", require_in= "pkg: krita") }}
{% endif %}

krita:
  pkg.installed:
    - pkgs:
      - krita
      - krita-l10n
