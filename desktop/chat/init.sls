include:
  - .matrix     {# matrix protocol chat/video/voice clients # }
  - .signal     {# modern chat/video/voice client #}
  - .jami       {# decentral dht/video/voice and sip client #}
{% if salt['pillar.get']('desktop:proprietary:enabled', false) == true %}
  - .skype      {# proprietary chat/video/voice client from microsoft #}
{% endif %}
  - .mumble     {# low latency voice only client #}

linphone:       {# sip (telephone/voice) client #}
  pkg:
    - installed 
