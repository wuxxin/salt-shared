# desktop

Installs and configures features you usually want to have in a working desktop

## Features

  * Electronic Signing: installes a jre, java browser plugin, chipcard daemon

  * ubuntu:
    * user: disable shopping lenses
    * /ubuntu.desktop: reenable suspend to disk, disable apport and whoopsie, install ubuntu/unity tweaks program

  * voice: mumble skype (if enabled)
  * video: vlc and mpv and codecs
  * graphics:
    * installs Pixel Software: gimp, krita, darktable
    * ocr software
    * vector graphics software inkscape
    * dtp software: scribus

  * Development:
    * ide: atom
    * revision control systems 
    * android: installes and configures android sdk & ndk
    * gcloud: installs google cloud SDK
    * buildozer installation (kivy - python-for-android - android-sdk, android-ndk buildchain)
    * emulator:
      * install all qemu variants, install virt-manager

  * security:
    * install programms that have keychain support
    * install a metadata stripper (mat)
    * install a tor browser bundle

  * browser:
    * chromium browser, firefox-std/esr/dev, java plugin

## Pillar-Example


desktop:
  developer: enabled: true    # installs developer packages 
  commercial:enabled: true    # installs proprietary packages (currently skype)
  games: enabled: true        # installs additional game emulators
  bitcoin: enabled: true      # installs bitcoind
  
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
