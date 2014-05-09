#roles.desktop: 

Installs and configures features you usually want to have in a working desktop

##Features:

  * Electronic Signing: installes a jre, java browser plugin, chipcard daemon

  * chat: pidgin for chat with otr and other plugins

  * voice: mumble and jitsi and skype (if enabled)

  * Ubuntu specific:
    * freedom: restricted extras (codecs), libcss
    * power:  tlp and other power savings, (ubuntu): reenable suspend to disk
    * ubuntu/unity tweaks:  some unity tweaks (and disable shopping lenses)
      * disable apport

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

  * div:
    * chromium browser


##Pillar-Example:

desktop:
  status: present # installs all sub parts as included in roles.desktop.init.sls
  big:
    status: present # currently unused, but in the future if not set, very big packages will be skipped
  commercial:
    binary:
      status: present # current status: decide if skype is to be installed


##Todo:

install-css does install libcss even if already installed

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
