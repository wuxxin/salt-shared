# Virtual Android Devices

- Android Emulator Image >= 11 implements on the fly translation of arm code to x86,
  therefore making arm binaries from the play store available
- Magisk Versions >= 26.x can only be proper installed with the FAKEBOOTIMG argument
- Android 14 needs Magisk Version >= 26.x to be rooted

Example: **Voxel** - a Virtual Pixel 6a with Android 14 (API 34)

```yaml
model: Pixel 6a
name: bluejay
type: Phone
architecture: ARM-64Bit
api: Android 14 (API 34) with Google Services
tac: 35598476
# random generated imei from correct tac
imei: 355984766831784
```

## Create Virtual Device (AVD)

Voxel: Pixel 6a , API 34

```sh
avdmanager create avd --name voxel --device pixel_6a \
  --abi "google_apis_playstore/x86_64" -k "system-images;android-34;google_apis_playstore;x86_64"
```

modify AVD config: ~/.android/avd/voxel/config.ini

```ini
disk.dataPartition.size=20G
sdcard.size=1024 MB
PlayStore.enabled=yes
avd.id=voxel
avd.name=voxel
fastboot.forceColdBoot=yes
fastboot.forceFastBoot=no
```

- create symlink of android-launch.sh

```sh
cd ~/.local/bin
ln -s launch-android.sh voxel.sh
```

## Root, Debug and Emulator Disguise Modifications

Warning: Ramdisk of every virtual android with the same api version is affected

Information:

- Magisk Versions >= 26.x can only be proper installed with the FAKEBOOTIMG argument
- Android 14 needs Magisk Version >= 26.x to be rooted

Clone:

- https://gitlab.com/newbit/rootAVD.git

Download as ./Magisk.zip and Apps/Magisk.apk

- https://github.com/topjohnwu/Magisk/

Download into modules/

- https://github.com/Magisk-Modules-Repo/MagiskHidePropsConf
- https://github.com/kdrag0n/safetynet-fix
- https://gitlab.com/newbit/usbhostpermissions
- https://github.com/ViRb3/magisk-frida

### Installation

execute (for each targeted android api) and follow terminal and onscreen instructions.

```sh
./rootAVD.sh system-images/android-34/google_apis_playstore/x86_64/ramdisk.img FAKEBOOTIMG PATCHFSTAB GetUSBHPmodZ
```

add modules:

```sh
cd modules; for i in *; do adb push $i /sdcard/Download/; done; cd ..
```

activate modules in magisk.


### optional: MagiskHidePropsConf

emulator traces:

```java
Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
Build.FINGERPRINT.startsWith("generic")
Build.FINGERPRINT.startsWith("unknown")
Build.HARDWARE.contains("goldfish")
Build.HARDWARE.contains("ranchu")
Build.MODEL.contains("google_sdk")
Build.MODEL.contains("Emulator")
Build.MODEL.contains("Android SDK built for x86")
Build.MANUFACTURER.contains("Genymotion")
Build.PRODUCT.contains("sdk_google")
Build.PRODUCT.contains("google_sdk")
Build.PRODUCT.contains("sdk")
Build.PRODUCT.contains("sdk_x86")
Build.PRODUCT.contains("sdk_gphone64_arm64")
Build.PRODUCT.contains("vbox86p")
Build.PRODUCT.contains("emulator")
Build.PRODUCT.contains("simulator");
```

copy fingerprints

```sh
adb push printfiles-dev.sh /data/adb/modules/MagiskHidePropsConf/printfiles/Dev.sh
```

run props from MagiskHidePropsConf

```sh
adb shell
su -l
props
```

### optional: create and patch desired imei

```sh
# from salt-shared/android
# generate a imei from tac and optional serial
calculate-imei.py 12345678 [123456]

# emulator: 35824005 111111 0
# google pixel (1): 35161508 710935 1

# patch qemu runtime for mobile carrier name and device imei
pushd ~/code/android/sdk/emulator/qemu/linux-x86_64
python -c "import sys; f=open('qemu-system-x86_64','rb'); s=f.read(); f.close();
s=s.replace(b'TelKila', b'A1     ');
s=s.replace(b'358240051111110', b'351615087109351');
w=open('qemu-system-x86_64.vixel', 'wb'); w.write(s); w.close()"
chmod +x qemu-system-x86_64.vixel
popd
```

## Insert ROOT-CA into System Store

### Tested on emulators running API LEVEL 29 and 30

Instructions:

- List your AVDs: emulator -list-avds (If this yields an empty list, create a new AVD in the Android Studio AVD Manager)
- Start the desired AVD: emulator -avd <avd_name_here> -writable-system (add -show-kernel flag for kernel logs)
- restart adb as root: adb root
- disable secure boot verification: adb shell avbctl disable-verification
- reboot device: adb reboot
- restart adb as root: adb root
- perform remount of partitions as read-write: adb remount. (If adb tells you that you need to reboot, reboot again adb reboot and run adb remount again.)
- push your renamed certificate from step 2: adb push <path_to_certificate> /system/etc/security/cacerts
- set certificate permissions: adb shell chmod 664 /system/etc/security/cacerts/<name_of_pushed_certificate>
- reboot device: adb reboot

```sh
adb root
adb shell avbctl disable-verification
adb reboot
adb root
adb remount
```

### manual install

```text
Open settings
Go to 'Security'
Go to 'Encryption & Credentials'
Go to 'Install from storage'
Select 'CA Certificate' from the list of types available
Accept a large scary warning
Browse to the certificate file on the device and open it
Confirm the certificate install
```


