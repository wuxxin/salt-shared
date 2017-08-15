include:
  - roles.desktop.eclipse

{% from 'roles/desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'roles/desktop/eclipse/lib.sls' import eclipse_plugin, keytool_cert with context %}

{% set plugins= [
    ('shelled bash editor', 'https://sourceforge.net/projects/shelled/files/shelled/update/', 'net.sourceforge.shelled.feature.group'),
    ('startexplorer', 'http://basti1302.github.com/startexplorer/update/', 'de.bastiankrol.startexplorer.feature.feature.group'),
    ('eclipse-color-theme', 'http://eclipse-color-theme.github.io/update/', 'com.github.eclipsecolortheme.feature.feature.group'),
    ('anyedit', 'http://andrei.gmxhome.de/eclipse/', 'AnyEditTools.feature.group'),
    ('yaml editor', 'http://dadacoalition.org/yedit', 'org.dadacoalition.yedit.feature.group'), 
    ('Egit', 'http://download.eclipse.org/egit/updates', 'org.eclipse.egit.feature.group'),
    ('pydev', 'http://pydev.org/updates/', 'org.python.pydev.feature.feature.group'),
    ] %}
# org.python.pydev.mylyn.feature.feature.group

{% set certs= [
    ] %}
#  ('pydev', 'http://pydev.org/pydev_certificate.cer', 'md5=c852152cde986ede2afd78ccee8272f5'),
 
{% for name,url,hash in certs %}
{{ keytool_cert(user,name,url,hash) }}
{% endfor %}
{% for name,url,group in plugins %}
{{ eclipse_plugin(user,name,url,group) }}
{% endfor %}

eclipse-desktop-icon:
  file.managed:
    - source: salt://roles/desktop/eclipse/eclipse.desktop
    - name: {{ user_home }}/.local/share/applications/eclipse.desktop
    - user:  {{ user }}
    - group: {{ user }}
    - makedirs: true
