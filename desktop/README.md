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
```

## Main Features

* graphics:
    * Pixel Software: gimp, krita, darktable
    * Ocr software
    * Vector graphics software: inkscape
    * Clipart packages

* writing:
    * libreoffice
    * sphinx, latex
    * dtp software: scribus

* voice: mumble, linphone, skype (if enabled)

* chat: riot, signal, optional: pidgin

* video: vlc, gstreamer and codecs, video loopback devices (if enabled)

* security:
    * tor browser bundle
    * keychain/keyring support packages
    * metadata stripper (mat)
    * firejail restricted application jail

* browser:
    * firefox, chromium browser

* hardware support:
    * electronic signing chipcard daemon

* ubuntu:
    * /ubuntu.desktop: reenable suspend to disk, disable apport and whoopsie

* optional:
    * emulation:games: Arcade, PS2, Nintendo64 Emulator

## Development Features

needs desktop:development:enabled: true

* editor: atom
* revision control systems & tools, git-crypt, homeshick
* python development
* jupyterlab with scientific python
* android tools
* emulation/virtualization: qemu/kvm, libvirt, lxc, vagrant, nspawn
