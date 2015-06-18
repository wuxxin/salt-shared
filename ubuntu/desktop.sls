include:
  - .reporting-disabled
  - .java-integration-enabled
  - .hibernate-enabled

{% if (grains['os'] == 'Ubuntu') %}
unity-tweaks:
  pkg.installed:
    - pkgs:
      - unity-tweak-tool
{% endif %}

compiz-tweaks:
  pkg.installed:
    - pkgs:
      - compizconfig-settings-manager

