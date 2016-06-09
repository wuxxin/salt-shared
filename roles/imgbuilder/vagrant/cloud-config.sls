{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

{{ pillar['destdir'] }}/user-data:
  file.managed:
    - contents: |
        #cloud-config
        users:
          - name: vagrant
            sudo: ['ALL=(ALL) NOPASSWD:ALL']
            ssh-authorized-keys:
{%- if pillar['adminkeys_present']|d(False) %}
  {%- for adminkey in pillar['adminkeys_present'] %}
              - "{{adminkey}}"
  {% endfor %}
{%- endif %}
              - "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"


{{ pillar['destdir'] }}/meta-data:
  file.managed:
    - contents: |
        #meta-data
        instance-id: iid-cloud-default
        local-hostname: linux


{{ pillar['destdir'] }}/seed.iso:
  cmd.run:
    - name: genisoimage -output {{ pillar['destdir'] }}/seed.iso -volid cidata -joliet -rock -input-charset utf-8 {{ pillar['destdir'] }}/user-data {{ pillar['destdir'] }}/meta-data
