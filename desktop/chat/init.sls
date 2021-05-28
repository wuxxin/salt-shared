include:
  - .matrix     {# matrix protocol chat/video/voice clients # }
  - .mumble     {# low latency voice only client #}
{% if salt['pillar.get']('desktop:proprietary:enabled', false) == true %}
  - .signal     {# modern chat/video/voice client #}
  - .skype      {# proprietary chat/video/voice client from microsoft #}
{% endif %}

linphone:       {# sip (telephone/voice) client #}
  pkg:
    - installed
