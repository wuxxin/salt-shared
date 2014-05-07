set -x

create_home(){
# Create the home directory
mkdir -p /home/vagrant
chown vagrant /home/vagrant
cd /home/vagrant

}

install_ssh_certs(){
# Install ssh certificates
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh
cd ..
}

extend_cygwin() {
# Install rpm,apt-get like code for cygwin
# http://superuser.com/questions/40545/upgrading-and-installing-packages-through-the-cygwin-command-line
wget http://apt-cyg.googlecode.com/svn/trunk/apt-cyg
chmod +x apt-cyg
mv apt-cyg /usr/local/bin/
}


install_vbox_addons(){
# 7zip will allow us to extract a file from an ISO
wget http://downloads.sourceforge.net/sevenzip/7z922-x64.msi
msiexec /qb /i 7z922-x64.msi

# Download Virtualbox Additions
VBOX_VERSION="4.2.16" #"4.0.8"
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso

# Extract the installer from the ISO (WHY WHY WHY isn't this available not bundled within an ISO)
/cygdrive/c/Program\ Files/7-Zip/7z.exe x VBoxGuestAdditions_$VBOX_VERSION.iso VBoxWindowsAdditions-amd64.exe

# Mark Oracle as a trusted installer
#http://blogs.msdn.com/b/steverac/archive/2009/07/09/adding-certificates-to-the-local-certificates-store-and-setting-local-policy-using-a-command-line-system-center-updates-publisher-example.aspx
certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer

# Install the Virtualbox Additions
./VBoxWindowsAdditions-amd64.exe /S
}

install_kvm_addons(){
SPICE_VERSION="0.59"
# bcdedit test signing on something parameter before install of guest tools
/cygdrive/c/Windows/Sysnative/bcdedit.exe -set TESTSIGNING ON
wget http://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-${SPICE_VERSION}.exe
chmod +x spice-guest-tools-${SPICE_VERSION}.exe
./spice-guest-tools-${SPICE_VERSION}.exe /S
/cygdrive/c/Windows/Sysnative/bcdedit.exe -set TESTSIGNING OFF
}

install_chef_client(){
#Rather than do the manual install of ruby and chef, just use the opscode msi
curl -L http://www.opscode.com/chef/install.msi -o chef-client-latest.msi
msiexec /qb /i chef-client-latest.msi

#Making aliases
cat <<EOF > /home/vagrant/.bash_profile
alias chef-client="chef-client.bat"
alias gem="gem.bat"
alias ruby="ruby.exe"
alias puppet="puppet.bat"
alias ohai="ohai.bat"
alias irb="irb.bat"
alias facter="facter.bat" 
EOF
}


install_salt_minion(){
SALT_VERSION="0.16.0"
wget http://saltstack.com/downloads/Salt-Minion-${SALT_VERSION}-AMD64-Setup.exe
chmod +x Salt-Minion-${SALT_VERSION}-Setup-amd64.exe
./Salt-Minion-${SALT_VERSION}-Setup-amd64.exe /S /master=salt /minion-name=win7-64
}


sudo_fix(){
cat <<'EOF' > /bin/sudo
#!/usr/bin/bash
exec "$@"
EOF
chmod 755 /bin/sudo
}


indicate_success(){
# Mounting a directory
net.exe use  '\\vboxsvr\veewee-validation'
}


reboot_machine(){
# Reboot
# http://www.techrepublic.com/blog/datacenter/restart-windows-server-2003-from-the-command-line/245
shutdown.exe /s /t 0 /d p:2:4 /c "Vagrant initial reboot"
}


# main
create_home
install_ssh_certs
extend_cygwin
#install_vbox_addons
#install_kvm_addons
#install_chef_client
install_salt_minion
sudo_fix
indicate_success
reboot_machine
