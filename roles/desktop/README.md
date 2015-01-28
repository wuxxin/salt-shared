#roles.desktop: 

Installs and configures features you usually want to have in a working desktop

##Todo:
 * add partner and extra repositories
 * add supported languages packages install (one click at languages)
 * apt-get install exfat-fuse exfat-utils
 * install-css does install libcss even if already installed

 * interesting stuff to look at:
   * utrac: http://www.ubuntuupdates.org/package/getdeb_apps/trusty/apps/getdeb/utrac

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
       * android: 

##Features:

  * Electronic Signing: installes a jre, java browser plugin, chipcard daemon

  * chat: pidgin for chat with otr and other plugins

  * voice: mumble and jitsi and skype (if enabled)
  * video: vlc and mplayer2 and codecs

  * roles.desktop.ubuntu:
    * restricted extras (codecs), libcss
    * power:  tlp
    * sensor: psensor
    * user: disable shopping lenses
    * /ubuntu.desktop: reenable suspend to disk, disable apport and whoopsie, install ubuntu/unity tweaks program

  * graphics:
    * installs Pixel Software: gimp, krita, darktable
    * ocr software
    * vector graphics software inkscape
    * dtp software: scribus

  * Development:
    * revision control systems (mercurial and git and subversion)
    * android: installes and configures android sdk & ndk
      * optional IDEA and ECLIPSE plugin installation
    * buildozer installation (kivy - python-for-android - android-sdk, android-ndk buildchain)
    * ide: eclipse and idea
    * emulator:
      * install all qemu variants, install virt-manager

  * security:
    * install programms that have keychain support
    * install a metadata stripper (mat)
    * install a tor browser bundle

  * browser:
    * chromium browser, firefox, java plugin

##Pillar-Example:

desktop:
  status: present # installs all sub parts as included in roles.desktop.init.sls
  developer: status: present # installs developer packages (see init.sls)
  commercial: status: present # installs also commercial software (eg. skype)
