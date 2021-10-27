{% set reddroid_module_list= ['ashmem_linux', 'binder_linux', 'mac80211_hwsim'] %}

redroid-kernel-modules:
    kmod.present:
      - mods:
  {%- for i in reddroid_module_list %}
        - {{ i }}
  {%- endfor %}

/etc/modules-load.d/redroid.conf:
  file.managed:
    - contents: |
  {%- for i in reddroid_module_list %}
        {{ i }}
  {%- endfor %}

{#
+ https://github.com/remote-android/redroid-doc

+ https://github.com/remote-android/redroid-doc/tree/master/android-builder-docker

# start and connect via `scrcpy` (Performance boost, *recommended*)
docker run -itd --rm --memory-swappiness=0 --privileged\
	-v ~/data:/data \
	-p 5555:5555 \
	redroid/redroid:10.0.0-latest
adb connect <IP>:5555
scrcpy --serial <IP>:5555
## explains:
## -v ~/data:/data  -- mount data partition
## -p 5555:5555 -- 5555 for adb connect, you can run `adb connect <IP>`

# start with built-in VNC support (debug only)
docker run -itd --rm --memory-swappiness=0 --privileged \
	-v ~/data:/data  \
	-p 5900:5900 -p 5555:5555 \
	redroid/redroid:10.0.0-latest redroid.vncserver=1
## explains:
## -p 5900:5900 -- 5900 for VNC connect, you can connect via VncViewer with <IP>:5900

#}
