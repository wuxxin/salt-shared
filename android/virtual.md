# Virtual Android Devices

- Android >= 11 Emulator Image implements on the fly translation of arm code to x86
  therefore making arm binaries from the play store available
- Android >= 14 needs Magisk Version >= 26.x to be rooted
- Android > 12L (api 32) can not be safetynet fixed
- Magisk Versions >= 26.x can only be proper installed with the FAKEBOOTIMG argument


## Voxel - Virtual Pixel 6 with Android 12L (API 32) and Google Play Services


```yaml
model: Pixel 6
model_target: oriole
model_type: Phone
architecture: ARM-64Bit
api: Android 12L (API 32) with Google Play Services
tac: 12345678
fingerprint: google/oriole/oriole:12/SQ3A.220705.001.B2/8836500:user/release-keys
```

### Create Virtual Device (AVD)

Voxel: Pixel 6

```sh
avdmanager create avd --name voxel --device pixel_6 \
    --abi "google_apis_playstore/x86_64" -k "system-images;android-32;google_apis_playstore;x86_64"
```

modify AVD config: ~/.android/avd/voxel/config.ini

```ini
PlayStore.enabled = yes
disk.dataPartition.size=20G
image.sysdir.1=system-images/android-32/google_apis_playstore/x86_64/
avd.id=voxel
avd.name=voxel
tag.display=Google Play
tag.displaynames=Google Play
tag.id=google_apis_playstore
tag.ids=google_apis_playstore
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

- start emulator

```sh
voxel.sh
```

- execute (for each targeted android api) and follow terminal and onscreen instructions

```sh
./rootAVD.sh system-images/android-32/google_apis_playstore/x86_64/ramdisk.img FAKEBOOTIMG GetUSBHPmodZ
```

- add modules:

```sh
cd modules; for i in *; do adb push $i /sdcard/Download/; done; cd ..
```

activate modules in magisk.


### optional: MagiskHidePropsConf (Hide Root/Debug and Emulator Presence)

- get fingerprint of device to mimick:
  - https://developers.google.com/android/binary_transparency/image_info.txt

- write printslist of fingerprints

```printslist
Google Pixel 6 (Android 12-220705):Google:Pixel 6=google/oriole/oriole:12/SQ3A.220705.001.B2/8836500:user/release-keys__2022-07-05
Google Pixel 6a (Android 15-250205-250301):Google:Pixel 6a=google/bluejay/bluejay:15/AP4A.250205.002/12821496:user/release-keys__2025-03-01
Google Pixel 6a (Android 15-250305-250305):Google:Pixel 6a=google/bluejay/bluejay:15/BP1A.250305.019/13003188:user/release-keys__2025-03-05
```

- copy fingerprints to device

```sh
adb push printslist /storage/self/primary/
```

- run magiskhideprops

```sh
adb shell
# become root
su -l
# run props from MagiskHidePropsConf
props
```

- set custom fingerprint
```
1 (edit device fingerprint)
f (pick a certified)
3 (custom)
1,2,3 (select the matching)
y
y
```

- device simulation
```
3 (device simulation)
s (device simulation)
y
1,2,3,9,10 or a (enable all)
y
y
```

ro.boot.serialno: EMULATOR36X2X8X0
ro.build.characteristics: emulator
ro.build.flavor: sdk_gphone64_x86_64-user
ro.build.product: emulator64_x86_64_arm64
ro.product.board: goldfish_x86_64
ro.product.bootimage.brand: google
ro.product.bootimage.device: emulator64_x86_64_arm64
ro.product.bootimage.manufacturer: Google
ro.product.bootimage.model: sdk_gphone64_x86_64
ro.product.bootimage.name: sdk_gphone64_x86_64
ro.product.vendor_dlkm.device]: [emulator64_x86_64_arm64]
 385   │ [ro.product.vendor_dlkm.manufacturer]: [Google]
 386   │ [ro.product.vendor_dlkm.model]: [sdk_gphone64_x86_64]
 387   │ [ro.product.vendor_dlkm.name]: [sdk_gphone64_x86_64]

- check safety net
  - https://github.com/vvb2060/KeyAttestation/releases/download/v1.8.4/KeyAttestation-v1.8.4.apk

```sh
adb install KeyAttestation-v1.8.4.apk
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

