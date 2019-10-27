{% if grains['os'] == 'Ubuntu' %}
  {% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"http://ppa.launchpad.net/inkscape.dev/stable-daily/ubuntu/dists/'+ grains['oscodename']+
  '/InRelease" | grep -q "200 OK"', python_shell=true) == 0 %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("inkscape-ppa",
  "inkscape.dev/stable-daily", require_in= "pkg: inkscape") }}
  {% endif %}
{% endif %} 

inkscape:
  pkg.installed:
    - pkgs:
      - inkscape
      - librsvg2-bin

pixel_vector:
  pkg.installed:
    - pkgs:
      - pencil2d
