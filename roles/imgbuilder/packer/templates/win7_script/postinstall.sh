set -x

cat <<'EOF' > /bin/sudo
#!/usr/bin/bash
exec "$@"
EOF
chmod 755 /bin/sudo

# Reboot
# http://www.techrepublic.com/blog/datacenter/restart-windows-server-2003-from-the-command-line/245
shutdown.exe /s /t 0 /d p:2:4 /c "Vagrant initial reboot"

