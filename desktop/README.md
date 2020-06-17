# Desktop

Installs and configures features usually wanted for a working desktop

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
* video: vlc, gstreamer and codecs
* security:
    * tor browser bundle
    * keychain/keyring support packages
    * metadata stripper (mat)
    * firejail restricted application jail

* browser:
    * firefox, chromium browser

* electronic signing:
    * jre, Java Webstart (icedtea-netx), chipcard daemon

* ubuntu:
    * /ubuntu.desktop: reenable suspend to disk, disable apport and whoopsie

* optional:
    * emulation:games: Arcade, PS2, Nintendo64 Emulator

## Development Features

needs desktop:development:enabled: true

* editor: atom
* revision control systems & tools
    * git-crypt, homeshick
* python development
* python sci-py distribution
* android: tools
* emulation:
  * qemu/kvm, libvirt, virt-manager
  * lxd, vagrant, vagrant-libvirt, vagrant-lxd, tools

* optional
    * android: sdk & ndk
    * gcloud: installs google cloud SDK
    * ubuntu.dev: Cubic (Custom Ubuntu ISO Creator)

## Pillar-Example

desktop:
  development:enabled: true    # installs developer packages
vagrant.virtualbox: true       # installs virtualbox if desktop.development
