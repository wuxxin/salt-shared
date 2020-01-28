{% from "ubuntu/init.sls" import apt_add_repository %}

{% if salt['cmd.retcode']('curl -sSL -D - -o /dev/null --max-time 5 '+
  '"http://ppa.launchpad.net/micahflee/ppa/ubuntu/dists/'+ grains['oscodename']+
  '/InRelease" | grep -q "200 OK"', python_shell=true) == 0 %}
{{ apt_add_repository("torbrowser-ppa", "micahflee/ppa",
  require_in = "pkg:torbrowser-launcher") }}
{% endif %} 
  
torbrowser-launcher:
  pkg:
    - installed
