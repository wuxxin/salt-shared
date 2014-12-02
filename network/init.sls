{% set sys_network = salt['pillar.get']('network:system', {}) %}
{% set interfaces = salt['pillar.get']('network:interfaces', {}) %}
{% set routes = salt['pillar.get']('network:routes', {}) %}

{% from "network/lib.sls" import config_system, config_interfaces, config_routes with context %}

{{ config_system(sys_network) }}
{{ config_interfaces(interfaces) }}
{{ config_routes(routes) }}
