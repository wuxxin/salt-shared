{% from "ubuntu/init.sls" import apt_add_repository %}

music-cd-ripper:
  pkg.installed:
    - pkgs:
      - cdparanoia
      - sound-juicer

music-tagger:
  pkg.installed:
    - pkgs:
      - picard

music-player:
  pkg.installed:
    - pkgs:
      - rhythmbox
      - lollypop


{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"http://ppa.launchpad.net/fossfreedom/rhythmbox-plugins/ubuntu/dists/'+ grains['oscodename']+
  '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}

{{ apt_add_repository("rhythmbox-plugins_ppa",
  "fossfreedom/rhythmbox-plugins", require_in= "pkg: rhythmbox-plugins") }}

rhythmbox-plugins:
  pkg.installed:
    - pkgs:
      - rhythmbox-plugin-close-on-hide
      - rhythmbox-plugin-countdown-playlist
      - rhythmbox-plugin-drc
      - rhythmbox-plugin-equalizer
      - rhythmbox-plugin-fullscreen
      - rhythmbox-plugin-parametriceq
      - rhythmbox-plugin-rating-filters
{% endif %}


{% if grains['os'] == 'Ubuntu' %}
  {% if grains['osrelease_info'][0]|int <= 19 %}
{{ apt_add_repository("sonic-pi_ppa",
  "sonic-pi/ppa", require_in= "pkg: sonic-pi") }}
  {% endif %}
{% endif %}
sonic-pi:
  pkg.installed:
    - pkgs:
      - sonic-pi
