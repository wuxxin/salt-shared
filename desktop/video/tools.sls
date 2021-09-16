include:
  - desktop.video.framework

v4l2-tools:
  pkg.installed:
    - pkgs:
      - qv4l2       {# Graphical Qt v4l2 control panel #}
      - uvcdynctrl  {# Command line tool to control v4l2 devices #}
      - v4l-utils   {# video4linux command line utilities #}
      - yavta       {# test Video4Linux2 devices #}
      - fswebcam    {# Tiny and flexible webcam program #}
