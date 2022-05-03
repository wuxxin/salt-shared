{# Gigabyte b550 AORUS ELITE AX V2

motherboard: https://www.gigabyte.com/Motherboard/B550-AORUS-ELITE-AX-V2-rev-10/support
monitoring driver: https://github.com/frankcrawford/it87

## Motherboard Hardware Sensors SuperIO Chip (IT8688E)

+ board has superio chip (IT8688E) for temperature and fan sensors/control
+ lmsensors does not have support for it, but AUR has a dkms for it
+ the dkms conflicts with the BIOS, see
  + https://bugzilla.kernel.org/show_bug.cgi?id=204807#c37

+ Solution 1: Use WMI Driver (only temperature sensors, no fan rotation sensors or control)

```shell
modprobe gigabyte_wmi
```

+ Solution 2: compile custom driver, change kernel parameter
  + potential conflicting access between BIOS and Kernel

```shell
yay -S --noconfirm it87-dkms-git
# insert acpi_enforce_resources=lax to kernel boot parameter, reboot
modprobe it87
sensor-detect
```
#}

{% for i in ['gigabyte_wmi',] %}
/etc/modules-load.d/{{ i }}.conf:
  file.managed:
    - contents: |
        {{ i }}
load-{{ i }}-kernel-module:
  kmod.present:
    - name: {{ i }}
{% endfor %}
