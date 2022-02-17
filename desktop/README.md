# Desktop

Installs and configures features usually wanted for a working desktop

usage:

```yaml
include:
  - desktop

```

## Pillar Settings

```yaml
desktop:
  development:
    enabled:   *false|true      # install developer packages
  video:
    loopback:
      enabled: *false|true      # install video4linux2 loopback kernel modules
  games:
    enabled:   *false|true      # install Arcade-, PS2-, Nintendo64- Emulator
```

## Showcased Features

see desktop.ubuntu , desktop.manjaro for details of packages

+ Audio
    + pipewire as pulseaudio replacement
+ Music
    + lollypop, cdparanoia, sound-juicer, picard
+ Video
    + gstreamer and most codecs
    + video4linux2 and (if enabled) video loopback devices
    + vlc (videolanclient)
    + youtube-dl
+ Voice telephone
    + mumble, linphone
+ Chat and Voice and Video telephone
    + Element (matrix client)
    + Signal
+ Graphics
    + Pixel Software: Gimp, Krita
    + Foto Software: Darktable
    + Vector graphics software: Inkscape
    + OCR packages
    + Clipart packages
+ Writing
    + Libreoffice
    + Sphinx
    + Latex
    + Scribus (DTP)
+ Browser
    + Firefox- , Chromium- \& Tor- Browser
+ Security
    + firejail (restricted application jail)
    + keychain/keyring support packages
    + metadata stripper (mat)
+ Ubuntu
    + reenable suspend to disk, disable apport and whoopsie, a.o.

## Development Features

needs desktop:development:enabled: true

+ Editor: atom
+ Revision control systems & tools, git-crypt
+ Python development
+ Emulation/Virtualization
  + qemu/kvm, libvirt, lxc, vagrant, nspawn, android-emulator
+ jupyterlab with scientific python
  + machinelearning:  sklearn, tensorflow, pytorch and fastai
  + neurophysiological: brainflow, pylsl, neurodsp, mne, opencv
