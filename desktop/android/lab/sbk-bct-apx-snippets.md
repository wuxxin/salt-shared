# snippets

## TWRP

+ Mainpage: https://twrp.me/
    + Eu DownloadMirror: https://eu.dl.twrp.me/

+ sourcecode: https://github.com/omnirom/android_bootable_recovery/
+ twrp jenkins builder: https://jenkins.twrp.me/view/prod/
+ download jenkins images at:
    + https://build.twrp.me/$imagename
    + eg. imagename=twrp-3.3.0-0-a3y17lte.img see build output of jenkins

## sbk

sbkcalc:
  cmd.run:
    - name: gcc sbkcalc.c -o sbkcalc

getserial:
  cmd.run:
    - name: sudo adb shell su -c dmesg | grep androidboot.serialno | sed -re "s/.+androidboot.serialno=([0-9a-fA-F]+).+/\1/g"
  require:
    - pkg: android-tools

getsbk:
  cmd.run:
    - name: ./sbcalc `sudo adb shell su -c dmesg | grep androidboot.serialno | sed -re "s/.+androidboot.serialno=([0-9a-fA-F]+).+/\1/g"`
  require:
    - pkg: android-tools

getsbkshort:
  cmd.run:
    - name: ./sbcalc `sudo adb shell su -c dmesg | grep androidboot.serialno | sed -re "s/.+androidboot.serialno=([0-9a-fA-F]+).+/\1/g"` | sed -re "s/0x([0-9A-F]{8}) 0x([0-9A-F]{8}) 0x([0-9A-F]{8}) 0x([0-9A-F]{8})/\1\2\3\4/g"
  require:
    - pkg: android-tools

## apx

mmcblk0_start:
  cmd.run:
    - name: adb shell su -c "dd if=/dev/block/mmcblk0 bs=512 count=13312 of=/sdcard/mmcblk0_start"; adb pull /sdcard/mmcblk0_start .

rip_bct:
  cmd.run:
    - name: ./rip_bct ${GETSBKSHORT}

boot_into_apx:
  cmd.run:
    - name: sudo adb shell su -c "echo 3 > /sys/EcControl/RecoveryMode"
  require:
    - pkg: android-tools

load_apx_mode:
  cmd.run:
    - name: sudo ./nvflash --bct iconia_bct.bin --setbct --bl dlmodebl.bin --configfile flash_ic.cfg --odmdata 0x300d8011 --sbk ${GETSBK} --sync

flash_bootloader:
  cmd.run:
    - name: sudo ./nvflash -r --format_partition 4; sudo ./nvflash -r --download 4 bootloader.bin

flash_recovery:
  cmd.run:
    - name: sudo ./nvflash -r --format_partition 6; sudo ./nvflash -r --download 6 recovery.img

reboot_apx:
  cmd.run:
    - name: sudo ./nvflash -r --go

    