{% from "ubuntu/lib.sls" import apt_add_repository %}

music-cd-ripper:
  pkg.installed:
    - pkgs:
      - cdparanoia
      - sound-juicer

music-tagger:
  pkg.installed:
    - pkgs:
      - picard

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
    '"http://ppa.launchpad.net/gnumdk/lollypop/ubuntu/dists/'+ grains['oscodename']+
    '/InRelease" | grep -qE "^HTTP/[12]\.?1? 200"', python_shell=true) == 0 %}
{{ apt_add_repository("lollypop_ppa",
    "gnumdk/lollypop", require_in= "pkg: music-player") }}
{% endif %}

music-player:
  pkg.installed:
    - pkgs:
      - lollypop

{#
download all currently cached network music files via youtube-dl
cd ~/music/lollypop/; for i in $(find ~/.cache/lollypop/ -type f -regex ".*/[^.]+$"); do youtube-dl --download-archive ./already-downloaded.log -x "$(cat $i)"; done
#}

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
