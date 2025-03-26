#!/bin/bash
set -eux
source /etc/profile.d/android-sdk-platform-tools.sh
sudo chown    $(id -u):$(id -g) /dev/kvm 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) /dev/snd 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) /dev/video{0..10} 2>/dev/null || true
sudo qemu-system-x86_64 -m ${RAM:-4}000 \
${ENABLE_KVM-"-enable-kvm"} \
-cpu ${CPU-host},${CPUID_FLAGS-"+invtsc,vmware-cpuid-freq=on,+pcid,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check,"}${BOOT_ARGS} \
-smp ${CPU_STRING:-$(nproc)} \
-machine q35,${KVM-"accel=kvm:tcg"} \
-smp ${CPU_STRING:-${SMP:-4},cores=${CORES:-4}} \
-hda "${IMAGE_PATH:=/home/arch/dock-droid/android.qcow2}" \
-usb -device usb-kbd -device usb-tablet \
-bios /usr/share/OVMF/x64/OVMF.fd \
-smbios type=2 \
-audiodev ${AUDIO_DRIVER:-alsa},id=hda -device ich9-intel-hda -device hda-duplex,audiodev=hda \
-device usb-ehci,id=ehci \
-netdev user,id=net0,hostfwd=tcp::${INTERNAL_SSH_PORT:-10022}-:22,hostfwd=tcp::${SCREEN_SHARE_PORT:-5900}-:5900,hostfwd=tcp::${ADB_PORT:-5555}-:5555,${ADDITIONAL_PORTS} \
-device ${NETWORKING:-vmxnet3},netdev=net0,id=net0,mac=${MAC_ADDRESS:-00:11:22:33:44:55} \
-monitor stdio \
-boot menu=on \
-cdrom "${CDROM:-${CDROM}}" \
${DISPLAY_ARGUMENTS:=-vga vmware} \
${WEBCAM:-} \
${EXTRA:-}
