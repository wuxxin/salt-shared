#!/usr/bin/bash
set -eo pipefail

# calling script for {{ entry.type }} container of {{ entry.name }}
{%- from "containers/lib.sls" import env_repl, name_to_usernsid with context %}

# include environment
. {{ entry.configdir }}/.env

{%- if entry.update %}
  {%- if entry.build.source != '' %}

# build container
pushd {{ entry.builddir }}
podman build {{ '--tag='+ entry.tag if entry.tag }} \
    {%- for key,value in entry.build.args.items() %}
    {{ '--build-arg=' ~ key ~ '=' ~ value }} \
    {%- endfor %}
    {{ entry.build.source }}
popd
  {%- else %}

# pull container
podman pull {{ entry.image }}{{ ":"+ entry.tag if entry.tag }}
  {%- endif %}
{%- endif %}

{%- if entry.ephemeral %}
# remove probably existing container
podman rm -f {{ entry.name }} || true
{%- endif %}

{%- if entry.type == 'desktop' %}
# desktop container
exec x11docker \
  {%- for k in entry.x11docker %}
  {{ k }} \
  {%- endfor %}
  -- \
{%- else %}
# commandline container
exec podman run \
{%- endif %}
  --name={{ entry.name }} \
  --cgroups=split \
  --env-host \
{%- if entry.userns == 'pick' %}
  --uidmap=0:{{ name_to_usernsid(entry.name) }}:65536 \
  --gidmap=0:{{ name_to_usernsid(entry.name) }}:65536 \
{%- else %}
  --userns={{ entry.userns }} \
{%- endif %}
{%- for key,value in entry.options.items() %}
  --{{ key }}={{ value }} \
{%- endfor %}
{%- for key,value in entry.labels.items() %}
  --label={{ key }}={{ value }} \
{%- endfor %}
{%- for vol in entry.volumes %}
  {%- set vol_str = env_repl(vol, entry.environment) %}
  --volume={{ vol_str }} \
{%- endfor %}
{%- for publish in entry.ports %}
  {%- set publish_str = env_repl(publish, entry.environment) %}
  --publish={{ publish_str }} \
{%- endfor %}
{%- for k,v in entry.environment %}
  -e {{ k }}={{ v }} \
{%- endfor %}
  -- \
  {{ entry.image }}{{ ":"+ entry.tag if entry.tag }} {% if entry.command %} \
  {{ entry.command }} {{ entry.args }}
{% endif %}
