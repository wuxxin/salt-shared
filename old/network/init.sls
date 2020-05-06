{% from "network/lib.sls" import config_system, config_interfaces, config_routes with context %}
{% from "network/lib.sls" import sys_network, interfaces, routes with context %}

{{ config_system(sys_network) }}
{{ config_interfaces(interfaces) }}
{{ config_routes(routes) }}
