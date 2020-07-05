
{% macro lxc_volume(name, labels=[], driver='local', opts=[]) %}
  {%- set labels_string = '' if not labels else '-l ' ~ labels|join(' -l ') %}
  {%- set opts_string = '' if not opts else '-o ' ~ opts|join(' -o ') %}
containers_volume_{{ name }}:
  cmd.run:
    - name: lxc volume create --driver {{ driver }} {{ labels_string }} {{ opts_string }}
    - unless: lxc ls -q | grep -q {{ name }}
{% endmacro %}


{% macro lxc_container(definition) %}
  {%- from "lxc/defaults.jinja" import settings, default_service with context %}
  {%- set mergedconfig= salt['grains.filter_by']({'default': default_service},
    grain='default', default= 'default', merge=definition) %}

          lxc.uts.name = {%= ct.hostname || ct.id %}
          # Init: lxc.init.cmd = {%= ct.format_init_cmd %}
          # UID/GID mapping
          {% ct.user.uid_map.each do |entry| -%}
          lxc.idmap = u {%= entry.ns_id %} {%= entry.host_id %} {%= entry.count %}
          {% end -%}
          {% ct.user.gid_map.each do |entry| -%}
          lxc.idmap = g {%= entry.ns_id %} {%= entry.host_id %} {%= entry.count %}
          {% end -%}
          # Security
          lxc.seccomp.profile = {%= ct.seccomp_profile %}
          lxc.apparmor.profile = {%= ct.apparmor.namespace_profile_name %}
          lxc.autodev = 1
          # Process limits
          {% prlimits.each do |name, limit| -%}
          lxc.prlimit.{%= name %} = {%= limit.soft %}:{%= limit.hard %}
          {% end -%}
          # Mounts
          {% mounts.each do |m| -%}
          lxc.mount.entry = {%= m.fs %} {%= m.lxc_mountpoint %} {%= m.type %} {%= m.opts %}
          {% end -%}

  {%- if not pod.container.update %}
  {# if not update on every container start, update now #}
update_image_{{ pod.image }}:
  cmd.run:
    {%- if pod.build %}
    - name: lxc build {{ pod.build }} {{ "--tag="+ pod.tag if pod.tag }}
    {%- else %}
    - name: lxc pull {{ pod.image }}{{ ":"+ pod.tag if pod.tag }}
    {%- endif %}
    - require_in:
      - file: {{ pod.container_name }}.service
  {%- endif %}

{{ pod.container_name }}.service:
  file.managed:
    - source: salt://containers/lxc/lxc-template.service
    - name: /etc/systemd/system/{{ pod.container_name }}.service
    - template: jinja
    - defaults:
        pod: {{ pod }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ pod.container_name }}.service
  service.running:
    - name: {{ pod.container_name }}.service
    - enable: true
    - require:
      - cmd: {{ pod.container_name }}.service
{% endmacro %}
