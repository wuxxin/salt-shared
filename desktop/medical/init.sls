dicom-viewer:
  pkg.installed:
    - pkgs:
      - aeskulap
      - ginkgocadx
      - amide
      {# plastimatch #}

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("invesalius_ppa", "tfmoraes/invesalius ", require_in= "pkg: invesalius") }}
{% endif %}

invesalius:
  pkg.installed:
    - pkgs:
      - invesalius
