{# http://man7.org/linux/man-pages/man7/inotify.7.html #}
{# This specifies an upper limit on the number of events that can be queued to the corresponding inotify instance. #}
fs.inotify.max_queued_events:
  sysctl.present:
    - value: 1048576 {# 16384 #}

{# This specifies an upper limit on the number of inotify instances that can be created per real user ID. #}
fs.inotify.max_user_instances:
  sysctl.present:
    - value: 1048576 {# 128 #}

{# This specifies an upper limit on the number of watches that can be created per real user ID. #}
fs.inotify.max_user_watches:
  sysctl.present:
    - value: 1048576 {# 8192 #}
