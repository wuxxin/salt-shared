# Radeon GPU Accelerated Applications - VAAPI and VDPAU Support

+ <https://wiki.archlinux.org/title/Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/Firefox#Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/GStreamer#Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/FFmpeg#Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/Mpv#Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/VLC_media_player#Hardware_video_acceleration>
+ <https://wiki.archlinux.org/title/Backlight#Color_correction>

## check opencl support

```sh
clinfo
```

## check vaapi, vdpau support

```shell
vainfo
vdpauinfo
gst-inspect-1.0 vaapi
```

## check hardware assisted image support

```shell
clinfo | grep -i "image support"
```

## applications with vaapi/vdpau support

+ darktable – OpenCL feature requires at least 1 GB RAM on GPU and Image support (check output of clinfo command).
+ FFmpeg – <https://trac.ffmpeg.org/wiki/HWAccelIntro#OpenCL>
+ GIMP – experimental – <http://www.h-online.com/open/news/item/GIMP-2-8-RC-1-arrives-with-GPU-acceleration-1518417.html>
+ darktable – OpenCL feature requires at least 1 GB RAM on GPU and Image support (check output of clinfo command).
+ DaVinci Resolve - a non-linear video editor. Can use both OpenCL and CUDA.
+ lc0AUR - Used for searching the neural network (supports tensorflow, OpenCL, CUDA, and openblas)
+ HandBrake
+ Hashcat
+ imagemagick
+ opencv

### firefox (97+) about:config

+ media.ffmpeg.vaapi.enabled: true

### chromium (97+)

```sh
# ~/.config/chromium-flags.conf
--ozone-platform-hint=auto
--ignore-gpu-blocklist
--enable-gpu-rasterization
--enable-zero-copy
```

#### optional patched AUR version of chromium with vaapi support under wayland

```yaml
chromium-wayland-vaapi:
  pkg:
    - installed
```
