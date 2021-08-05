{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install %}

include:
  - python

{# https://github.com/mozilla/TTS #}

mozilla-tts-req:
  pkg.installed:
    - pkgs:
      - espeak-ng

{{ pipx_install('TTS', user=user) }}

{#
tts --model_name=tts_models/de/thorsten/tacotron2-DCA --text "Das ist ein Test, der soll zeigen wie das geht."

#}
