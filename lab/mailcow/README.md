# look at https://labs.theshire.space/promaethius/mailcow-dind
# is mailcow in docker in docker for kubernetes

lxc launch ubuntu-daily:bionic -p default -p nested mailcow
lxc file push /etc/apt/sources.list.d/local-docker-custom.list mailcow/etc/apt/sources.list.d/
lxc file push /usr/local/lib/docker-custom-archive mailcow/usr/local/lib/ -r
lxc shell mailcow

cat - > /root/install.sh <<"INSTALLEOF"
mkdir -p /etc/docker
cat - > /etc/docker/daemon.json <<"EOF"
{
	"experimental": true,
	"features": {"buildkit": true},
	"storage-driver": "overlay2",
	"log-driver": "syslog"
}
EOF
DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get install -y docker.io bridge-utils ebtables gnupg2 pass 
apt-get install -y python3 python3-pip python3-setuptools python3-venv
apt-get install -y python3-cached-property python3-distutils python3-docker python3-dockerpty python3-docopt python3-jsonschema python3-requests python3-six python3-texttable python3-websocket python3-yaml
pip3 install -U pip
/usr/local/bin/pip3 install docker-compose

umask
# 0022
cd /opt
git clone https://github.com/mailcow/mailcow-dockerized
cd mailcow-dockerized
INSTALLEOF
chmod +x /root/install.sh
