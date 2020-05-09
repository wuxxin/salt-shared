{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
include:
  - desktop.ubuntu.desktop

disable-shopping-lenses:
  cmd.run:
    - name: gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']"
    - runas: {{ user }}
    - require:
      - sls: desktop.ubuntu.desktop

power-button-interactive:
  cmd.run:
    - name: gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
    - runas: {{ user }}
    - require:
      - sls: desktop.ubuntu.desktop

{#
ubuntu-f10-fix:

mkdir -p ~/.config/gtk-3.0 
cat << EOF > ~/.config/gtk-3.0/gtk.css 
@binding-set NoKeyboardNavigation { 
     unbind "F10" 
} 

* { 
    gtk-key-bindings: NoKeyboardNavigation 
} 

EOF
#}