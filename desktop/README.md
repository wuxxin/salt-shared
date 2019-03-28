# desktop

Installs and configures features usually wanted for a working desktop

## Desktop Features

* graphics:
    * clipart, fonts, icons
    * Pixel Software: gimp, krita, darktable
    * Ocr software
    * Vector graphics software: inkscape

* writing:
    * libreoffice
    * sphinx, latex
    * dtp software: scribus
    * optional
        * doconce
        * zotero

* voice: mumble, linphone, skype (if enabled)
* chat: riot, signal, optional: pidgin
* video: mpv, vlc, gstreamer and codecs
* security:
    * tor browser bundle
    * keychain/keyring support packages
    * metadata stripper (mat)
    * firejail restricted application jail

* browser:
    * firefox, chromium browser

* Electronic Signing: 
    * jre, java browser plugin, chipcard daemon

* ubuntu:
    * user: disable shopping lenses and other spam
    * /ubuntu.desktop: reenable suspend to disk, disable apport and whoopsie

## Development Features

(needs desktop:developer:enabled: true)

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
    * buildozer (kivy - python-for-android - android-sdk, android-ndk buildchain)
    * emulation:games: Arcade, PS2, Nintendo64 Emulator

## Pillar-Example

desktop:
  developer:enabled: true    # installs developer packages
  proprietary:enabled: true   # installs proprietary packages
    # skype (if desktop)
    # virtualbox (if desktop.developer and vagrant.virtualbox: true)
  games:enabled: true        # installs additional game emulators
  bitcoin:enabled: true      # installs bitcoind
  
## Todo

* development:
   * openwrt: tiny linux distribution
   * tinyos: TinyOS for 16bit embedded processors
   * contiki, contiki-tres: OS for 16 bit processors
   * riot: OS for 16 bit processors
   * arduino: semi os stack for 16 bit processors
   * pymite: python on a chip
   * more internet of things stuff and bridging of technology between:
    *  python on 16bit, linux embedded, android, desktop 
       * contiki: https://github.com/tecip-nes/contiki-tres
       * openwrt: https://github.com/nodesign/weio
