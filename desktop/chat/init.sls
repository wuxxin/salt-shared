include:
  - .matrix     {# matrix protocol chat/video/voice clients # }
  - .signal     {# modern chat/video/voice client #}
  - .jami       {# decentral dht/video/voice and sip client #}
{% if salt['pillar.get']('desktop:proprietary:enabled', false) == true %}
  - .skype
{% endif %}
  - .mumble     {# low latency voice only #}

linphone:       {# sip client #}
  pkg:
    - installed 

