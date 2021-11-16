#!/usr/bin/bash
# calling script for {{ entry.type }} container of {{ entry.name }}
set -eo pipefail

{%- if entry.refresh %}
  {%- if entry.build.source != '' %}
# build container
pushd {{ entry.builddir }} > /dev/null
podman build {{ '--tag='+ entry.tag if entry.tag }} \
    {%- for k,v in entry.build.args.items() %}
    {{ '--build-arg=' ~ k ~ '=' ~ v }} \
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

# commands run before the first time the service is started
if test ! -e "{{ entry.configdir }}/image.digest"; then
    echo "INFO: initial run"
{%- if entry.init.command != '' %}
    /usr/bin/env - \
        {% for k,v in entry.init.environment %}{{ k ~ '=' ~ v }} {% endfor %} \
        {{ entry.init.command }}
{%- endif %}
fi

# create a digest if none is existing
if test ! -e "{{ entry.configdir }}/image.digest"; then
    podman image list --format json {{ entry.image }}{{ ":"+ entry.tag if entry.tag }} | \
        jq ".[0].Digest" -r > "{{ entry.configdir }}/image.digest"
fi

# commands run after updating image to newer image before starting new image
if test "$(cat "{{ entry.configdir }}/image.digest")" != \
    "$(podman image list --format json \
        {{ entry.image }}{{ ":"+ entry.tag if entry.tag }} | jq -r ".[0].Digest")"; then
    echo "INFO: update run"
{%- if entry.change.command != '' %}
    /usr/bin/env - \
        {% for k,v in entry.change.environment %}{{ k ~ '=' ~ v }} {% endfor %} \
        {{ entry.change.command }}
{%- endif %}
fi

# update digest
podman image list --format json {{ entry.image }}{{ ":"+ entry.tag if entry.tag }} | \
    jq -r ".[0].Digest" > "{{ entry.configdir }}/image.digest"

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
{%- if entry.userns == 'pick' or (entry.userns == 'auto' and user) %}
  --uidmap=0:{{ entry.USERNS_ID }}:65536 \
  --gidmap=0:{{ entry.USERNS_ID }}:65536 \
{%- else %}
  --userns={{ entry.userns }} \
{%- endif %}
{%- for k,v in entry.labels.items() %}
  --label={{ k }}={{ v }} \
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
