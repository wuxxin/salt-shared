#!/usr/bin/bash
# calling script for {{ entry.type }} container of {{ entry.name }}
set -eo pipefail

{%- if entry.update %}
  {%- if entry.build.source != '' %}
# build container
pushd {{ entry.builddir }} > /dev/null
podman build {{ '--tag='+ entry.tag if entry.tag }} \
    {%- for key,value in entry.build.args.items() %}
    {{ '--build-arg=' ~ key ~ '=' ~ value }} \
    {%- endfor %}
    {{ entry.build.source }}
popd > /dev/null
  {%- else %}

# pull container if not already pointing to localhost
registry="{{ entry.image }}"
if test "${registry%*/}" != "localhost"; then
    podman pull {{ entry.image }}{{ ":"+ entry.tag if entry.tag }}
fi
  {%- endif %}
{%- endif %}

{%- if entry.ephemeral %}
# remove probably existing container
podman rm -f {{ entry.name }} || true
{%- endif %}

{%- if entry.type == 'desktop' %}
# desktop container
exec x11docker \
  {%- for k in entry.desktop.template_options %}
  {{ k }} \
  {%- endfor %}
  {%- for k in entry.desktop.options %}
  {{ k }} \
  {%- endfor %}
  --name={{ entry.name }} \
  -- \
{%- else %}
# commandline container
exec podman run \
  --name={{ entry.name }} \
{%- endif %}
  --cgroups=split \
  --env-file {{ entry.configdir }}/.env \
  --env-host \
{%- if entry.userns == 'pick' %}
  --uidmap=0:{{ entry.USERNS_ID }}:65536 \
  --gidmap=0:{{ entry.USERNS_ID }}:65536 \
{%- else %}
  --userns={{ entry.userns }} \
{%- endif %}
{%- for key,value in entry.labels.items() %}
  --label={{ key }}={{ value }} \
{%- endfor %}
{%- for vol in entry.volumes %}
  --volume={{ vol }} \
{%- endfor %}
{%- for publish in entry.ports %}
  --publish={{ publish }} \
{%- endfor %}
{%- for opt in entry.options %}
  {{ opt }} \
{%- endfor %}
  -- \
  {{ entry.image }}{{ ":"~ entry.tag if entry.tag }} {% if entry.command %} \
  {{ entry.command }} {{ entry.args }}
{% endif %}
