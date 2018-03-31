{%- from 'lib/minivault.sls' import manage_secret, rsa_public_from_secret %}
{%- set dkim_secretkey= manage_secret('dkim_secretkey', 'rsa_secret') %}
{%- set dkim_publickey= rsa_public_from_secret(dkim_secretkey) %}

# change dns
# @   IN  A     1.2.3.4
# @   IN  MX    10  @
# @   IN  TXT   "v=spf1 a mx ptr -all"
# default._domainkey    IN  TXT   ("v=DKIM1; k=rsa; s=email; "
#    "p={{ dkim_publickey[:250] }}"
#    "{{ dkim_publickey[250:] }}")
# for gui-dns: default.domainkey:v=DKIM1; k=rsa; s=email; p={{ dkim_publickey }}
# 4.3.2.1.in-addr.arpa. IN  PTR  {{ domain }}.

dehydrated:
  pillar: appliance:zentyal:letsencrypt
  
appliance:
  zentyal:
    dkim:
      key: |
{{ dkim_secretkey|indent(10,True) }}
