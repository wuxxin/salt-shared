
date > /etc/vagrant_box_build_time

VAGRANT_USER=vagrant
VAGRANT_HOME=/home/$VAGRANT_USER
VAGRANT_KEY_URL=https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub

echo "Create Vagrant user (if not already present)"
if ! id -u $VAGRANT_USER >/dev/null 2>&1; then
    /usr/sbin/groupadd $VAGRANT_USER
    /usr/sbin/useradd $VAGRANT_USER -g $VAGRANT_USER -G sudo -d $VAGRANT_HOME --create-home
fi

echo "NOT setting a password for user $VAGRANT_USER, because we prefer ssh public key"
# echo "${VAGRANT_USER}:${VAGRANT_USER}" | chpasswd

echo "Set up sudo for vagrant"
echo "${VAGRANT_USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

echo "reCreate Homedir and .ssh dir"
mkdir $VAGRANT_HOME/.ssh
chmod 700 $VAGRANT_HOME/.ssh
cd $VAGRANT_HOME/.ssh

if test -f authorized_keys; then
    echo "authorized ssh keys already there, nothing to do"
    cat authorized_keys
elif test -f /root/.ssh/authorized_keys; then
    echo "authorized ssh keys are available for /root, copy them from there"
    cp /root/.ssh/authorized_keys $VAGRANT_HOME/.ssh/authorized_keys
else
    echo "Install public! vagrant keys for user vagrant"
    wget --no-check-certificate "${VAGRANT_KEY_URL}" -O authorized_keys
fi

echo "chmod and chown for user $VAGRANT_USER and ~/.ssh/authorized_keys"
chmod 600 $VAGRANT_HOME/.ssh/authorized_keys
chown -R $VAGRANT_USER:$VAGRANT_USER $VAGRANT_HOME/.ssh
