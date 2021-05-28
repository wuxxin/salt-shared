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
    + Pixel Software: gimp, krita, darktable
    + Vector graphics software: inkscape
    + OCR packages
    + Clipart packages
+ Writing
    + libreoffice
    + sphinx
    + latex
    + dtp software: scribus
+ Voice
    + mumble, linphone
+ Chat
    + Elements (matrix client)
+ Video
    + vlc, gstreamer and codecs
    + video loopback devices (if enabled)
+ Security
    + tor browser bundle
    + keychain/keyring support packages
    + metadata stripper (mat)
    + firejail restricted application jail
+ Browser
    + firefox-, chromium- browser
+ Hardware support
    + electronic signing chipcard daemon
+ Ubuntu
    + /ubuntu.desktop: reenable suspend to disk, disable apport and whoopsie

## Development Features

needs desktop:development:enabled: true

+ Editor: atom
+ Revision control systems & tools, git-crypt, homeshick
+ Python development
+ Emulation/Virtualization
  + qemu/kvm, libvirt, lxc, vagrant, nspawn
+ pipx installed jupyterlab with
  + scientific python packages ()
  + machinelearning packages (torch, sklearn, tensorflow, fastai, ...)
+ Android tools
