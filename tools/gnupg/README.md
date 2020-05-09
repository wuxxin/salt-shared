# python bindings

+ use official python bindings (gpgme) "python3-gpg" from gnupg that are comming with system
+ use Hkp4py for keyserver
+ create mime email by hand

# create gpg key and encrypt with personal keychain
gpg --quiet --no-default-keyring --enable-special-filenames --batch --yes --armor --gen-key | gpg --encrypt > ./user@email.gpg.crypted << EOF
Key-Type: 1
Key-Length: 2048
Expire-Date: 0
Name-Real: user@email
%secring -&1
%pubring -&2
%commit
EOF

# import newly generated key into personal keychain
cat ./user@email.gpg.crypted | gpg --decrypt | gpg --batch --yes --import

# add to git-crypt keys
git-crypt add-gpg-user user@email


manual-install-git-crypt(){
  apt-get -y install libssl-dev build-essential git-buildpackage debhelper
  git clone https://github.com/AGWA/git-crypt.git /tmp/git-crypt
  cd /tmp/git-crypt
  gbp buildpackage -uc -us --git-ignore-new && DEBIAN_FRONTEND=noninteractive dpkg -i `ls /tmp/git-crypt/*.deb`
  rm -rf /tmp/git-crypt
  apt-get -y remove --purge libssl-dev build-essential git-buildpackage debhelper
}


get ssh public key from secret key:
`cat deployment.ssh.secret | sed "/^{%.*%}/d" | ssh-keygen -y -f /dev/stdin`
