lxc launch ubuntu-daily:bionic -p default -p nested matrix
lxc file push /etc/apt/sources.list.d/local-docker-custom.list matrix/etc/apt/sources.list.d/
lxc file push /usr/local/lib/docker-custom-archive matrix/usr/local/lib/ -r
lxc shell matrix

# ansible must be >= 2.5.2 , but bionic has 2.5.1
add-apt-repository ppa:ansible/ansible
apt-get update
apt install docker.io pwgen mc ansible python-dns
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

git clone https://github.com/spantaleev/matrix-docker-ansible-deploy.git
cd matrix-docker-ansible-deploy/
mkdir inventory/host_vars/matrix.lxd
cp examples/host-vars.yml  inventory/host_vars/matrix.lxd/vars.yml
cp examples/hosts inventory/hosts
# edit inventory/hosts and inventory/host_vars/matrix.lxd/vars.yml
# patch base installation, see matrix.patch

# building kamax-matrix/mxisd container from source
cd ..
apt install default-jdk-headless
git clone https://github.com/kamax-matrix/mxisd.git
cd mxisd
./gradlew build
./gradlew dockerBuild
cd matrix-docker-ansible-deploy

# install playbook
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all
ansible-playbook -i inventory/hosts setup.yml --tags=start
ansible-playbook -i inventory/hosts setup.yml --tags=self-check
