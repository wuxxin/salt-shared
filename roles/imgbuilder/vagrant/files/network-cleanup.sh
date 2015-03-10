echo "cleaning up udev rules: Make sure Udev doesn't block our network http://6.ptmc.org/?p=164"
rm -rf /dev/.udev/

if [ -d "/lib/udev/rules.d" ]; then
    echo "delete persistent-net udev (debian)"
    rm /lib/udev/rules.d/75-persistent-net-generator.rules
fi
if [ -d "/etc/udev/rules.d" ]; then
    echo "delete persistent-net udev (centos)"
    rm -f /etc/udev/rules.d/70-persistent-net.rules
fi

if [ -d "/var/lib/dhcp" ]; then
    echo "cleaning up dhcp leases (debian derivat)"
    rm /var/lib/dhcp/*
fi

if [ -d "/var/lib/dhclient" ]; then
    echo "cleaning up dhcp leases (centos)"
    rm -f /var/lib/dhclient/dhclient-eth0.leases
fi

if test -f /etc/sysconfig/network-scripts/ifcfg-eth0; then
    echo "cleaning up network uuid, hwaddr, /etc/ssh/ssh_host_* (centos)"
    sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0
    sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
fi
