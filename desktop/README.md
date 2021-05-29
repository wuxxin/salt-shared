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
    enabled:   *false|true      # install signal and skype
  games:
    enabled:   *false|true      # install Arcade-, PS2-, Nintendo64- Emulator
```

## Main Features

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
+ Voice
    + mumble, linphone
+ Chat
    + Element (matrix client)
+ Video
    + vlc, gstreamer and codecs
    + video loopback devices (if enabled)
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
+ jupyterlab with scientific and machinelearning packages
  + (torch, sklearn, tensorflow, fastai, ...)
