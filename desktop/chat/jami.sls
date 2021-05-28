jami:
  pkgrepo.managed:
    - name: deb https://dl.jami.net/nightly/{{ grains['os']|lower }}_{{ grains['osrelease'] }}/ ring main
    - key_url: https://dl.jami.net/ring.pub.key
    - file: /etc/apt/sources.list.d/jami.net.list
    - require_in:
      - pkg: jami
  pkg.installed:
    - name: jami
