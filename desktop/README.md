# Desktop

Installs and configures features usually wanted for a working desktop

## Pillar Settings

```yaml
desktop:
  development:
    enabled:   *false|true      # install developer packages
  video:
    loopback:
      enabled: *false|true      # install video4linux2 loopback kernel modules
  proprietary:
    enabled:   *false|true      # allow to install non opensource packages
  games:
    enabled:   *false|true      # install Arcade-, PS2-, Nintendo64- Emulator
```

## Main Features

+ Audio
    + pipewire as pulseaudio replacement
+ Video
    + gstreamer and most codecs
    + video4linux2 and (if enabled) video loopback devices
    + vlc (videolanclient)
    + youtube-dl
+ Voice
    + mumble, linphone
+ Music
    + lollypop, cdparanoia, sound-juicer, picard
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
+ Chat
    + Element (matrix client)
    + Signal (if proprietary is enabled)
+ Security
    + Tor Browser
    + firejail (restricted application jail)
    + keychain/keyring support packages
    + metadata stripper (mat)
    + chipcard hardware daemon
+ Browser
    + Firefox- \& Chromium- Browser
+ Ubuntu
    + reenable suspend to disk, disable apport and whoopsie, a.o.

## Development Features

needs desktop:development:enabled: true

+ Editor: atom
+ Revision control systems & tools, git-crypt, homeshick
+ Python development
+ Emulation/Virtualization
  + qemu/kvm, libvirt, lxc, vagrant, nspawn, android-emulator

+ jupyterlab with scientific python including:
  + machinelearning:  sklearn*, tensor*, torch* and fastai
  + neurophysiological: brainflow, pylsl, neurodsp, mne, opencv
