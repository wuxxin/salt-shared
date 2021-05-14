
+ desktop example
```yaml
desktop:
  template: host
  options:
    - "--webcam"
environment:
  NO_PULSE_AUDIO: "false"
```

+ command = make a "oneshot" /usr/local/bin , ~/.local/bin script
+ desktop = install desktop files to call as a desktop application via x11docker
{% macro write_desktop(entry, user='') %}
{# write desktop environment files (either for everyone or for one user) #}
{#
/usr/local
~/.local
/share/applications/android-{{ name }}.desktop:
/usr/local
~/.local
/bin/android-{{ name }}.sh:
#}
{% endmacro %}

desktop:
  # template: group of options passed to x11docker:  ['default', 'host']
  template: default
  # options: list of string for additional options for x11docker
  options: []
  # entry: desktop entry is used for .desktop file
  entry: {}
  # type: Application
  # name: Android-Emulator
  # comment: Android Emulator Desktop Version
  # exec: env LANG=de_DE.UTF-8 android-emulator.sh
  # terminal: "true"
  # icon: applications-internet
  # categories: Network;
  # keywords: android;emulator;
