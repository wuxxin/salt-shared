{% from 'storage/lib.sls' import storage_setup with context %}

{% if salt['pillar.get']('storage', {}) %}
{{ storage_setup(pillar.storage) }}
{% endif %}
