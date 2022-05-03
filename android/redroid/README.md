# android.redroid.lib

Create and launch a (same kernel) android container using ReDroid.

+ `redroid_service()`

## about redroid

+ https://github.com/remote-android/redroid-doc

ReDroid (Remote Android) is a GPU accelerated AIC (Android In Container) solution. You can boot many instances in Linux host or any Linux container envrionments (Docker, K8S, LXC etc.). ReDroid supports both arm64 and amd64 architectures. You can connect to ReDroid througth VNC or scrcpy / sndcpy or WebRTC (Panned) or adb shell. ReDroid is suitable for Cloud Gaming, VDI / VMI (Virtual Mobile Infurstrure), Automation Test and more.

```sh

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
```
